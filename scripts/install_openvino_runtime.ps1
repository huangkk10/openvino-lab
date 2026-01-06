# OpenVINO GenAI Runtime One-Click Installation Script
# For quick deployment of OpenVINO GenAI C++ Runtime on a new computer
# Author: OpenVINO Lab Project
# Version: 1.0.0
# Date: 2026-01-05

<#
.SYNOPSIS
    Automatically download, verify, extract and deploy OpenVINO GenAI C++ Runtime

.DESCRIPTION
    This script automates the following steps:
    1. Create necessary directory structure
    2. Download official OpenVINO GenAI Runtime package
    3. Verify SHA256 checksum (optional)
    4. Extract package to specified directory
    5. Copy all necessary DLL and dependency files
    6. Validate installation integrity
    7. Generate installation report

.PARAMETER Version
    OpenVINO GenAI version number, default is 2025.4.1.0

.PARAMETER InstallRoot
    Installation root directory, defaults to openvino_cpp_runtime under script directory

.PARAMETER SkipDownload
    Skip download step (if file already exists)

.PARAMETER SkipHashCheck
    Skip SHA256 checksum verification

.PARAMETER ForceReinstall
    Force reinstallation (delete existing files)

.EXAMPLE
    .\install_openvino_runtime.ps1
    Install with default settings

.EXAMPLE
    .\install_openvino_runtime.ps1 -ForceReinstall
    Force reinstallation

.EXAMPLE
    .\install_openvino_runtime.ps1 -SkipHashCheck
    Skip checksum verification
#>

