# run_benchmark_with_official_runtime.ps1
param(
    [string]$Model = "open_llama_7b_v2-int4-ov",
    [string]$Device = "CPU",
    [string]$Prompt = "The Sky is blue because",
    [int]$MaxTokens = 20,
    [int]$NumIterations = 1
)

$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Run benchmark_genai.exe" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$projectRoot = "C:\Users\svd\codes\openvino-lab"
$cppBinPath = "$projectRoot\nvme_dsm_test\openvino_cpp_runtime\bin"

if (-not (Test-Path $cppBinPath)) {
    Write-Host "Error: DLL directory not found" -ForegroundColor Red
    exit 1
}

Write-Host "Found C++ Runtime bin directory" -ForegroundColor Green
Write-Host "Path: $cppBinPath`n" -ForegroundColor Gray

$env:PATH = "$cppBinPath;$env:PATH"
Write-Host "Set temporary PATH`n" -ForegroundColor Green

$benchmarkExe = "$projectRoot\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe"
$modelPath = "$projectRoot\models\$Model"

if (-not (Test-Path $benchmarkExe)) {
    Write-Host "Error: benchmark_genai.exe not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $modelPath)) {
    Write-Host "Error: Model directory not found: $modelPath" -ForegroundColor Red
    exit 1
}

Write-Host "Executing benchmark...`n" -ForegroundColor Yellow
Write-Host "Model: $Model" -ForegroundColor Gray
Write-Host "Device: $Device" -ForegroundColor Gray
Write-Host "Prompt: $Prompt" -ForegroundColor Gray
Write-Host "Max Tokens: $MaxTokens`n" -ForegroundColor Gray

& $benchmarkExe -m $modelPath -d $Device -p $Prompt --nw 0 --mt $MaxTokens -n $NumIterations

$exitCode = $LASTEXITCODE

Write-Host "`n========================================" -ForegroundColor Cyan
if ($exitCode -eq 0) {
    Write-Host "SUCCESS! Exit Code: $exitCode" -ForegroundColor Green
} else {
    Write-Host "FAILED! Exit Code: $exitCode" -ForegroundColor Red
}
Write-Host "========================================`n" -ForegroundColor Cyan

exit $exitCode