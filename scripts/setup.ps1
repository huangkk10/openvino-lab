# OpenVINO GenAI 自動化設置腳本
# Windows PowerShell

param(
    [switch]$SkipVenv = $false,
    [switch]$SkipInstall = $false
)

# 顏色輸出輔助函數
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

Write-Host "=" * 60
Write-Host "OpenVINO GenAI 自動化設置"
Write-Host "=" * 60 + "`n"

# 檢查 Python
Write-Info "檢查 Python 安裝..."
try {
    $pythonVersion = python --version 2>&1
    Write-Success "找到 Python: $pythonVersion"
} catch {
    Write-Error-Custom "Python 未找到。請先安裝 Python 3.10+"
    exit 1
}

# 檢查虛擬環境
if (-not $SkipVenv) {
    Write-Info "創建/檢查虛擬環境..."
    if (-not (Test-Path "venv")) {
        Write-Info "創建虛擬環境..."
        python -m venv venv
        Write-Success "虛擬環境已創建"
    } else {
        Write-Success "虛擬環境已存在"
    }
    
    # 啟動虛擬環境
    Write-Info "啟動虛擬環境..."
    & ".\venv\Scripts\Activate.ps1"
    Write-Success "虛擬環境已啟動"
}

# 安裝套件
if (-not $SkipInstall) {
    Write-Info "安裝 Python 套件..."
    Write-Info "注意：這可能需要幾分鐘...`n"
    
    pip install --upgrade pip
    Write-Success "pip 已更新"
    
    pip install openvino-genai optimum[openvino]
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "套件安裝完成"
    } else {
        Write-Error-Custom "套件安裝失敗"
        exit 1
    }
}

# 測試環境
Write-Info "測試環境..."
python scripts/test_openvino.py

if ($LASTEXITCODE -eq 0) {
    Write-Success "環境測試通過"
} else {
    Write-Error-Custom "環境測試失敗"
    Write-Info "請參考 docs/TROUBLESHOOTING.md"
    exit 1
}

Write-Host "`n" + "=" * 60
Write-Host "✅ 設置完成！" -ForegroundColor Green
Write-Host "=" * 60
Write-Host "`n快速開始："
Write-Host "1. 查看文檔："
Write-Host "   cat docs/README.md"
Write-Host "`n2. 下載模型："
Write-Host "   cat docs/MODELS.md"
Write-Host "`n3. 運行範例："
Write-Host "   python examples/simple_inference.py"
Write-Host "`n"
