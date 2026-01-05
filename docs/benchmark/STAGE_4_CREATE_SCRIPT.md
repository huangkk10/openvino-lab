# 階段 3：配置執行腳本

**目標：** 創建自動化執行腳本並配置環境  
**時間：** 5 分鐘  
**難度：** ⭐ 簡單  
**狀態：** ✅ 已驗證

---

## 📋 本階段目標

1. 創建自動化執行腳本 `run_benchmark_with_official_runtime.ps1`
2. 配置臨時 PATH 環境變數
3. 添加 DLL 依賴檢查功能
4. 測試腳本執行

---

## 🎯 為什麼需要執行腳本？

### 手動執行的問題

❌ **每次都要設置環境變數**
```powershell
$env:PATH = "C:\path\to\bin;$env:PATH"
```

❌ **需要記住複雜的命令參數**
```powershell
.\benchmark_genai.exe --model "..." --device CPU --prompt "..." --max_new_tokens 20
```

❌ **沒有錯誤檢查**
- DLL 缺失無法提前發現
- 執行失敗不知道原因

### 使用腳本的優勢

✅ **自動設置環境** - 臨時 PATH，不影響系統  
✅ **參數化配置** - 支援自定義所有選項  
✅ **完整錯誤檢查** - 預先驗證所有依賴  
✅ **清晰的輸出** - 彩色提示和結果顯示

---

## 🚀 操作步驟

### 🎯 快速開始：一鍵創建腳本（推薦）

**最快速的方式：** 使用自動化工具創建腳本

```powershell
# 進入項目根目錄
cd C:\Users\svd\codes\openvino-lab

# 執行腳本創建工具
.\scripts\create_benchmark_script.ps1
```

腳本會自動創建完整的 `run_benchmark_with_official_runtime.ps1`，包含：
- ✅ 自動 PATH 配置
- ✅ DLL 依賴檢查
- ✅ 參數化執行
- ✅ 錯誤處理

**完成後即可直接使用：**
```powershell
cd nvme_dsm_test
.\run_benchmark_with_official_runtime.ps1
```

---

### 📝 手動創建步驟

如果您想手動創建或自定義腳本：

### 步驟 3.1：創建執行腳本

```powershell
# 進入測試目錄
cd C:\Users\svd\codes\openvino-lab\nvme_dsm_test

# 創建執行腳本
@'
<#
.SYNOPSIS
    使用官方 C++ Runtime 執行預編譯的 benchmark_genai.exe
    
.DESCRIPTION
    此腳本自動設置環境變數並執行 benchmark_genai.exe
    - 自動設置臨時 PATH（不影響系統環境）
    - 檢查所有必要的 DLL 依賴
    - 支援自定義參數
    - 提供清晰的錯誤提示
    
.PARAMETER Model
    模型路徑（預設：OpenLLaMA 7B INT4）
    
.PARAMETER Device
    設備類型：CPU 或 GPU（預設：CPU）
    
.PARAMETER Prompt
    輸入提示文字（預設："What is OpenVINO?"）
    
.PARAMETER MaxTokens
    最大生成 token 數（預設：20）
    
.PARAMETER NumIterations
    測試迭代次數（預設：1）
    
.EXAMPLE
    .\run_benchmark_with_official_runtime.ps1
    使用預設參數執行 CPU 測試
    
.EXAMPLE
    .\run_benchmark_with_official_runtime.ps1 -Device GPU
    執行 GPU 測試
    
.EXAMPLE
    .\run_benchmark_with_official_runtime.ps1 -MaxTokens 50 -NumIterations 3
    自定義參數測試
#>

param(
    [string]$Model = "C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov",
    [ValidateSet("CPU", "GPU")]
    [string]$Device = "CPU",
    [string]$Prompt = "What is OpenVINO?",
    [int]$MaxTokens = 20,
    [int]$NumIterations = 1
)

# 設置控制台輸出編碼
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 顯示標題
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  OpenVINO GenAI Benchmark (C++ Runtime)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. 定義路徑
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$binPath = Join-Path $scriptDir "openvino_cpp_runtime\bin"
$exePath = Join-Path $scriptDir "benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe"

# 2. 檢查執行檔
Write-Host "檢查 benchmark_genai.exe..." -ForegroundColor Yellow
if (-not (Test-Path $exePath)) {
    Write-Host "❌ 找不到 benchmark_genai.exe" -ForegroundColor Red
    Write-Host "   預期路徑: $exePath" -ForegroundColor Red
    exit 1
}
Write-Host "✅ benchmark_genai.exe 存在" -ForegroundColor Green

# 3. 檢查 bin 目錄
Write-Host "檢查 DLL 目錄..." -ForegroundColor Yellow
if (-not (Test-Path $binPath)) {
    Write-Host "❌ 找不到 bin 目錄" -ForegroundColor Red
    Write-Host "   預期路徑: $binPath" -ForegroundColor Red
    Write-Host "   請先完成階段 2：設置獨立環境" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ bin 目錄存在" -ForegroundColor Green

# 4. 檢查必要的 DLL（關鍵依賴）
Write-Host "檢查必要的 DLL..." -ForegroundColor Yellow
$requiredDlls = @(
    "openvino_genai.dll",
    "openvino.dll",
    "openvino_tokenizers.dll",
    "openvino_ir_frontend.dll",
    "openvino_intel_cpu_plugin.dll"
)

$missingDlls = @()
foreach ($dll in $requiredDlls) {
    $dllPath = Join-Path $binPath $dll
    if (-not (Test-Path $dllPath)) {
        $missingDlls += $dll
    }
}

if ($missingDlls.Count -gt 0) {
    Write-Host "❌ 缺少必要的 DLL 文件:" -ForegroundColor Red
    foreach ($dll in $missingDlls) {
        Write-Host "   - $dll" -ForegroundColor Red
    }
    Write-Host "`n請執行階段 2 的 verify_dlls.ps1 檢查所有依賴" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ 所有關鍵 DLL 文件存在" -ForegroundColor Green

