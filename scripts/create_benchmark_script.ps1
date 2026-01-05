# Create Benchmark Script Tool
# Automatically generates run_benchmark_with_official_runtime.ps1 for Stage 4
# Author: OpenVINO Lab Project
# Version: 1.0.0
# Date: 2026-01-05

<#
.SYNOPSIS
    Automatically creates the benchmark execution script

.DESCRIPTION
    This script generates run_benchmark_with_official_runtime.ps1 with:
    - Automatic PATH configuration
    - DLL dependency checking
    - Parameterized execution
    - Error handling and validation

.PARAMETER TargetDir
    Target directory where the script will be created (default: nvme_dsm_test)

.PARAMETER Force
    Overwrite existing script if it exists

.EXAMPLE
    .\create_benchmark_script.ps1
    Create script with default settings

.EXAMPLE
    .\create_benchmark_script.ps1 -Force
    Overwrite existing script
#>

[CmdletBinding()]
param(
    [string]$TargetDir = "nvme_dsm_test",
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Helper Functions
function Write-Step {
    param([string]$Message)
    Write-Host "[STEP] $Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor White
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Create Benchmark Script Tool" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Resolve target directory
$scriptRoot = Split-Path -Parent $PSCommandPath
$projectRoot = Split-Path -Parent $scriptRoot
$targetPath = Join-Path $projectRoot $TargetDir
$scriptPath = Join-Path $targetPath "run_benchmark_with_official_runtime.ps1"

Write-Info "Target directory: $targetPath"
Write-Info "Script path: $scriptPath"

# Check if target directory exists
if (-not (Test-Path $targetPath)) {
    Write-Host "[ERROR] Target directory not found: $targetPath" -ForegroundColor Red
    exit 1
}

# Check if script already exists
if ((Test-Path $scriptPath) -and -not $Force) {
    Write-Host "[ERROR] Script already exists: $scriptPath" -ForegroundColor Red
    Write-Info "Use -Force to overwrite"
    exit 1
}

# Generate script content
Write-Step "Generating benchmark script content..."

$scriptContent = @'
<#
.SYNOPSIS
    Execute precompiled benchmark_genai.exe with official C++ Runtime
    
.DESCRIPTION
    This script automatically sets up environment and executes benchmark_genai.exe
    - Automatic temporary PATH setup (no system impact)
    - Check all necessary DLL dependencies
    - Support custom parameters
    - Clear error messages
    
.PARAMETER Model
    Model path (default: OpenLLaMA 7B INT4)
    
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
#>

param(
    [string]$Model = "C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov",
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

# 1. Define paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$binPath = Join-Path $scriptDir "openvino_cpp_runtime\bin"
$exePath = Join-Path $scriptDir "benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe"

# 2. Check executable
Write-Host "Checking benchmark_genai.exe..." -ForegroundColor Yellow
if (-not (Test-Path $exePath)) {
    Write-Host "[ERROR] Cannot find benchmark_genai.exe" -ForegroundColor Red
    Write-Host "   Expected path: $exePath" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] benchmark_genai.exe exists" -ForegroundColor Green

# 3. Check bin directory
Write-Host "Checking DLL directory..." -ForegroundColor Yellow
if (-not (Test-Path $binPath)) {
    Write-Host "[ERROR] Cannot find bin directory" -ForegroundColor Red
    Write-Host "   Expected path: $binPath" -ForegroundColor Red
    Write-Host "   Please complete Stage 1+2 first: run scripts\install_openvino_runtime.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] bin directory exists" -ForegroundColor Green

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
    Write-Host "   Please ensure model is downloaded or specify correct path" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Model path exists" -ForegroundColor Green

# 6. Display test configuration
Write-Host "`n=== Test Configuration ===" -ForegroundColor Cyan
Write-Host "Model: $Model" -ForegroundColor White
Write-Host "Device: $Device" -ForegroundColor White
Write-Host "Prompt: $Prompt" -ForegroundColor White
Write-Host "Max tokens: $MaxTokens" -ForegroundColor White
Write-Host "Iterations: $NumIterations`n" -ForegroundColor White

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
    "--max_new_tokens", $MaxTokens,
    "--num_iterations", $NumIterations
)

# Execute command
& $exePath @arguments

$exitCode = $LASTEXITCODE
$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

# 9. Display results
Write-Host "`n=== Execution Complete ===" -ForegroundColor Cyan
Write-Host "Total time: $($duration.ToString('F2')) seconds" -ForegroundColor White
Write-Host "Exit code: $exitCode" -ForegroundColor $(if ($exitCode -eq 0) { "Green" } else { "Red" })

if ($exitCode -eq 0) {
    Write-Host "`n[SUCCESS] Benchmark executed successfully!" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] Benchmark execution failed (exit code: $exitCode)" -ForegroundColor Red
    Write-Host "Please check error messages above" -ForegroundColor Yellow
}

Write-Host "========================================`n" -ForegroundColor Cyan

exit $exitCode
'@

# Write script file
Write-Step "Writing script file..."
$scriptContent | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

Write-Success "Benchmark script created successfully!"
Write-Info ""
Write-Info "Script location: $scriptPath"
Write-Info ""
Write-Info "Usage examples:"
Write-Info "  cd $TargetDir"
Write-Info "  .\run_benchmark_with_official_runtime.ps1              # CPU test"
Write-Info "  .\run_benchmark_with_official_runtime.ps1 -Device GPU   # GPU test"
Write-Info ""
Write-Host "========================================`n" -ForegroundColor Cyan

exit 0
