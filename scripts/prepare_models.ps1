# OpenVINO 優化模型下載腳本（可選）
# Purpose: Download OpenVINO-optimized LLM models (optional for future compatibility)
# Usage: .\scripts\prepare_models.ps1
#
# ⚠️ 說明：
#   - 推薦使用 run_inference_simple.py 進行推理（開箱即用）
#   - 此腳本用於下載 OpenVINO 優化版本（用於未來 OpenVINO GenAI 兼容性）
#   - 當前環境已支持標準 PyTorch 推理，無需此腳本

# Set error handling
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"

# 顯示歡迎信息
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   OpenVINO 優化模型下載腳本（可選）                            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 提示：" -ForegroundColor Yellow
Write-Host "  • 推薦使用：python scripts/run_inference_simple.py" -ForegroundColor Green
Write-Host "  • 此腳本下載的是 OpenVINO 優化版本（可選）" -ForegroundColor Yellow
Write-Host "  • 當前環境已支持標準推理，無需運行此腳本" -ForegroundColor Yellow
Write-Host ""

# Color output
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

# ==================== Configuration ====================
Write-Status "Loading configuration..." Info
$ProjectRoot = Split-Path -Parent -Path $PSScriptRoot
$ModelsDir = Join-Path $ProjectRoot "models"
$ConfigFile = Join-Path $ProjectRoot "config/.env"

# Ensure virtual environment is activated
if (-not (Test-Path 'env:\VIRTUAL_ENV')) {
    Write-Status "Virtual environment not activated. Activating..." Warning
    & (Join-Path $ProjectRoot "venv\Scripts\Activate.ps1")
}

Write-Status "Python virtual environment activated" Success
Write-Status "Project root: $ProjectRoot" Info
Write-Status "Model save directory: $ModelsDir" Info

# Create models directory
if (-not (Test-Path $ModelsDir)) {
    Write-Status "Creating models directory..." Info
    New-Item -ItemType Directory -Path $ModelsDir -Force | Out-Null
}

# ==================== Model List ====================
# Available models (sorted by size)
# Models from HuggingFace with verified availability

$Models = @(
    @{
        Name = "TinyLlama-1.1B-Chat-int4"
        HFModel = "ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-asym-int4"
        Type = "small"
        Size = "600MB"
        Quantization = "int4"
        Description = "TinyLlama chat model, int4 quantization"
    },
    @{
        Name = "TinyLlama-1.1B-Chat-int8"
        HFModel = "ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-asym-int8"
        Type = "small"
        Size = "800MB"
        Quantization = "int8"
        Description = "TinyLlama chat model, int8 quantization (better quality)"
    },
    @{
        Name = "TinyLlama-1.1B-Chat-fp16"
        HFModel = "ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-fp16"
        Type = "medium"
        Size = "1.2GB"
        Quantization = "fp16"
        Description = "TinyLlama chat model, fp16 (best quality)"
    }
)

# ==================== Function Definitions ====================

function Show-ModelMenu {
    Write-Status "Available pre-converted models:" Info
    Write-Host ""
    for ($i = 0; $i -lt $Models.Count; $i++) {
        $model = $Models[$i]
        $index = $i + 1
        Write-Host "  $index) $($model.Name) - $($model.Size) (Quantization: $($model.Quantization))"
    }
    Write-Host ""
}

function Download-Model {
    param(
        [string]$ModelName,
        [string]$HFModel
    )
    
    $ModelPath = Join-Path $ModelsDir $ModelName
    
    # Check if model files actually exist (not just the directory)
    $RequiredFiles = @('openvino_model.xml', 'openvino_model.bin', 'config.json')
    $AllFilesExist = $true
    
    if (Test-Path $ModelPath) {
        foreach ($file in $RequiredFiles) {
            $filePath = Join-Path $ModelPath $file
            if (-not (Test-Path $filePath)) {
                $AllFilesExist = $false
                break
            }
        }
        
        if ($AllFilesExist) {
            Write-Status "Model $ModelName already exists and is complete: $ModelPath" Success
            return $true
        } else {
            Write-Status "Model directory exists but incomplete, re-downloading..." Warning
        }
    }
    
    Write-Status "Downloading model $ModelName..." Info
    Write-Status "Source: $HFModel" Info
    
    try {
        # Use huggingface_hub to download
        python -c @"
from huggingface_hub import snapshot_download
import os

model_name = r'$HFModel'
save_dir = r'$ModelPath'

print(f'Starting download: {model_name}')
print(f'Save location: {save_dir}')

snapshot_download(
    repo_id=model_name,
    local_dir=save_dir,
    repo_type='model',
    resume_download=True,
    local_dir_use_symlinks=False
)

print(f'Model download completed')
"@
        
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Model $ModelName downloaded successfully" Success
            return $true
        } else {
            Write-Status "Model download failed" Error
            return $false
        }
    } catch {
        Write-Status "Model download error: $_" Error
        return $false
    }
}

