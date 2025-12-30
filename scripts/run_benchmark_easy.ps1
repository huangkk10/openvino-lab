# OpenVINO GenAI Benchmark Runner (Helper Script)
# Automatically handles paths and environment setup

param(
    [string]$Model = "./models/open_llama",
    [string]$Device = "CPU",
    [string]$Prompt = "The Sky is blue because",
    [int]$MaxTokens = 20,
    [int]$NumWarmup = 0,
    [int]$NumIter = 1
)

# Set base paths
$scriptDir = Split-Path -Parent $PSCommandPath
$repoRoot = Split-Path -Parent $scriptDir
$benchmarkExe = Join-Path $repoRoot "src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
$genaiDllDir = Join-Path $repoRoot "src\openvino.genai\build_cpp\openvino_genai"
$openvinoDllDir = "C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs"

# Check prerequisites
Write-Host "`n[*] Checking environment..." -ForegroundColor Cyan

if (-not (Test-Path $benchmarkExe)) {
    Write-Host "[!] ERROR: benchmark_genai.exe not found" -ForegroundColor Red
    Write-Host "    Expected at: $benchmarkExe" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] benchmark_genai.exe found" -ForegroundColor Green

$modelPath = if ([System.IO.Path]::IsPathRooted($Model)) { $Model } else { Join-Path $repoRoot $Model }
if (-not (Test-Path $modelPath)) {
    Write-Host "[!] ERROR: Model not found at: $modelPath" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Model found" -ForegroundColor Green

# Setup environment
Write-Host "`n[*] Setting up environment..." -ForegroundColor Cyan
$env:PATH = "$genaiDllDir;$openvinoDllDir;" + $env:PATH
Write-Host "[OK] PATH configured" -ForegroundColor Green

# Display parameters
Write-Host "`n[*] Benchmark Parameters:" -ForegroundColor Cyan
Write-Host "    Model: $modelPath"
Write-Host "    Device: $Device"
Write-Host "    Prompt: $Prompt"
Write-Host "    Max Tokens: $MaxTokens"
Write-Host "    Warmup Iterations: $NumWarmup"
Write-Host "    Test Iterations: $NumIter"
Write-Host ""

# Run benchmark
Write-Host "[*] Starting benchmark..." -ForegroundColor Cyan
Write-Host "    (Estimated time: ~$($($NumWarmup + $NumIter) * 30) seconds)`n" -ForegroundColor Yellow

& $benchmarkExe `
    -m $modelPath `
    -d $Device `
    -p $Prompt `
    --nw $NumWarmup `
    --mt $MaxTokens `
    -n $NumIter

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[OK] Benchmark completed successfully!" -ForegroundColor Green
} else {
    Write-Host "`n[!] Benchmark failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
