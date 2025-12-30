# 互動式模型下載包裝腳本
# 提供友好的菜單介面，調用 Python 下載腳本
# 支援常見的 OpenVINO 和 PyTorch 模型

param(
    [Parameter(Mandatory=$false)]
    [string]$RepoId,
    
    [Parameter(Mandatory=$false)]
    [string]$ModelName,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "./models"
)

# ==================== 設定 ====================

$ErrorActionPreference = "Stop"
$Colors = @{
    Success = 'Green'
    Error   = 'Red'
    Warning = 'Yellow'
    Info    = 'Cyan'
    Yellow  = 'Yellow'
}

function Write-Status {
    param([string]$Message, [string]$Type = 'Info')
    Write-Host "[$Type] $Message" -ForegroundColor $Colors[$Type]
}

# 檢查虛擬環境
if (-not (Test-Path 'env:\VIRTUAL_ENV')) {
    Write-Status "虛擬環境未激活，正在激活..." Warning
    $ProjectRoot = Split-Path -Parent -Path $PSScriptRoot
    & (Join-Path $ProjectRoot "venv\Scripts\Activate.ps1")
}

# ==================== 模型列表 ====================

$Models = @(
    @{
        Index = 1
        Name = "OpenLLaMA 7B (OpenVINO int4)"
        RepoId = "OpenVINO/open_llama_7b_v2-int4-ov"
        LocalName = "open_llama_7b_v2-int4"
        Size = "3.5GB"
        Type = "Large Language Model"
    },
    @{
        Index = 2
        Name = "TinyLlama 1.1B (OpenVINO int4)"
        RepoId = "ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-asym-int4"
        LocalName = "tinyllama-openvino-int4"
        Size = "600MB"
        Type = "Small Language Model"
    },
    @{
        Index = 3
        Name = "TinyLlama 1.1B (PyTorch)"
        RepoId = "TinyLlama/TinyLlama-1.1B-Chat-v1.0"
        LocalName = "tinyllama-pytorch"
        Size = "2.2GB"
        Type = "Small Language Model"
    },
    @{
        Index = 4
        Name = "Qwen 7B (OpenVINO)"
        RepoId = "OpenVINO/Qwen1.5-7B-Chat-int4-ov"
        LocalName = "qwen_7b_chat_int4"
        Size = "3.8GB"
        Type = "Large Language Model"
    },
    @{
        Index = 5
        Name = "自訂模型（手動輸入）"
        RepoId = "custom"
        LocalName = "custom"
        Size = "？"
        Type = "User Input"
    }
)

# ==================== 函數 ====================

function Show-Menu {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║        HuggingFace 模型下載工具 - 互動式菜單                 ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Status "可用模型列表：" Info
    Write-Host ""
    
    foreach ($model in $Models) {
        $index = $model.Index
        $name = $model.Name
        $size = $model.Size
        Write-Host "  $index) $name" -ForegroundColor Yellow
        Write-Host "     Size: $size | Type: $($model.Type)" -ForegroundColor DarkGray
        Write-Host ""
    }
}

function Download-SelectedModel {
    param(
        [string]$RepoId,
        [string]$ModelName,
        [string]$OutputDir
    )
    
    Write-Status "準備下載模型..." Info
    Write-Host "  Repository: $RepoId" -ForegroundColor DarkGray
    Write-Host "  Save to: $OutputDir" -ForegroundColor DarkGray
    Write-Host ""
    
    $command = @(
        "python",
        "scripts/download_hf_model.py",
        "--repo-id", "`"$RepoId`"",
        "--model-name", "`"$ModelName`"",
        "--output-dir", "`"$OutputDir`""
    )
    
    Write-Status "執行下載命令..." Info
    Write-Host ""
    
    # 執行下載
    & python scripts/download_hf_model.py `
        --repo-id "$RepoId" `
        --model-name "$ModelName" `
        --output-dir "$OutputDir"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Status "下載成功！" Success
        return $true
    } else {
        Write-Status "下載失敗，詳見上方錯誤信息" Error
        return $false
    }
}

# ==================== 主程序 ====================

Write-Host ""

if ($RepoId) {
    # 命令行模式 - 直接下載
    Write-Status "使用命令行參數進行下載" Info
    Download-SelectedModel -RepoId $RepoId -ModelName $ModelName -OutputDir $OutputDir
} else {
    # 互動式菜單
    Show-Menu
    
    $choice = Read-Host "請選擇要下載的模型（輸入編號 1-5，或按 Q 取消）"
    
    if ($choice -eq 'Q' -or $choice -eq 'q') {
        Write-Status "已取消" Warning
        exit
    }
    
    $selectedModel = $Models | Where-Object { $_.Index -eq [int]$choice } | Select-Object -First 1
    
    if (-not $selectedModel) {
        Write-Status "無效選擇" Error
        exit 1
    }
    
    if ($selectedModel.RepoId -eq "custom") {
        # 自訂模型
        Write-Host ""
        Write-Status "自訂模型模式" Info
        $customRepoId = Read-Host "請輸入 HuggingFace Repository ID（例如：OpenVINO/open_llama_7b_v2-int4-ov）"
        $customName = Read-Host "請輸入本地模型名稱（例如：my_model）"
        
        if (-not $customRepoId -or -not $customName) {
            Write-Status "輸入不完整，已取消" Error
            exit 1
        }
        
        Download-SelectedModel -RepoId $customRepoId -ModelName $customName -OutputDir $OutputDir
    } else {
        # 預設模型
        Write-Host ""
        Write-Status "已選擇：$($selectedModel.Name)" Success
        
        Download-SelectedModel `
            -RepoId $selectedModel.RepoId `
            -ModelName $selectedModel.LocalName `
            -OutputDir $OutputDir
    }
}

Write-Host ""
Write-Status "操作完成" Success
Write-Host ""