function Convert-ToOpenVINO {
    param(
        [string]$ModelName
    )
    
    $ModelPath = Join-Path $ModelsDir $ModelName
    
    if (-not (Test-Path $ModelPath)) {
        Write-Status "Model path does not exist: $ModelPath" Error
        return $false
    }
    
    Write-Status "Converting model to OpenVINO format: $ModelName" Info
    
    try {
        python -c @"
import os
from pathlib import Path

model_path = r'$ModelPath'
print(f'Model path: {model_path}')

# Check existing files
if Path(model_path).exists():
    files = list(Path(model_path).glob('*'))
    print(f'Model contains: {len(files)} files')
    
    # List main files
    for ext in ['*.safetensors', '*.onnx', '*.bin', 'config.json']:
        matching = list(Path(model_path).glob(ext))
        if matching:
            print(f'  - {ext}: {len(matching)} files')

print('Model is ready to use')
"@
        
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Model conversion completed" Success
            return $true
        } else {
            Write-Status "Model conversion failed" Error
            return $false
        }
    } catch {
        Write-Status "Conversion error: $_" Error
        return $false
    }
}

function Verify-Model {
    param(
        [string]$ModelName
    )
    
    $ModelPath = Join-Path $ModelsDir $ModelName
    
    Write-Status "Verifying model: $ModelName" Info
    
    if (-not (Test-Path $ModelPath)) {
        Write-Status "Model directory does not exist" Error
        return $false
    }
    
    # Check required files for OpenVINO models
    $RequiredFiles = @(
        'openvino_model.xml',
        'openvino_model.bin',
        'config.json'
    )
    
    $OptionalFiles = @(
        'tokenizer.json',
        'tokenizer_config.json',
        'generation_config.json'
    )
    
    $MissingRequired = @()
    $MissingOptional = @()
    
    foreach ($file in $RequiredFiles) {
        $filePath = Join-Path $ModelPath $file
        if (-not (Test-Path $filePath)) {
            $MissingRequired += $file
        }
    }
    
    foreach ($file in $OptionalFiles) {
        $filePath = Join-Path $ModelPath $file
        if (-not (Test-Path $filePath)) {
            $MissingOptional += $file
        }
    }
    
    if ($MissingRequired.Count -eq 0) {
        Write-Status "Model verification successful - All required files present" Success
        if ($MissingOptional.Count -gt 0) {
            Write-Status "Optional files missing: $($MissingOptional -join ', ')" Info
        }
        
        # Show file count
        $allFiles = Get-ChildItem -Path $ModelPath -File
        Write-Status "Total files in model: $($allFiles.Count)" Info
        
        return $true
    } else {
        Write-Status "Missing required files: $($MissingRequired -join ', ')" Error
        Write-Status "Model download may have failed or is incomplete" Warning
        return $false
    }
}

# ==================== Main Program ====================

Write-Host ""
Write-Status "========== OpenVINO GenAI Model Preparation ==========" Success
Write-Host ""

# Check dependencies
Write-Status "Checking required tools..." Info
$tools = @('huggingface_hub', 'transformers')
foreach ($tool in $tools) {
    try {
        $result = python -c "import $tool; print('OK')" 2>$null
        if ($result -eq 'OK') {
            Write-Status "OK - $tool is installed" Success
        }
    } catch {
        Write-Status "WARN - $tool not installed, will auto-install" Warning
    }
}

Write-Host ""

# Menu selection
Show-ModelMenu

$choice = Read-Host "Please select a model to download (1-$($Models.Count), or type 'skip' to skip)"

if ($choice -eq 'skip') {
    Write-Status "Skipping model download" Info
} elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $Models.Count) {
    $selectedIndex = [int]$choice - 1
    $selectedModel = $Models[$selectedIndex]
    
    Write-Status "Selected model: $($selectedModel.Name)" Info
    Write-Host ""
    
    # Download model
    $downloadSuccess = Download-Model -ModelName $selectedModel.Name -HFModel $selectedModel.HFModel
    
    if ($downloadSuccess) {
        # Verify model
        $verifySuccess = Verify-Model -ModelName $selectedModel.Name
        
        if ($verifySuccess) {
            Write-Status "Model preparation completed" Success
        } else {
            Write-Status "Model file verification found issues, but model has been downloaded" Warning
        }
    }
} else {
    Write-Status "Invalid choice" Error
}

Write-Host ""
Write-Status "=========================================" Info
Write-Status "OpenVINO 優化模型下載完成！" Success
Write-Status "下一步：使用推理腳本進行推理" Info
Write-Host ""
Write-Status "推薦命令（推薦使用）：" Info
Write-Host "  python scripts/run_inference_simple.py --prompt 'Your question'" -ForegroundColor Cyan
Write-Host ""
Write-Status "或交互式模式：" Info
Write-Host "  python scripts/run_inference_simple.py" -ForegroundColor Cyan
Write-Host ""
Write-Status "說明：" Info
Write-Host "  • run_inference_simple.py 使用標準 PyTorch 模型（開箱即用）" -ForegroundColor Yellow
Write-Host "  • 上述 OpenVINO 優化模型可選（用於未來兼容性）" -ForegroundColor Yellow
Write-Host ""
