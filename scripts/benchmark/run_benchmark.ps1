# ============================================================
# Benchmark GenAI Runner with OpenVINO PATH Setup
# ============================================================

param(
    [string]$Model = ".\models\open_llama_7b_v2-int4-ov",
    [string]$Device = "GPU",
    [string]$Prompt = "The Sky is blue because",
    [int]$Warmup = 0,
    [int]$NumIter = 1,
    [int]$MaxTokens = 20,
    [string]$CacheDir = ".\.ccache"
)

# 取得專案根目錄（從 scripts/benchmark 向上兩層）
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
Set-Location $projectRoot

# Set OpenVINO runtime path
$openvinoPath = ".\nvme_dsm_test\openvino_cpp_runtime\bin"
if (-not (Test-Path $openvinoPath)) {
    Write-Host "❌ OpenVINO runtime path not found: $openvinoPath" -ForegroundColor Red
    exit 1
}

$env:PATH = (Convert-Path $openvinoPath) + ";" + $env:PATH
Write-Host "✅ OpenVINO PATH set" -ForegroundColor Green

# Verify benchmark executable exists
$benchmarkExe = ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe"
if (-not (Test-Path $benchmarkExe)) {
    Write-Host "❌ Benchmark executable not found: $benchmarkExe" -ForegroundColor Red
    exit 1
}

Write-Host "🚀 Starting benchmark..." -ForegroundColor Cyan
Write-Host "  Model: $Model"
Write-Host "  Device: $Device"
Write-Host "  Max Tokens: $MaxTokens"
Write-Host ""

# Run benchmark
& $benchmarkExe `
    -m $Model `
    -d $Device `
    -p $Prompt `
    --nw $Warmup `
    -n $NumIter `
    --mt $MaxTokens `
    --cache_dir $CacheDir

$exitCode = $LASTEXITCODE
if ($exitCode -eq 0) {
    Write-Host "`n✅ Benchmark completed successfully" -ForegroundColor Green
} else {
    Write-Host "`n❌ Benchmark failed with exit code: $exitCode" -ForegroundColor Red
}

exit $exitCode
