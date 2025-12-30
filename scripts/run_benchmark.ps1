# OpenVINO GenAI Benchmark 互動式執行腳本
# 提供友好的菜單介面運行 benchmark

param(
    [Parameter(Mandatory=$false)]
    [string]$ModelPath,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("CPU", "GPU", "NPU")]
    [string]$Device = "GPU",
    
    [Parameter(Mandatory=$false)]
    [string]$Prompt,
    
    [Parameter(Mandatory=$false)]
    [int]$MaxTokens = 20,
    
    [Parameter(Mandatory=$false)]
    [int]$NumWarmup = 0,
    
    [Parameter(Mandatory=$false)]
    [int]$NumIter = 1
)

# ==================== 設定 ====================

$ErrorActionPreference = "Stop"
$Colors = @{
    Success = 'Green'
    Error   = 'Red'
    Warning = 'Yellow'
    Info    = 'Cyan'
}

function Write-Status {
    param([string]$Message, [string]$Type = 'Info')
    Write-Host "[$Type] $Message" -ForegroundColor $Colors[$Type]
}

function Write-Banner {
    param([string]$Title)
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  $($Title.PadRight(56))  ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# ==================== 函數 ====================

function Find-BenchmarkExe {
    $possiblePaths = @(
        ".\src\openvino.genai\samples\cpp\text_generation\build\Release\benchmark_genai.exe",
        ".\benchmark_genai.exe",
        ".\build\Release\benchmark_genai.exe"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            return (Resolve-Path $path).Path
        }
    }
    
    return $null
}

function Get-AvailableModels {
    $modelsDir = ".\models"
    if (-not (Test-Path $modelsDir)) {
        return @()
    }
    
    $models = Get-ChildItem -Path $modelsDir -Directory | Where-Object {
        Test-Path (Join-Path $_.FullName "openvino_model.xml")
    }
    
    return $models
}

function Show-ModelMenu {
    $models = Get-AvailableModels
    
    if ($models.Count -eq 0) {
        Write-Status "未找到已下載的模型" Warning
        Write-Host ""
        Write-Status "請先執行 Stage 8 下載模型：" Info
        Write-Host "  python scripts/download_hf_model.py --repo-id 'OpenVINO/open_llama_7b_v2-int4-ov'" -ForegroundColor Yellow
        return $null
    }
    
    Write-Status "可用模型列表：" Info
    Write-Host ""
    
    for ($i = 0; $i -lt $models.Count; $i++) {
        $index = $i + 1
        $name = $models[$i].Name
        $size = (Get-ChildItem -Path $models[$i].FullName -Recurse | Measure-Object -Property Length -Sum).Sum
        $sizeGB = [math]::Round($size / 1GB, 2)
        Write-Host "  $index) $name" -ForegroundColor Yellow
        Write-Host "     大小: $sizeGB GB" -ForegroundColor DarkGray
        Write-Host ""
    }
    
    $choice = Read-Host "請選擇模型（輸入編號 1-$($models.Count)，或按 Q 取消）"
    
    if ($choice -eq 'Q' -or $choice -eq 'q') {
        return $null
    }
    
    $selectedIndex = [int]$choice - 1
    if ($selectedIndex -ge 0 -and $selectedIndex -lt $models.Count) {
        return $models[$selectedIndex].FullName
    }
    
    Write-Status "無效選擇" Error
    return $null
}

function Show-DeviceMenu {
    Write-Host ""
    Write-Status "選擇推理設備：" Info
    Write-Host ""
    Write-Host "  1) CPU" -ForegroundColor Yellow
    Write-Host "  2) GPU（推薦，如果有 NVIDIA GPU）" -ForegroundColor Yellow
    Write-Host "  3) NPU（如果有 Intel NPU）" -ForegroundColor Yellow
    Write-Host ""
    
    $choice = Read-Host "請選擇設備（1-3，預設 2）"
    
    switch ($choice) {
        "1" { return "CPU" }
        "3" { return "NPU" }
        default { return "GPU" }
    }
}

function Get-Prompt {
    Write-Host ""
    Write-Status "輸入測試提示詞：" Info
    Write-Host ""
    Write-Host "  預設：'The Sky is blue because'" -ForegroundColor DarkGray
    Write-Host ""
    
    $input = Read-Host "提示詞（直接按 Enter 使用預設）"
    
    if ([string]::IsNullOrWhiteSpace($input)) {
        return "The Sky is blue because"
    }
    
    return $input
}

