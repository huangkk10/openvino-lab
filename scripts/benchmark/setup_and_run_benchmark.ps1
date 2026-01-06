# ============================================================
# One-Click Setup & Run Benchmark
# 一鍵設定環境變數 + 執行 Benchmark
# ============================================================
# 
# 用法：
#   .\setup_and_run_benchmark.ps1          # 使用預設參數
#   .\setup_and_run_benchmark.ps1 -SkipSetup  # 跳過環境變數設定
#   .\setup_and_run_benchmark.ps1 -MaxTokens 50 -NumIter 3
#
# ============================================================

param(
    [switch]$SkipSetup = $false,
    [string]$Device = "GPU",
    [string]$Model = ".\models\open_llama_7b_v2-int4-ov",
    [string]$Prompt = "The Sky is blue because",
    [int]$Warmup = 0,
    [int]$NumIter = 1,
    [int]$MaxTokens = 20,
    [string]$CacheDir = ".\.ccache"
)

# ============================================================
# 顏色定義
# ============================================================
$colors = @{
    "success" = "Green"
    "warning" = "Yellow"
    "error"   = "Red"
    "info"    = "Cyan"
    "section" = "Magenta"
}

# ============================================================
# 函數：打印帶格式的信息
# ============================================================
function Print-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $colors["section"]
    Write-Host "║  $($Text.PadRight(56))║" -ForegroundColor $colors["section"]
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $colors["section"]
}

function Print-Step {
    param([string]$Number, [string]$Text)
    Write-Host "[$Number] $Text" -ForegroundColor $colors["info"]
}

function Print-Success {
    param([string]$Text)
    Write-Host "✅ $Text" -ForegroundColor $colors["success"]
}

function Print-Warning {
    param([string]$Text)
    Write-Host "⚠️  $Text" -ForegroundColor $colors["warning"]
}

function Print-Error {
    param([string]$Text)
    Write-Host "❌ $Text" -ForegroundColor $colors["error"]
}

# ============================================================
# 檢查管理員權限（設定環境變數時需要）
# ============================================================
function Check-AdminPrivilege {
    $isAdmin = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544'
    return $isAdmin
}

# ============================================================
# 步驟 1：檢查環境
# ============================================================
Print-Header "一鍵 Benchmark 設定與執行"

Print-Step "1" "檢查系統環境"

# 取得專案根目錄（從 scripts/benchmark 向上兩層）
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
Set-Location $projectRoot
Write-Host "   工作目錄: $projectRoot" -ForegroundColor Gray

# 檢查必要檔案
$benchmarkExe = ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe"
$openvinoPath = ".\nvme_dsm_test\openvino_cpp_runtime\bin"
$modelPath = $Model

if (!(Test-Path $benchmarkExe)) {
    Print-Error "找不到 benchmark 執行檔: $benchmarkExe"
    exit 1
}
Print-Success "找到 benchmark 執行檔"

if (!(Test-Path $modelPath)) {
    Print-Error "找不到模型路徑: $modelPath"
    exit 1
}
Print-Success "找到模型路徑"

if (!(Test-Path $openvinoPath)) {
    Print-Error "找不到 OpenVINO runtime: $openvinoPath"
    exit 1
}
Print-Success "找到 OpenVINO runtime"