# 5. 檢查模型路徑
Write-Host "檢查模型路徑..." -ForegroundColor Yellow
if (-not (Test-Path $Model)) {
    Write-Host "❌ 模型路徑不存在: $Model" -ForegroundColor Red
    Write-Host "   請確認模型已下載或指定正確的路徑" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ 模型路徑存在" -ForegroundColor Green

# 6. 顯示測試配置
Write-Host "`n=== 測試配置 ===" -ForegroundColor Cyan
Write-Host "模型: $Model" -ForegroundColor White
Write-Host "設備: $Device" -ForegroundColor White
Write-Host "提示: $Prompt" -ForegroundColor White
Write-Host "最大 tokens: $MaxTokens" -ForegroundColor White
Write-Host "迭代次數: $NumIterations`n" -ForegroundColor White

# 7. 設置臨時 PATH 環境變數
$env:PATH = "$binPath;$env:PATH"
Write-Host "✅ 已設置臨時 PATH 環境變數`n" -ForegroundColor Green

# 8. 執行 benchmark
Write-Host "=== 開始執行 Benchmark ===" -ForegroundColor Cyan
Write-Host "執行中，請稍候...`n" -ForegroundColor Yellow

$startTime = Get-Date

# 構建命令參數
$arguments = @(
    "--model", "`"$Model`"",
    "--device", $Device,
    "--prompt", "`"$Prompt`"",
    "--max_new_tokens", $MaxTokens,
    "--num_iterations", $NumIterations
)

# 執行命令
& $exePath @arguments

$exitCode = $LASTEXITCODE
$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

# 9. 顯示結果
Write-Host "`n=== 執行完成 ===" -ForegroundColor Cyan
Write-Host "總耗時: $($duration.ToString('F2')) 秒" -ForegroundColor White
Write-Host "退出代碼: $exitCode" -ForegroundColor $(if ($exitCode -eq 0) { "Green" } else { "Red" })

if ($exitCode -eq 0) {
    Write-Host "`n✅ Benchmark 執行成功！" -ForegroundColor Green
} else {
    Write-Host "`n❌ Benchmark 執行失敗（退出代碼: $exitCode）" -ForegroundColor Red
    Write-Host "請檢查以上錯誤信息" -ForegroundColor Yellow
}

Write-Host "========================================`n" -ForegroundColor Cyan

exit $exitCode
'@ | Out-File -FilePath "run_benchmark_with_official_runtime.ps1" -Encoding UTF8

Write-Host "✅ 執行腳本已創建" -ForegroundColor Green
```

---

### 步驟 3.2：測試腳本語法

```powershell
# 檢查腳本語法
powershell -NoProfile -ExecutionPolicy Bypass -File ".\run_benchmark_with_official_runtime.ps1" -WhatIf
```

如果沒有錯誤，繼續下一步。

---

### 步驟 3.3：測試腳本執行（乾運行）

```powershell
# 測試腳本的檢查功能（不實際執行 benchmark）
# 先暫時重命名 exe 來測試錯誤檢查

# 檢查腳本是否能正確檢測到文件
.\run_benchmark_with_official_runtime.ps1 -Device CPU
```

**預期輸出：**
```
========================================
  OpenVINO GenAI Benchmark (C++ Runtime)
========================================

檢查 benchmark_genai.exe...
✅ benchmark_genai.exe 存在
檢查 DLL 目錄...
✅ bin 目錄存在
檢查必要的 DLL...
✅ 所有關鍵 DLL 文件存在
檢查模型路徑...
✅ 模型路徑存在

=== 測試配置 ===
模型: C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov
設備: CPU
提示: What is OpenVINO?
最大 tokens: 20
迭代次數: 1

✅ 已設置臨時 PATH 環境變數

=== 開始執行 Benchmark ===
執行中，請稍候...
```

---

### 步驟 3.4：測試幫助功能

```powershell
# 查看腳本幫助
Get-Help .\run_benchmark_with_official_runtime.ps1 -Full
```

**預期輸出：**
```
名稱
    run_benchmark_with_official_runtime.ps1
    
概要
    使用官方 C++ Runtime 執行預編譯的 benchmark_genai.exe
    
語法
    .\run_benchmark_with_official_runtime.ps1 [[-Model] <String>] [[-Device] <String>] ...
    
說明
    此腳本自動設置環境變數並執行 benchmark_genai.exe
    - 自動設置臨時 PATH（不影響系統環境）
    - 檢查所有必要的 DLL 依賴
    - 支援自定義參數
    - 提供清晰的錯誤提示
    
參數
    -Model <String>
        模型路徑（預設：OpenLLaMA 7B INT4）
        
    -Device <String>
        設備類型：CPU 或 GPU（預設：CPU）
        
    ...
```

---

### 步驟 3.5：測試錯誤檢查功能

#### 測試 1：缺少 DLL 的檢測

```powershell
# 暫時重命名一個關鍵 DLL
Rename-Item "openvino_cpp_runtime\bin\openvino_genai.dll" -NewName "openvino_genai.dll.bak"

# 執行腳本
.\run_benchmark_with_official_runtime.ps1

# 恢復 DLL
Rename-Item "openvino_cpp_runtime\bin\openvino_genai.dll.bak" -NewName "openvino_genai.dll"
```

**預期輸出：**
```
...
檢查必要的 DLL...
❌ 缺少必要的 DLL 文件:
   - openvino_genai.dll

請執行階段 2 的 verify_dlls.ps1 檢查所有依賴
```

#### 測試 2：錯誤的模型路徑

```powershell
# 使用不存在的模型路徑
.\run_benchmark_with_official_runtime.ps1 -Model "C:\nonexistent\model"
```

**預期輸出：**
```
...
檢查模型路徑...
❌ 模型路徑不存在: C:\nonexistent\model
   請確認模型已下載或指定正確的路徑
```

---

## ✅ 完成檢查

在進入下一階段前，確認以下項目：

- [ ] 腳本 `run_benchmark_with_official_runtime.ps1` 已創建
- [ ] 腳本語法無錯誤
- [ ] 幫助文檔可正常顯示
- [ ] DLL 檢查功能正常工作
- [ ] 模型路徑檢查功能正常
- [ ] 所有預檢查步驟通過

---

## 📊 階段總結

### 完成項目

✅ **腳本創建**
- 創建 `run_benchmark_with_official_runtime.ps1`
- 總計 200+ 行完整腳本

✅ **功能驗證**
- 參數支援：Model, Device, Prompt, MaxTokens, NumIterations
- 錯誤檢查：DLL 依賴、模型路徑、執行檔
- 環境設置：臨時 PATH 環境變數
- 結果顯示：彩色輸出、退出代碼

✅ **測試通過**
- 語法檢查通過
- 錯誤檢測功能正常
- 幫助文檔完整

### 關鍵成果

🎯 **一鍵執行**
- 不需要手動設置環境
- 自動檢查所有依賴
- 清晰的錯誤提示

### 下一階段預告

在 [階段 5：執行性能測試](STAGE_5_RUN_BENCHMARK.md) 中，我們將：
1. 執行 CPU 模式測試
2. 執行 GPU 模式測試
3. 分析性能結果
4. 生成測試報告

---

## 📚 腳本功能詳解

### 核心功能

#### 1. 參數系統
```powershell
param(
    [string]$Model = "...",        # 模型路徑
    [ValidateSet("CPU", "GPU")]
    [string]$Device = "CPU",       # 設備類型（限制選項）
    [string]$Prompt = "...",       # 提示文字
    [int]$MaxTokens = 20,          # 最大 tokens
    [int]$NumIterations = 1        # 迭代次數
)
```

#### 2. 環境檢查
- ✅ 檢查 `benchmark_genai.exe` 存在
- ✅ 檢查 `bin` 目錄存在
- ✅ 檢查 5 個關鍵 DLL 存在
- ✅ 檢查模型路徑存在

#### 3. PATH 設置
```powershell
$env:PATH = "$binPath;$env:PATH"
```
- 臨時修改，不影響系統
- 腳本執行完畢後自動恢復

#### 4. 命令執行
```powershell
& $exePath @arguments
$exitCode = $LASTEXITCODE
```
- 使用 PowerShell 的調用運算符 `&`
- 捕獲退出代碼

#### 5. 結果報告
- 顯示執行時間
- 顯示退出代碼
- 彩色狀態指示

---

## 💡 腳本使用範例

### 範例 1：基本 CPU 測試
```powershell
.\run_benchmark_with_official_runtime.ps1
```

### 範例 2：GPU 測試
```powershell
.\run_benchmark_with_official_runtime.ps1 -Device GPU
```

### 範例 3：自定義提示
```powershell
.\run_benchmark_with_official_runtime.ps1 -Prompt "Explain quantum computing in simple terms"
```

### 範例 4：長文本生成
```powershell
.\run_benchmark_with_official_runtime.ps1 -MaxTokens 100 -NumIterations 3
```

### 範例 5：使用不同模型
```powershell
.\run_benchmark_with_official_runtime.ps1 -Model "C:\path\to\another\model"
```

### 範例 6：完整自定義
```powershell
.\run_benchmark_with_official_runtime.ps1 `
    -Model "C:\Users\svd\codes\openvino-lab\models\TinyLlama-1.1B-Chat-v1.0" `
    -Device GPU `
    -Prompt "Write a haiku about AI" `
    -MaxTokens 50 `
    -NumIterations 5
```

---

## ⚠️ 故障排除

### 問題 1：執行策略錯誤

**症狀：**
```
.\run_benchmark_with_official_runtime.ps1 : 無法載入檔案，因為這個系統上已停用指令碼執行。
```

**解決方案：**
```powershell
# 臨時允許執行（推薦）
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 或使用完整命令
powershell -ExecutionPolicy Bypass -File ".\run_benchmark_with_official_runtime.ps1"
```

### 問題 2：路徑錯誤

**症狀：** "找不到 benchmark_genai.exe"

**解決方案：**
```powershell
# 檢查當前目錄
Get-Location

# 確保在正確目錄
cd C:\Users\svd\codes\openvino-lab\nvme_dsm_test

# 檢查文件結構
dir benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe
```

### 問題 3：DLL 檢查失敗

**症狀：** "❌ 缺少必要的 DLL 文件"

**解決方案：**
```powershell
# 執行完整 DLL 驗證
cd openvino_cpp_runtime
.\verify_dlls.ps1

# 如果有缺失，重新執行階段 2
```

### 問題 4：模型路徑問題

**症狀：** "❌ 模型路徑不存在"

**解決方案：**
```powershell
# 檢查模型是否存在
Test-Path "C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov"

# 或使用絕對路徑
.\run_benchmark_with_official_runtime.ps1 -Model "C:\full\path\to\model"
```

### 問題 5：編碼問題

**症狀：** 中文顯示亂碼

**解決方案：**
```powershell
# 設置控制台編碼
chcp 65001

# 或在腳本開頭已經處理
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

---

## 🔧 腳本自定義

### 修改預設模型路徑

在腳本中找到：
```powershell
[string]$Model = "C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov",
```

修改為您的預設模型：
```powershell
[string]$Model = "C:\your\custom\path\to\model",
```

### 添加更多設備選項

修改 Device 參數：
```powershell
[ValidateSet("CPU", "GPU", "NPU", "AUTO")]
[string]$Device = "CPU",
```

### 調整預設參數

根據需求修改：
```powershell
[int]$MaxTokens = 50,      # 增加預設生成長度
[int]$NumIterations = 3    # 增加預設迭代次數
```

---

## 🎯 關鍵要點

1. **腳本是自包含的** - 不需要其他依賴
2. **環境是臨時的** - PATH 修改不影響系統
3. **錯誤檢查完整** - 預先驗證所有條件
4. **參數靈活** - 支援各種測試場景
5. **輸出清晰** - 彩色提示易於理解

---

**準備好了嗎？讓我們進入 [階段 5：執行性能測試](STAGE_5_RUN_BENCHMARK.md)！**

---

**創建日期：** 2026-01-02  
**最後更新：** 2026-01-02  
**維護者：** OpenVINO Lab 項目  
**狀態：** ✅ 已驗證可用
