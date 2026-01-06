# Microsoft Visual C++ Runtime Installation Script
# Ensures that the MSVC Runtime required by benchmark_genai.exe is installed
# Author: OpenVINO Lab Project
# Version: 1.0.0
# Date: 2026-01-06

<#
.SYNOPSIS
    Install Microsoft Visual C++ 2015-2022 Redistributable (x64)

.DESCRIPTION
    This script checks if Visual C++ Runtime is installed and installs it if missing.
    The runtime is required for benchmark_genai.exe and other C++ compiled programs.
    
.PARAMETER Force
    Force reinstallation even if runtime is detected

.PARAMETER Silent
    Silent installation without user prompts

.EXAMPLE
    .\install_msvc_runtime.ps1
    Check and install if needed

.EXAMPLE
    .\install_msvc_runtime.ps1 -Force
    Force reinstall runtime

.EXAMPLE
    .\install_msvc_runtime.ps1 -Silent
    Silent installation
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$Silent
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

# Main Script
Write-Header "Microsoft Visual C++ Runtime Installer"
Write-Info "Target: Visual C++ 2015-2022 Redistributable (x64)"
Write-Info "Start Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Info ""

# Check current installation
Write-Step "Checking current installation..."

$vcRuntimeFound = $false
$vcRuntimePaths = @()

$systemPaths = @(
    "$env:SystemRoot\System32",
    "$env:SystemRoot\SysWOW64"
)

$requiredDlls = @(
    "vcruntime140.dll",
    "vcruntime140_1.dll",
    "msvcp140.dll"
)

Write-Info "Scanning system directories..."
foreach ($path in $systemPaths) {
    foreach ($dll in $requiredDlls) {
        $dllPath = Join-Path $path $dll
        if (Test-Path $dllPath) {
            $fileInfo = Get-Item $dllPath
            $vcRuntimePaths += "$dll found in $path ($([math]::Round($fileInfo.Length/1KB, 2)) KB)"
        }
    }
}

if ($vcRuntimePaths.Count -ge 2) {
    $vcRuntimeFound = $true
}

Write-Info ""
if ($vcRuntimeFound) {
    Write-Success "Visual C++ Runtime is installed"
    Write-Info ""
    Write-Info "Found files:"
    foreach ($path in $vcRuntimePaths) {
        Write-Info "  - $path"
    }
    Write-Info ""
    
    if (-not $Force) {
        Write-Info "No action needed. Use -Force to reinstall."
        Write-Info ""
        exit 0
    } else {
        Write-Warning "Force reinstall requested"
        Write-Info ""
    }
} else {
    Write-Warning "Visual C++ Runtime not detected or incomplete"
    Write-Info "Found files:"
    if ($vcRuntimePaths.Count -eq 0) {
        Write-Info "  (none)"
    } else {
        foreach ($path in $vcRuntimePaths) {
            Write-Info "  - $path"
        }
    }
    Write-Info ""
}

# Download and Install
Write-Step "Preparing installation..."

$vcRedistUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vcRedistPath = Join-Path $env:TEMP "vc_redist.x64.exe"

Write-Info "Download URL: $vcRedistUrl"
Write-Info "Temp Path: $vcRedistPath"
Write-Info ""

# Confirm if not silent
if (-not $Silent -and -not $Force) {
    Write-Host "This will download and install Microsoft Visual C++ 2015-2022 Redistributable (x64)"
    Write-Host "Size: ~14 MB, Installation time: ~1-2 minutes"
    Write-Host ""
    $response = Read-Host "Continue? (Y/N)"
    if ($response -ne 'Y' -and $response -ne 'y') {
        Write-Info "Installation cancelled"
        exit 0
    }
    Write-Host ""
}

# Download
Write-Step "Downloading Visual C++ Redistributable..."
Write-Info "This may take a moment depending on your internet speed..."

