# OpenVINO GenAI Model Download Script
# Automates download of OpenLLaMA 7B v2 INT4 model for benchmark testing
# Version: 1.0.0
# Date: 2026-01-05

param(
    [string]$ModelName = "open_llama_7b_v2-int4-ov",
    [string]$TargetDir = "models",
    [switch]$Force
)

# UTF-8 encoding for console output
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenVINO Model Download Tool" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get workspace root
$workspaceRoot = Split-Path -Parent $PSScriptRoot
$modelPath = Join-Path $workspaceRoot $TargetDir
$targetModelPath = Join-Path $modelPath $ModelName

# Check if model already exists
if ((Test-Path $targetModelPath) -and -not $Force) {
    Write-Host "[INFO] Model already exists at: $targetModelPath" -ForegroundColor Yellow
    Write-Host "[INFO] Use -Force to re-download" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[OK] Model is ready for use" -ForegroundColor Green
    exit 0
}

Write-Host "[STEP 1/5] Checking requirements..." -ForegroundColor Cyan
Write-Host ""

# Check Python availability
$pythonCmd = $null
foreach ($cmd in @("python", "python3")) {
    try {
        $version = & $cmd --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $pythonCmd = $cmd
            Write-Host "  [OK] Found Python: $version" -ForegroundColor Green
            break
        }
    } catch {
        continue
    }
}

if (-not $pythonCmd) {
    Write-Host "  [ERROR] Python not found. Please install Python 3.8+" -ForegroundColor Red
    Write-Host ""
    Write-Host "Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}

# Check pip availability
try {
    $pipVersion = & $pythonCmd -m pip --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] pip is available" -ForegroundColor Green
    }
} catch {
    Write-Host "  [ERROR] pip not found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[STEP 2/5] Checking disk space..." -ForegroundColor Cyan
Write-Host ""

# Check available disk space
$drive = Split-Path -Qualifier $workspaceRoot
$disk = Get-PSDrive -Name $drive.TrimEnd(':')
$freeSpaceGB = [math]::Round($disk.Free / 1GB, 2)

Write-Host "  Available space on $drive : $freeSpaceGB GB" -ForegroundColor White

if ($freeSpaceGB -lt 10) {
    Write-Host "  [WARNING] Less than 10 GB free. Model requires ~4 GB" -ForegroundColor Yellow
    if ($freeSpaceGB -lt 5) {
        Write-Host "  [ERROR] Insufficient disk space" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  [OK] Sufficient disk space" -ForegroundColor Green
}

Write-Host ""
Write-Host "[STEP 3/5] Installing required packages..." -ForegroundColor Cyan
Write-Host ""

# Install required packages
$packages = @("huggingface-hub", "optimum-intel")
foreach ($pkg in $packages) {
    Write-Host "  Installing $pkg..." -ForegroundColor White
    try {
        & $pythonCmd -m pip install -q $pkg 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] $pkg installed" -ForegroundColor Green
        } else {
            Write-Host "  [WARNING] $pkg installation may have issues" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  [ERROR] Failed to install $pkg" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "[STEP 4/5] Downloading model..." -ForegroundColor Cyan
Write-Host ""
Write-Host "  Model: $ModelName" -ForegroundColor White
Write-Host "  Source: Hugging Face Hub" -ForegroundColor White
Write-Host "  Target: $targetModelPath" -ForegroundColor White
Write-Host ""

# Create target directory
if (-not (Test-Path $modelPath)) {
    New-Item -Path $modelPath -ItemType Directory -Force | Out-Null
}

# Download using Python script
$downloadScript = @"
import sys
from huggingface_hub import snapshot_download
from pathlib import Path

model_name = "$ModelName"
target_dir = r"$targetModelPath"

print(f"  Downloading {model_name}...")
print(f"  This may take several minutes (~4 GB)...")
print("")

try:
    snapshot_download(
        repo_id="openlm-research/open_llama_7b_v2_openvino_int4",
        local_dir=target_dir,
        local_dir_use_symlinks=False
    )
    print("")
    print("  [OK] Download complete")
    sys.exit(0)
except Exception as e:
    print("")
    print(f"  [ERROR] Download failed: {e}")
    sys.exit(1)
"@

$tempScript = Join-Path $env:TEMP "download_model_temp.py"
$downloadScript | Out-File -FilePath $tempScript -Encoding UTF8

try {
    & $pythonCmd $tempScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "[ERROR] Model download failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "[ERROR] Model download failed: $_" -ForegroundColor Red
    exit 1
} finally {
    Remove-Item $tempScript -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "[STEP 5/5] Verifying model files..." -ForegroundColor Cyan
Write-Host ""

# Verify essential files
$requiredFiles = @(
    "openvino_model.xml",
    "openvino_model.bin",
    "openvino_tokenizer.xml",
    "openvino_tokenizer.bin"
)

$allFound = $true
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $targetModelPath $file
    if (Test-Path $filePath) {
        $sizeKB = [math]::Round((Get-Item $filePath).Length / 1KB, 2)
        Write-Host "  [OK] $file ($sizeKB KB)" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $file" -ForegroundColor Red
        $allFound = $false
    }
}

Write-Host ""

if ($allFound) {
    # Calculate total size
    $totalSize = (Get-ChildItem $targetModelPath -Recurse | Measure-Object -Property Length -Sum).Sum
    $totalSizeGB = [math]::Round($totalSize / 1GB, 2)
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Model Download Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Model: $ModelName" -ForegroundColor White
    Write-Host "  Location: $targetModelPath" -ForegroundColor White
    Write-Host "  Total Size: $totalSizeGB GB" -ForegroundColor White
    Write-Host ""
    Write-Host "  The model is ready for benchmark testing." -ForegroundColor Green
    Write-Host ""
    exit 0
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  Model Verification Failed" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Some required files are missing." -ForegroundColor Yellow
    Write-Host "Please check the download or try again with -Force" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
