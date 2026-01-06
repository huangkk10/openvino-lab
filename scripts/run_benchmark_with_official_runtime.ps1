<#
.SYNOPSIS
    Execute precompiled benchmark_genai.exe with official C++ Runtime
    
.DESCRIPTION
    This script automatically sets up environment and executes benchmark_genai.exe
    - Automatic temporary PATH setup (no system impact)
    - Check all necessary DLL dependencies
    - Support custom parameters
    - Clear error messages
    - Smart path detection: can run from anywhere in the repo
    
.PARAMETER Model
    Model path (default: auto-detect from repo structure)
    
.PARAMETER Device
    Device type: CPU or GPU (default: CPU)
    
.PARAMETER Prompt
    Input prompt text (default: "What is OpenVINO?")
    
.PARAMETER MaxTokens
    Maximum tokens to generate (default: 20)
    
.PARAMETER NumIterations
    Number of test iterations (default: 1)
    
.EXAMPLE
    .\run_benchmark_with_official_runtime.ps1
    Run with default parameters (CPU test)
    
.EXAMPLE
    .\run_benchmark_with_official_runtime.ps1 -Device GPU
    Run GPU test
    
.EXAMPLE
    .\run_benchmark_with_official_runtime.ps1 -MaxTokens 50 -NumIterations 3
    Custom parameters test
    
.EXAMPLE
    .\run_benchmark_with_official_runtime.ps1 -Model "C:\path\to\custom\model"
    Use custom model path

.NOTES
    This script can be run from:
    - Repository root: .\scripts\run_benchmark_with_official_runtime.ps1
    - Scripts directory: .\run_benchmark_with_official_runtime.ps1
    - Any subdirectory: ..\scripts\run_benchmark_with_official_runtime.ps1
#>

param(
    [string]$Model = "",
    [ValidateSet("CPU", "GPU")]
    [string]$Device = "CPU",
    [string]$Prompt = "What is OpenVINO?",
    [int]$MaxTokens = 20,
    [int]$NumIterations = 1
)

# Set console output encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Display header
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  OpenVINO GenAI Benchmark (C++ Runtime)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ============================================================================
# Smart Path Detection: Find repository root
# ============================================================================

function Find-RepoRoot {
    param([string]$StartPath)
    
    $current = $StartPath
    $maxDepth = 10
    $depth = 0
    
    while ($depth -lt $maxDepth) {
        # Check for .git directory or pyproject.toml (repo markers)
        if ((Test-Path (Join-Path $current ".git")) -or 
            (Test-Path (Join-Path $current "pyproject.toml"))) {
            return $current
        }
        
        $parent = Split-Path -Parent $current
        if ([string]::IsNullOrEmpty($parent) -or ($parent -eq $current)) {
            break
        }
        $current = $parent
        $depth++
    }
    
    return $null
}

Write-Host "Detecting repository structure..." -ForegroundColor Yellow
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Find-RepoRoot $scriptDir