try {
    $ProgressPreference = 'Continue'
    Invoke-WebRequest -Uri $vcRedistUrl -OutFile $vcRedistPath -UseBasicParsing
    
    $fileSize = (Get-Item $vcRedistPath).Length / 1MB
    Write-Success "Downloaded successfully ($($fileSize.ToString('F2')) MB)"
} catch {
    Write-ErrorMsg "Download failed: $_"
    Write-Info ""
    Write-Info "Please manually download from:"
    Write-Info "  https://aka.ms/vs/17/release/vc_redist.x64.exe"
    Write-Info ""
    exit 1
}

# Install
Write-Info ""
Write-Step "Installing Visual C++ Runtime..."
Write-Info "Installation in progress, please wait..."
Write-Info ""

try {
    $installArgs = @("/install", "/quiet", "/norestart")
    $process = Start-Process -FilePath $vcRedistPath -ArgumentList $installArgs -Wait -PassThru -NoNewWindow
    
    Write-Info ""
    
    switch ($process.ExitCode) {
        0 {
            Write-Success "Installation completed successfully!"
        }
        3010 {
            Write-Success "Installation completed successfully!"
            Write-Warning "A system restart is recommended for changes to take full effect"
        }
        1638 {
            Write-Info "This product is already installed (exit code 1638)"
            Write-Success "Runtime is available"
        }
        5100 {
            Write-Warning "System requirements not met (exit code 5100)"
            Write-Info "Your system may not meet minimum requirements"
        }
        default {
            Write-Warning "Installation returned exit code: $($process.ExitCode)"
            Write-Info "This may be normal if the runtime was already installed"
            Write-Info "Common exit codes:"
            Write-Info "  0: Success"
            Write-Info "  1638: Already installed"
            Write-Info "  3010: Success, restart recommended"
        }
    }
} catch {
    Write-ErrorMsg "Installation failed: $_"
    Write-Info ""
    Write-Info "Please try manual installation:"
    Write-Info "  1. Download: https://aka.ms/vs/17/release/vc_redist.x64.exe"
    Write-Info "  2. Run the installer"
    Write-Info "  3. Follow on-screen instructions"
    Write-Info ""
    exit 1
} finally {
    # Cleanup
    if (Test-Path $vcRedistPath) {
        Remove-Item $vcRedistPath -ErrorAction SilentlyContinue
    }
}

# Verify Installation
Write-Info ""
Write-Step "Verifying installation..."

$vcRuntimePaths = @()
foreach ($path in $systemPaths) {
    foreach ($dll in $requiredDlls) {
        $dllPath = Join-Path $path $dll
        if (Test-Path $dllPath) {
            $fileInfo = Get-Item $dllPath
            $vcRuntimePaths += "$dll in $path ($([math]::Round($fileInfo.Length/1KB, 2)) KB)"
        }
    }
}

Write-Info ""
if ($vcRuntimePaths.Count -ge 2) {
    Write-Success "Verification passed!"
    Write-Info ""
    Write-Info "Installed components:"
    foreach ($path in $vcRuntimePaths) {
        Write-Info "  ✓ $path"
    }
} else {
    Write-Warning "Some components may not be detected immediately"
    Write-Info "Found:"
    if ($vcRuntimePaths.Count -eq 0) {
        Write-Info "  (components may be registered after restart)"
    } else {
        foreach ($path in $vcRuntimePaths) {
            Write-Info "  - $path"
        }
    }
    Write-Info ""
    Write-Info "If benchmark_genai.exe still fails, try:"
    Write-Info "  1. Restart PowerShell"
    Write-Info "  2. Restart your computer"
    Write-Info "  3. Run this script again with -Force"
}

# Summary
Write-Info ""
Write-Header "Installation Summary"
Write-Info "Status: Completed"
Write-Info "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Info "Exit Code: $($process.ExitCode)"
Write-Info ""

if ($process.ExitCode -eq 3010) {
    Write-Info "⚠️  IMPORTANT: System restart recommended"
    Write-Info ""
}

Write-Info "Next steps:"
Write-Info "  1. Close and reopen PowerShell"
Write-Info "  2. Run benchmark_genai.exe or benchmark scripts"
Write-Info "  3. If issues persist, restart your computer"
Write-Info ""

exit 0