# ============================================================
# 步驟 2：設定環境變數
# ============================================================
if (!$SkipSetup) {
    Print-Step "2" "設定 OpenVINO PATH 環境變數"
    
    $isAdmin = Check-AdminPrivilege
    
    if (!$isAdmin) {
        Print-Warning "目前 PowerShell 未以管理員身份執行"
        Write-Host "   將嘗試臨時設定 PATH (僅此會話有效)" -ForegroundColor Gray
        $tempOnly = $true
    } else {
        Write-Host "   檢查是否已設定永久環境變數..." -ForegroundColor Gray
        $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
        
        if ($currentPath -like '*openvino_cpp_runtime*') {
            Print-Warning "OpenVINO PATH 已存在於永久環境變數"
        } else {
            Write-Host "   正在添加永久環境變數..." -ForegroundColor Gray
            $absoluteOpenvinoPath = Convert-Path $openvinoPath
            try {
                [Environment]::SetEnvironmentVariable(
                    'PATH',
                    $absoluteOpenvinoPath + ';' + $currentPath,
                    'User'
                )
                Print-Success "永久 PATH 設定完成"
                $tempOnly = $false
            } catch {
                Print-Warning "永久環境變數設定失敗，將使用臨時設定"
                $tempOnly = $true
            }
        }
    }
    
    # 臨時設定（當前會話）
    Write-Host "   設定當前會話的 PATH..." -ForegroundColor Gray
    $absoluteOpenvinoPath = Convert-Path $openvinoPath
    $env:PATH = $absoluteOpenvinoPath + ";" + $env:PATH
    Print-Success "會話 PATH 設定完成"
    
} else {
    Print-Step "2" "跳過環境變數設定（使用 -SkipSetup 參數）"
}

# ============================================================
# 步驟 3：驗證環境
# ============================================================
Print-Step "3" "驗證 OpenVINO 可用性"

$helpOutput = & $benchmarkExe --help 2>&1
if ($LASTEXITCODE -eq 0) {
    Print-Success "benchmark 執行檔驗證成功"
} else {
    Print-Error "benchmark 執行檔驗證失敗 (Exit Code: $LASTEXITCODE)"
    Write-Host "可能原因："
    Write-Host "  1. OpenVINO DLL 仍未找到 (請重新啟動 PowerShell)"
    Write-Host "  2. 缺少其他相依程式"
    Write-Host "  3. GPU 驅動程式問題"
    exit 1
}

# ============================================================
# 步驟 4：執行 Benchmark
# ============================================================
Print-Header "執行 Benchmark"

Write-Host "參數設定：" -ForegroundColor $colors["info"]
Write-Host "  Model:        $Model" -ForegroundColor Gray
Write-Host "  Device:       $Device" -ForegroundColor Gray
Write-Host "  Prompt:       $Prompt" -ForegroundColor Gray
Write-Host "  Warmup:       $Warmup" -ForegroundColor Gray
Write-Host "  Iterations:   $NumIter" -ForegroundColor Gray
Write-Host "  Max Tokens:   $MaxTokens" -ForegroundColor Gray
Write-Host "  Cache Dir:    $CacheDir" -ForegroundColor Gray
Write-Host ""

Write-Host "正在執行 benchmark..." -ForegroundColor $colors["info"]
Write-Host ""

$startTime = Get-Date
& $benchmarkExe `
    -m $Model `
    -d $Device `
    -p $Prompt `
    --nw $Warmup `
    -n $NumIter `
    --mt $MaxTokens `
    --cache_dir $CacheDir

$exitCode = $LASTEXITCODE
$endTime = Get-Date
$duration = $endTime - $startTime

# ============================================================
# 步驟 5：輸出結果
# ============================================================
Write-Host ""
Print-Header "執行結果"

if ($exitCode -eq 0) {
    Print-Success "Benchmark 執行完成"
    Write-Host "執行時間: $($duration.TotalSeconds.ToString('F2')) 秒" -ForegroundColor Gray
} else {
    Print-Error "Benchmark 執行失敗 (Exit Code: $exitCode)"
}

Write-Host ""
Write-Host "提示：" -ForegroundColor $colors["info"]
Write-Host "  • 結果已保存到終端機輸出" -ForegroundColor Gray
if ($tempOnly) {
    Write-Host "  • 當前 PATH 設定為臨時有效 (僅此會話)" -ForegroundColor Gray
    Write-Host "  • 建議以管理員身份重新執行以設定永久環境變數" -ForegroundColor Gray
} else {
    Write-Host "  • OpenVINO PATH 已永久設定，重新啟動 PowerShell 後自動生效" -ForegroundColor Gray
}
Write-Host ""

exit $exitCode