function Get-Parameters {
    Write-Host ""
    Write-Status "設定 Benchmark 參數：" Info
    Write-Host ""
    
    $maxTokens = Read-Host "最大生成令牌數（預設 20）"
    if ([string]::IsNullOrWhiteSpace($maxTokens)) {
        $maxTokens = 20
    }
    
    $numWarmup = Read-Host "預熱次數（預設 0）"
    if ([string]::IsNullOrWhiteSpace($numWarmup)) {
        $numWarmup = 0
    }
    
    $numIter = Read-Host "測試迭代次數（預設 1）"
    if ([string]::IsNullOrWhiteSpace($numIter)) {
        $numIter = 1
    }
    
    return @{
        MaxTokens = [int]$maxTokens
        NumWarmup = [int]$numWarmup
        NumIter = [int]$numIter
    }
}

# ==================== 主程序 ====================

Write-Banner "OpenVINO GenAI Benchmark 互動式執行"

# 檢查虛擬環境
if (-not (Test-Path 'env:\VIRTUAL_ENV')) {
    Write-Status "虛擬環境未激活，正在激活..." Warning
    $ProjectRoot = Split-Path -Parent -Path $PSScriptRoot
    & (Join-Path $ProjectRoot "venv\Scripts\Activate.ps1")
}

# 查找 benchmark 可執行文件
$benchmarkExe = Find-BenchmarkExe

if (-not $benchmarkExe) {
    Write-Status "未找到 benchmark_genai.exe" Error
    Write-Host ""
    Write-Status "請執行以下操作之一：" Info
    Write-Host "  1. 使用 Python 包裝腳本自動設置：" -ForegroundColor Yellow
    Write-Host "     python scripts/run_benchmark.py --model 'path' --auto-setup" -ForegroundColor Green
    Write-Host ""
    Write-Host "  2. 手動編譯（詳見 docs/setup/STAGE_9_GUIDE.md）" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Status "找到 benchmark 可執行文件：$benchmarkExe" Success
Write-Host ""

# 互動式選擇或使用參數
if (-not $ModelPath) {
    $ModelPath = Show-ModelMenu
    if (-not $ModelPath) {
        Write-Status "已取消" Warning
        exit 0
    }
}

if (-not $Device) {
    $Device = Show-DeviceMenu
}

if (-not $Prompt) {
    $Prompt = Get-Prompt
}

$params = @{
    MaxTokens = $MaxTokens
    NumWarmup = $NumWarmup
    NumIter = $NumIter
}

if ($MaxTokens -eq 20) {
    $inputParams = Get-Parameters
    $params = $inputParams
}

# 顯示配置摘要
Write-Host ""
Write-Status "執行配置：" Info
Write-Host "  模型：$ModelPath" -ForegroundColor Cyan
Write-Host "  設備：$Device" -ForegroundColor Cyan
Write-Host "  提示詞：$Prompt" -ForegroundColor Cyan
Write-Host "  最大令牌數：$($params.MaxTokens)" -ForegroundColor Cyan
Write-Host "  預熱次數：$($params.NumWarmup)" -ForegroundColor Cyan
Write-Host "  迭代次數：$($params.NumIter)" -ForegroundColor Cyan
Write-Host ""

$confirm = Read-Host "確認執行？(Y/n)"
if ($confirm -eq 'n' -or $confirm -eq 'N') {
    Write-Status "已取消" Warning
    exit 0
}

# 執行 benchmark
Write-Host ""
Write-Status "開始執行 Benchmark..." Info
Write-Host ""

try {
    & $benchmarkExe `
        -m "$ModelPath" `
        -d $Device `
        -p "$Prompt" `
        -mt $params.MaxTokens `
        -nw $params.NumWarmup `
        -n $params.NumIter
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Status "Benchmark 完成！" Success
    } else {
        Write-Host ""
        Write-Status "Benchmark 失敗（退出碼：$LASTEXITCODE）" Error
    }
} catch {
    Write-Status "執行錯誤：$_" Error
    exit 1
}

Write-Host ""
Write-Status "操作完成" Success
Write-Host ""