[CmdletBinding()]
param(
    [string]$Version = "2025.4.1.0",
    [string]$InstallRoot,
    [switch]$SkipDownload,
    [switch]$SkipHashCheck,
    [switch]$ForceReinstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Helper Functions
function Write-Header {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Message)
    Write-Host "[STEP] $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor White
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Initialize
Write-Header "OpenVINO GenAI Runtime One-Click Installer"
Write-Info "Version: $Version"
Write-Info "Start Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

if (-not $InstallRoot) {
    $InstallRoot = Join-Path (Split-Path -Parent $PSCommandPath) "openvino_cpp_runtime"
}

$zipFileName = "openvino_genai_windows_${Version}_x86_64.zip"
# Fix URL path: use major.minor.patch format (e.g., 2025.4.1) instead of full version
$versionPath = $Version -replace '(\d+\.\d+\.\d+).*', '$1'
$downloadUrl = "https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/$versionPath/windows/$zipFileName"
$sha256Url = "https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/$versionPath/windows/$zipFileName.sha256"

$downloadDir = Join-Path $InstallRoot "downloads"
$zipPath = Join-Path $downloadDir $zipFileName
$sha256Path = "$zipPath.sha256"
$extractDir = Join-Path $InstallRoot "openvino_genai_windows_${Version}_x86_64"
$binDir = Join-Path $InstallRoot "bin"
$libDir = Join-Path $InstallRoot "lib"
$sourceDllDir = Join-Path $extractDir "runtime\bin\intel64\Release"
$sourceLibDir = Join-Path $extractDir "runtime\lib\intel64\Release"

Write-Info "Install Directory: $InstallRoot"
Write-Info "Download URL: $downloadUrl"

# Step 1: Prepare Directory Structure
Write-Header "Step 1: Prepare Directory Structure"

if ($ForceReinstall -and (Test-Path $InstallRoot)) {
    Write-Warning "ForceReinstall detected, removing existing installation..."
    Remove-Item -Path $InstallRoot -Recurse -Force -ErrorAction SilentlyContinue
    Write-Success "Existing installation cleared"
}

Write-Step "Creating directories..."
$null = New-Item -ItemType Directory -Force -Path $InstallRoot
$null = New-Item -ItemType Directory -Force -Path $downloadDir
$null = New-Item -ItemType Directory -Force -Path $binDir
$null = New-Item -ItemType Directory -Force -Path $libDir

Write-Success "Directory structure ready"
Write-Info "  - Install Root: $InstallRoot"
Write-Info "  - Download Dir: $downloadDir"
Write-Info "  - Binary Dir: $binDir"
Write-Info "  - Library Dir: $libDir"

# Step 2: Download Package
Write-Header "Step 2: Download Official Package"

if (Test-Path $zipPath) {
    if ($SkipDownload) {
        Write-Info "Package exists, skipping download: $zipPath"
    } else {
        Write-Warning "Package exists, will re-download..."
        Remove-Item -Path $zipPath -Force
    }
}

if (-not (Test-Path $zipPath)) {
    Write-Step "Downloading OpenVINO GenAI Runtime..."
    Write-Info "Source: $downloadUrl"
    Write-Info "Target: $zipPath"
    Write-Info "File Size: ~168.5 MB, please wait..."
    
    try {
        $ProgressPreference = 'Continue'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
        
        $fileSize = (Get-Item $zipPath).Length / 1MB
        Write-Success "Download complete! File Size: $($fileSize.ToString('F2')) MB"
    } catch {
        Write-ErrorMsg "Download failed: $_"
        throw
    }
    
    if (-not $SkipHashCheck) {
        Write-Step "Downloading SHA256 checksum file..."
        try {
            Invoke-WebRequest -Uri $sha256Url -OutFile $sha256Path -UseBasicParsing -ErrorAction SilentlyContinue
            if (Test-Path $sha256Path) {
                Write-Success "SHA256 file downloaded"
            }
        } catch {
            Write-Warning "Cannot download SHA256 file, will skip verification"
        }
    }
} else {
    $fileSize = (Get-Item $zipPath).Length / 1MB
    Write-Success "Package exists: $($fileSize.ToString('F2')) MB"
}

# Step 3: Verify Integrity
Write-Header "Step 3: Verify File Integrity"

$calculatedHash = $null
if ($SkipHashCheck) {
    Write-Warning "Skipping SHA256 checksum verification (SkipHashCheck used)"
} else {
    Write-Step "Calculating file SHA256 checksum..."
    $calculatedHash = (Get-FileHash -Path $zipPath -Algorithm SHA256).Hash
    Write-Info "Calculated SHA256: $calculatedHash"
    
    $expectedHash = $null
    if (Test-Path $sha256Path) {
        $hashContent = Get-Content $sha256Path -Raw
        if ($hashContent -match '([a-fA-F0-9]{64})') {
            $expectedHash = $matches[1]
        }
    }
    
    if ($expectedHash) {
        Write-Info "Expected SHA256: $expectedHash"
        if ($calculatedHash.ToLower() -eq $expectedHash.ToLower()) {
            Write-Success "SHA256 checksum verified!"
        } else {
            Write-ErrorMsg "SHA256 checksum mismatch! File may be corrupted"
            throw "SHA256 verification failed"
        }
    } else {
        Write-Warning "Cannot get expected SHA256 value, skipping verification"
        Write-Info "You can manually verify SHA256: $calculatedHash"
    }
}

# Step 4: Extract Package
Write-Header "Step 4: Extract Official Package"

if (Test-Path $extractDir) {
    Write-Info "Extracted directory detected, will use existing files"
    Write-Info "Use -ForceReinstall to re-extract"
} else {
    Write-Step "Extracting package..."
    Write-Info "Source: $zipPath"
    Write-Info "Target: $InstallRoot"
    
    try {
        Expand-Archive -Path $zipPath -DestinationPath $InstallRoot -Force
        Write-Success "Extraction complete!"
    } catch {
        Write-ErrorMsg "Extraction failed: $_"
        throw
    }
}

if (-not (Test-Path $sourceDllDir)) {
    Write-ErrorMsg "DLL source directory not found: $sourceDllDir"
    throw "Extraction result incomplete"
}

Write-Success "Found DLL source directory: $sourceDllDir"

# Step 5: Copy Runtime Files
Write-Header "Step 5: Deploy Runtime Files"

Write-Step "Copying DLL and config files to bin directory..."

try {
    # Use -Recurse with -Include to search in subdirectories
    $dllFiles = Get-ChildItem -Path $sourceDllDir -Include *.dll, *.xml, *.json -File -Recurse
    $copiedCount = 0
    
    foreach ($file in $dllFiles) {
        Copy-Item -Path $file.FullName -Destination $binDir -Force
        $copiedCount++
    }
    
    Write-Success "Copied $copiedCount files to bin directory"
} catch {
    Write-ErrorMsg "Failed to copy DLL files: $_"
    throw
}

if (Test-Path $sourceLibDir) {
    Write-Step "Copying development library files..."
    try {
        $libFiles = Get-ChildItem -Path $sourceLibDir -Filter *.lib -File
        foreach ($file in $libFiles) {
            Copy-Item -Path $file.FullName -Destination $libDir -Force
        }
        Write-Success "Copied $($libFiles.Count) lib files"
    } catch {
        Write-Warning "Error copying lib files: $_"
    }
} else {
    Write-Warning "Lib directory not found, skipping library file copy"
}

# Step 6: Validate Installation
Write-Header "Step 6: Validate Installation Integrity"

Write-Step "Checking required runtime files..."

$coreDlls = @(
    "openvino_genai.dll",
    "openvino.dll",
    "openvino_tokenizers.dll",
    "openvino_intel_cpu_plugin.dll"
)

$recommendedDlls = @(
    "openvino_ir_frontend.dll",
    "openvino_onnx_frontend.dll",
    "openvino_paddle_frontend.dll",
    "openvino_pytorch_frontend.dll",
    "openvino_tensorflow_frontend.dll",
    "openvino_tensorflow_lite_frontend.dll",
    "openvino_intel_gpu_plugin.dll",
    "openvino_intel_npu_plugin.dll",
    "icudt70.dll",
    "icuuc70.dll",
    "tbb12.dll",
    "tbbbind_2_5.dll",
    "tbbmalloc.dll"
)

$missingCore = @()
Write-Info "Checking core DLLs..."
foreach ($dll in $coreDlls) {
    $path = Join-Path $binDir $dll
    if (Test-Path $path) {
        $size = (Get-Item $path).Length / 1MB
        $sizeStr = $size.ToString('F2')
        $msg = "  [OK] $dll (" + $sizeStr + " MB)"
        Write-Host $msg -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $dll" -ForegroundColor Red
        $missingCore += $dll
    }
}

if ($missingCore.Count -gt 0) {
    Write-ErrorMsg "Missing core DLLs: $($missingCore -join ', ')"
    throw "Installation validation failed: missing required files"
}

Write-Success "All core DLLs are ready!"

$missingRecommended = @()
Write-Info "Checking recommended DLLs..."
foreach ($dll in $recommendedDlls) {
    $path = Join-Path $binDir $dll
    if (Test-Path $path) {
        $size = (Get-Item $path).Length / 1MB
        $sizeStr = $size.ToString('F2')
        $msg = "  [OK] $dll (" + $sizeStr + " MB)"
        Write-Host $msg -ForegroundColor Green
    } else {
        Write-Host "  [WARN] $dll (not installed)" -ForegroundColor Yellow
        $missingRecommended += $dll
    }
}

if ($missingRecommended.Count -gt 0) {
    Write-Warning "Missing $($missingRecommended.Count) recommended DLLs, but basic functionality is not affected"
}

$allBinFiles = Get-ChildItem -Path $binDir -File
Write-Info "Total files in bin directory: $($allBinFiles.Count)"

# Step 7: Generate Installation Report
Write-Header "Step 7: Generate Installation Report"

$reportPath = Join-Path $InstallRoot "INSTALLATION_REPORT.md"
$installDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$fileSize = ((Get-Item $zipPath).Length / 1MB).ToString('F2')
$sha256Info = if ($calculatedHash) { $calculatedHash } else { "Skipped" }

# Build report content
$report = "# OpenVINO GenAI Runtime Installation Report`n`n"
$report += "**Installation Date:** $installDate`n"
$report += "**Version:** $Version`n"
$report += "**Install Directory:** $InstallRoot`n`n"
$report += "---`n`n"
$report += "## Installation Summary`n`n"
$report += "- **Downloaded File:** $zipFileName`n"
$report += "- **File Size:** $fileSize MB`n"
$report += "- **SHA256:** $sha256Info`n"
$report += "- **Status:** SUCCESS`n`n"
$report += "---`n`n"
$report += "## Directory Structure`n`n"
$report += "``````n"
$report += "$InstallRoot`n"
$report += "+-- bin\                    (Runtime DLLs and config)`n"
$report += "+-- lib\                    (Development libraries)`n"
$report += "+-- downloads\              (Downloaded archives)`n"
$report += "+-- openvino_genai_windows_${Version}_x86_64\  (Extracted content)`n"
$report += "``````n`n"
$report += "---`n`n"
$report += "## Installed Files`n`n"
$report += "### Core DLLs ($($coreDlls.Count) files)`n`n"

foreach ($dll in $coreDlls) {
    $path = Join-Path $binDir $dll
    if (Test-Path $path) {
        $size = ((Get-Item $path).Length / 1MB).ToString('F2')
        $report += "- [OK] ``$dll`` ($size MB)`n"
    } else {
        $report += "- [MISSING] ``$dll```n"
    }
}

$report += "`n### Recommended DLLs ($($recommendedDlls.Count) files)`n`n"

foreach ($dll in $recommendedDlls) {
    $path = Join-Path $binDir $dll
    if (Test-Path $path) {
        $size = ((Get-Item $path).Length / 1MB).ToString('F2')
        $report += "- [OK] ``$dll`` ($size MB)`n"
    } else {
        $report += "- [WARN] ``$dll`` (not installed)`n"
    }
}

$report += "`n### Total`n`n"
$report += "- Total files in bin: $($allBinFiles.Count)`n`n"
$report += "---`n`n"
$report += "## Validation Results`n`n"
$report += "- **Core DLLs:** $($coreDlls.Count - $missingCore.Count) / $($coreDlls.Count)`n"
$report += "- **Recommended DLLs:** $($recommendedDlls.Count - $missingRecommended.Count) / $($recommendedDlls.Count)`n"

if ($missingRecommended.Count -gt 0) {
    $report += "- **Missing Recommended:** $($missingRecommended -join ', ')`n"
}

$report += "`n---`n`n"
$report += "## Next Steps`n`n"
$report += "1. Review this installation report`n"
$report += "2. Run run_benchmark_with_official_runtime.ps1 to test`n"
$report += "3. Refer to docs/benchmark for more information`n`n"
$report += "---`n`n"
$report += "**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$report += "**Script Version:** 1.0.0`n"

$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Success "Installation report generated: $reportPath"

# Complete
Write-Header "Installation Complete!"

Write-Success "OpenVINO GenAI Runtime installed successfully!"
Write-Info ""
Write-Info "Install Directory: $InstallRoot"
Write-Info "Binary Directory: $binDir"
Write-Info "Installation Report: $reportPath"
Write-Info ""
Write-Info "Next Steps:"
Write-Info "  1. Review the installation report"
Write-Info "  2. Run run_benchmark_with_official_runtime.ps1 to test"
Write-Info "  3. Refer to docs/benchmark for documentation"
Write-Info ""
Write-Info "Completed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

exit 0