if ($null -eq $repoRoot) {
    Write-Host "[ERROR] Cannot find repository root" -ForegroundColor Red
    Write-Host "   Please ensure you're running this script from within the openvino-lab repository" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Repository root: $repoRoot" -ForegroundColor Green

# ============================================================================
# Define paths relative to repository root
# ============================================================================

# Try multiple possible locations for runtime and benchmark
$possibleBinPaths = @(
    (Join-Path $repoRoot "nvme_dsm_test\openvino_cpp_runtime\bin"),
    (Join-Path $repoRoot "scripts\openvino_cpp_runtime\bin")
)

$binPath = $null
foreach ($path in $possibleBinPaths) {
    if (Test-Path $path) {
        $binPath = $path
        break
    }
}

$possibleExePaths = @(
    (Join-Path $repoRoot "nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe"),
    (Join-Path $repoRoot "benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe")
)

$exePath = $null
foreach ($path in $possibleExePaths) {
    if (Test-Path $path) {
        $exePath = $path
        break
    }
}

# Auto-detect model path if not specified
if ([string]::IsNullOrEmpty($Model)) {
    $possibleModelPaths = @(
        (Join-Path $repoRoot "models\open_llama_7b_v2-int4-ov"),
        "C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov"
    )
    
    foreach ($path in $possibleModelPaths) {
        if (Test-Path $path) {
            $Model = $path
            break
        }
    }
    
    if ([string]::IsNullOrEmpty($Model)) {
        Write-Host "[ERROR] Cannot auto-detect model path" -ForegroundColor Red
        Write-Host "   Please specify model path with -Model parameter" -ForegroundColor Yellow
        Write-Host "   Example: -Model `"C:\path\to\model`"" -ForegroundColor Yellow
        exit 1
    }
}

# ============================================================================
# Validate all required paths
# ============================================================================

# 2. Check executable
Write-Host "Checking benchmark_genai.exe..." -ForegroundColor Yellow
if ($null -eq $exePath -or -not (Test-Path $exePath)) {
    Write-Host "[ERROR] Cannot find benchmark_genai.exe" -ForegroundColor Red
    Write-Host "   Searched locations:" -ForegroundColor Red
    foreach ($path in $possibleExePaths) {
        Write-Host "   - $path" -ForegroundColor Red
    }
    Write-Host "`n   Please ensure benchmark_genai.exe is in nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] benchmark_genai.exe found: $exePath" -ForegroundColor Green

# 3. Check bin directory
Write-Host "Checking DLL directory..." -ForegroundColor Yellow
if ($null -eq $binPath -or -not (Test-Path $binPath)) {
    Write-Host "[ERROR] Cannot find bin directory" -ForegroundColor Red
    Write-Host "   Searched locations:" -ForegroundColor Red
    foreach ($path in $possibleBinPaths) {
        Write-Host "   - $path" -ForegroundColor Red
    }
    Write-Host "`n   Please complete Stage 1+2 first: run scripts\install_openvino_runtime.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] DLL directory found: $binPath" -ForegroundColor Green

# 4. Check required DLLs (critical dependencies)
Write-Host "Checking required DLLs..." -ForegroundColor Yellow
$requiredDlls = @(
    "openvino_genai.dll",
    "openvino.dll",
    "openvino_tokenizers.dll",
    "openvino_ir_frontend.dll",
    "openvino_intel_cpu_plugin.dll"
)

$missingDlls = @()
foreach ($dll in $requiredDlls) {
    $dllPath = Join-Path $binPath $dll
    if (-not (Test-Path $dllPath)) {
        $missingDlls += $dll
    }
}

if ($missingDlls.Count -gt 0) {
    Write-Host "[ERROR] Missing required DLL files:" -ForegroundColor Red
    foreach ($dll in $missingDlls) {
        Write-Host "   - $dll" -ForegroundColor Red
    }
    Write-Host "`nPlease run: scripts\install_openvino_runtime.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] All critical DLL files present" -ForegroundColor Green

# 5. Check model path
Write-Host "Checking model path..." -ForegroundColor Yellow
if (-not (Test-Path $Model)) {
    Write-Host "[ERROR] Model path does not exist: $Model" -ForegroundColor Red
    Write-Host "   Please ensure model is downloaded or specify correct path with -Model parameter" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Model path exists: $Model" -ForegroundColor Green

# ============================================================================
# Display test configuration
# ============================================================================

Write-Host "`n=== Test Configuration ===" -ForegroundColor Cyan
Write-Host "Repository root: $repoRoot" -ForegroundColor White
Write-Host "Executable: $exePath" -ForegroundColor White
Write-Host "Runtime DLLs: $binPath" -ForegroundColor White
Write-Host "Model: $Model" -ForegroundColor White
Write-Host "Device: $Device" -ForegroundColor White
Write-Host "Prompt: $Prompt" -ForegroundColor White
Write-Host "Max tokens: $MaxTokens" -ForegroundColor White
Write-Host "Iterations: $NumIterations`n" -ForegroundColor White

# ============================================================================
# Set temporary PATH and execute benchmark
# ============================================================================

# 7. Set temporary PATH environment variable
$env:PATH = "$binPath;$env:PATH"
Write-Host "[OK] Temporary PATH configured`n" -ForegroundColor Green

# 8. Execute benchmark
Write-Host "=== Starting Benchmark ===" -ForegroundColor Cyan
Write-Host "Running, please wait...`n" -ForegroundColor Yellow

$startTime = Get-Date

# Build command arguments
$arguments = @(
    "--model", "`"$Model`"",
    "--device", $Device,
    "--prompt", "`"$Prompt`"",
    "--mt", $MaxTokens,
    "--num_iter", $NumIterations
)

# Execute command
& $exePath @arguments

$exitCode = $LASTEXITCODE
$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

# ============================================================================
# Display results
# ============================================================================

Write-Host "`n=== Execution Complete ===" -ForegroundColor Cyan
Write-Host "Total time: $($duration.ToString('F2')) seconds" -ForegroundColor White
Write-Host "Exit code: $exitCode" -ForegroundColor $(if ($exitCode -eq 0) { "Green" } else { "Red" })

if ($exitCode -eq 0) {
    Write-Host "`n[SUCCESS] Benchmark executed successfully!" -ForegroundColor Green
    Write-Host "You can now:" -ForegroundColor Cyan
    Write-Host "  - Run with GPU: .\scripts\run_benchmark_with_official_runtime.ps1 -Device GPU" -ForegroundColor White
    Write-Host "  - Increase tokens: .\scripts\run_benchmark_with_official_runtime.ps1 -MaxTokens 50" -ForegroundColor White
    Write-Host "  - Multiple runs: .\scripts\run_benchmark_with_official_runtime.ps1 -NumIterations 5" -ForegroundColor White
} else {
    Write-Host "`n[ERROR] Benchmark execution failed (exit code: $exitCode)" -ForegroundColor Red
    Write-Host "Please check error messages above" -ForegroundColor Yellow
    Write-Host "`nCommon issues:" -ForegroundColor Cyan
    Write-Host "  - Missing MSVC Runtime: Run scripts\install_msvc_runtime.ps1" -ForegroundColor White
    Write-Host "  - Missing DLLs: Run scripts\install_openvino_runtime.ps1" -ForegroundColor White
    Write-Host "  - GPU not available: Try -Device CPU instead" -ForegroundColor White
}

Write-Host "========================================`n" -ForegroundColor Cyan

exit $exitCode
