# 使用預編譯 benchmark_genai.exe 的完整執行方案

**目標：** 成功運行預編譯的 `benchmark_genai.exe`  
**首要條件：** 必須使用已提供的預編譯執行檔，不重新編譯  
**日期：** 2026-01-02

---

## 📋 方案概述

由於預編譯的 `benchmark_genai.exe` 與當前 Python 環境中的 OpenVINO GenAI 版本不完全兼容，我們需要：

1. ✅ **方案 1（推薦）：** 下載匹配的官方 C++ Runtime 套件
2. ⚠️ **方案 2（備用）：** 如果方案 1 失敗，請求提供者提供完整的運行時環境

---

## 🎯 方案 1：使用官方 OpenVINO GenAI C++ Runtime

### 步驟 1：下載官方套件

**下載位置：**
```
https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/2025.4.1/windows/
```

**需要下載的文件：**

#### 選項 A：下載完整 C++ 套件（推薦）

尋找類似以下名稱的壓縮檔：
```
openvino_genai_windows_2025.4.1_x86_64.zip
或
openvino_genai_runtime_2025.4.1_windows.zip
或
openvino_genai_cpp_2025.4.1.zip
```

#### 選項 B：下載個別 DLL 文件

如果沒有完整套件，下載以下 DLL：
```
openvino_genai.dll           (約 4-5 MB)
openvino_tokenizers.dll      (約 2-3 MB)
相關的依賴 DLL
```

---

### 步驟 2：設置獨立的 Runtime 環境

**目標：** 不影響現有的 Python 虛擬環境

#### 2.1 創建獨立目錄

```powershell
# 在項目根目錄創建新目錄
cd C:\Users\svd\codes\openvino-lab
New-Item -ItemType Directory -Path ".\openvino_cpp_runtime" -Force

# 創建子目錄結構
New-Item -ItemType Directory -Path ".\openvino_cpp_runtime\bin" -Force
New-Item -ItemType Directory -Path ".\openvino_cpp_runtime\lib" -Force
```

#### 2.2 解壓套件到獨立目錄

```powershell
# 假設下載的檔案在 Downloads 目錄
$downloadPath = "$env:USERPROFILE\Downloads\openvino_genai_windows_2025.4.1.zip"
$extractPath = "C:\Users\svd\codes\openvino-lab\openvino_cpp_runtime"

# 解壓縮
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force
```

#### 2.3 整理 DLL 文件

```powershell
# 確認 DLL 位置
cd C:\Users\svd\codes\openvino-lab\openvino_cpp_runtime

# 查找所有 DLL
Get-ChildItem -Recurse -Filter "*.dll" | ForEach-Object {
    Write-Host "$($_.Name) - $($_.DirectoryName)"
}

# 如果 DLL 在子目錄中，複製到 bin 目錄
# 根據實際情況調整路徑
Copy-Item ".\runtime\bin\*.dll" -Destination ".\bin\" -Force
```

---

### 步驟 3：配置環境變數（臨時）

**重要：** 使用臨時環境變數，不永久修改系統設定

#### 3.1 創建啟動腳本

創建文件：`run_benchmark_with_cpp_runtime.ps1`

```powershell
# run_benchmark_with_cpp_runtime.ps1
# 使用獨立 C++ Runtime 運行 benchmark_genai.exe

# 設置顏色輸出
$ErrorActionPreference = "Stop"

Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  使用官方 C++ Runtime 運行 benchmark_genai.exe" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# 設置項目根目錄
$projectRoot = "C:\Users\svd\codes\openvino-lab"
Set-Location $projectRoot

# 設置 C++ Runtime 路徑
$cppRuntimePath = Join-Path $projectRoot "openvino_cpp_runtime"
$cppBinPath = Join-Path $cppRuntimePath "bin"
$cppLibPath = Join-Path $cppRuntimePath "lib"

# 檢查路徑是否存在
if (-not (Test-Path $cppBinPath)) {
    Write-Host "❌ 錯誤: 找不到 C++ Runtime bin 目錄" -ForegroundColor Red
    Write-Host "   路徑: $cppBinPath" -ForegroundColor Gray
    Write-Host "`n請先執行步驟 1 和 2 下載並設置 C++ Runtime`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ 找到 C++ Runtime 目錄" -ForegroundColor Green
Write-Host "   路徑: $cppBinPath`n" -ForegroundColor Gray

# 設置臨時環境變數（僅對當前 PowerShell 會話有效）
$env:PATH = "$cppBinPath;$cppLibPath;$env:PATH"

Write-Host "✅ 已設置臨時環境變數 PATH" -ForegroundColor Green
Write-Host "`n📋 可用的 DLL 文件:" -ForegroundColor Yellow
Get-ChildItem $cppBinPath -Filter "*.dll" | Select-Object -First 10 | ForEach-Object {
    Write-Host "   • $($_.Name)" -ForegroundColor Gray
}

# 設置 benchmark_genai.exe 路徑
$benchmarkExe = Join-Path $projectRoot "nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe"

if (-not (Test-Path $benchmarkExe)) {
    Write-Host "`n❌ 錯誤: 找不到 benchmark_genai.exe" -ForegroundColor Red
    Write-Host "   路徑: $benchmarkExe`n" -ForegroundColor Gray
    exit 1
}

Write-Host "`n✅ 找到 benchmark_genai.exe" -ForegroundColor Green
Write-Host "   路徑: $benchmarkExe`n" -ForegroundColor Gray

# 設置模型路徑
$modelPath = Join-Path $projectRoot "models\open_llama_7b_v2-int4-ov"

if (-not (Test-Path $modelPath)) {
    Write-Host "❌ 錯誤: 找不到模型目錄" -ForegroundColor Red
    Write-Host "   路徑: $modelPath`n" -ForegroundColor Gray
    exit 1
}

Write-Host "✅ 找到模型目錄" -ForegroundColor Green
Write-Host "   路徑: $modelPath`n" -ForegroundColor Gray

# 執行 benchmark
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  開始執行 Benchmark" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "📝 參數設置:" -ForegroundColor Yellow
Write-Host "   • 模型: open_llama_7b_v2-int4-ov" -ForegroundColor Gray
Write-Host "   • 設備: CPU" -ForegroundColor Gray
Write-Host "   • 提示詞: 'The Sky is blue because'" -ForegroundColor Gray
Write-Host "   • 預熱次數: 0" -ForegroundColor Gray
Write-Host "   • 迭代次數: 1" -ForegroundColor Gray
Write-Host "   • 最大生成 tokens: 20`n" -ForegroundColor Gray

Write-Host "⏳ 執行中...`n" -ForegroundColor Yellow

# 執行命令
& $benchmarkExe `
    -m $modelPath `
    -d CPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1

$exitCode = $LASTEXITCODE

Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  執行結果" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

if ($exitCode -eq 0) {
    Write-Host "✅ 成功！Exit Code: $exitCode" -ForegroundColor Green
    Write-Host "`n📊 Benchmark 測試完成！" -ForegroundColor Cyan
} else {
    Write-Host "❌ 失敗！Exit Code: $exitCode" -ForegroundColor Red
    Write-Host "`n💡 可能的原因:" -ForegroundColor Yellow
    Write-Host "   1. 下載的 C++ Runtime 版本仍不匹配" -ForegroundColor Gray
    Write-Host "   2. 缺少其他依賴 DLL" -ForegroundColor Gray
    Write-Host "   3. 預編譯執行檔需要特定的內部構建版本`n" -ForegroundColor Gray
}

Write-Host "`n按任意鍵結束..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
```

#### 3.2 執行腳本

```powershell
# 給予執行權限（如需要）
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 執行腳本
.\run_benchmark_with_cpp_runtime.ps1
```

---

### 步驟 4：驗證和測試

#### 4.1 測試步驟

```powershell
# 1. 檢查是否能顯示幫助信息
.\run_benchmark_with_cpp_runtime.ps1 --help

# 2. 使用 TinyLlama 模型測試（較小，速度快）
# 修改腳本中的模型路徑為 TinyLlama

# 3. 使用 OpenLLaMA 7B 模型（完整測試）
.\run_benchmark_with_cpp_runtime.ps1
```

#### 4.2 預期結果

**成功的輸出：**
```
Compiled Cache Dir: compiled_cache
OpenVINO Runtime
    Version : 2025.4.1
    Build   : 2025.4.1-20426-82bbf0292c5-releases/2025/4

Using CACHE_DIR: .ccache
Prompt token size:6
Output token size:20
Load time: 5860.00 ms
Generate time: 1850.92 ms
...
Throughput: 11.05 tokens/s
```

**失敗的輸出：**
```
Exception from src\inference\src\cpp\core.cpp:186:
Cannot add extension. Cannot find entry point to the extension library
```

---

## 🔄 方案 2：如果方案 1 失敗（備用方案）

### 選項 A：請求完整的運行環境

**聯繫提供 benchmark_genai.exe 的人員：**

1. **請求提供完整的依賴文件：**
   ```
   請提供與 benchmark_genai.exe 配套的：
   - 所有 DLL 文件（openvino_genai.dll 等）
   - 確切的構建版本號
   - 環境設置說明
   ```

2. **詢問編譯環境信息：**
   ```
   請告知 benchmark_genai.exe 的編譯環境：
   - OpenVINO 版本和構建號
   - OpenVINO GenAI 版本和構建號
   - 編譯器版本（如 Visual Studio 2022）
   - 是否使用內部測試構建
   ```

### 選項 B：使用 Docker 容器隔離環境

如果有 Docker 可用，可以創建隔離環境：

```dockerfile
# Dockerfile
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# 安裝 OpenVINO GenAI 2025.4.1 官方套件
# 複製 benchmark_genai.exe
# 設置環境
```

### 選項 C：從源碼編譯匹配版本（最後選擇）

如果必須使用 C++ 工具但官方套件不匹配，則需要：

1. 從源碼編譯 `benchmark_genai.exe`
2. 使用當前環境的 pip 套件作為依賴
3. 確保 100% 版本匹配

詳見：`STAGE_9_GUIDE.md` - 方法 3：從源碼編譯

---

## 📊 成功率預估

| 方案 | 成功率 | 時間投入 | 風險 |
|------|--------|---------|------|
| **方案 1：官方 C++ Runtime** | 60-70% | 30 分鐘 | 中 |
| **方案 2A：請求完整環境** | 90%+ | 依賴回應 | 低 |
| **方案 2B：Docker 隔離** | 70-80% | 1-2 小時 | 中 |
| **方案 2C：從源碼編譯** | 95%+ | 20-30 分鐘 | 低 |

---

## ✅ 檢查清單

### 準備階段
- [ ] 確認網路可以訪問 OpenVINO 官方儲存庫
- [ ] 確認磁碟空間充足（至少 5 GB）
- [ ] 備份當前 Python 環境配置

### 下載階段
- [ ] 從官網下載 OpenVINO GenAI C++ Runtime
- [ ] 驗證下載文件的完整性
- [ ] 解壓到獨立目錄

### 配置階段
- [ ] 創建 `openvino_cpp_runtime` 目錄
- [ ] 整理 DLL 文件到 bin 目錄
- [ ] 創建啟動腳本 `run_benchmark_with_cpp_runtime.ps1`
- [ ] 測試腳本執行權限

### 測試階段
- [ ] 執行 benchmark_genai.exe --help
- [ ] 使用小模型測試（TinyLlama）
- [ ] 使用目標模型測試（OpenLLaMA 7B）
- [ ] 記錄測試結果和錯誤信息

### 如果失敗
- [ ] 記錄完整錯誤信息
- [ ] 檢查 DLL 版本號
- [ ] 考慮聯繫提供者
- [ ] 評估是否需要從源碼編譯

---

## 🎯 下一步行動

### 立即執行（推薦順序）

1. **訪問官方儲存庫**
   ```
   https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/2025.4.1/windows/
   ```
   查看可用的套件文件

2. **下載適合的套件**
   - 優先選擇完整的 Runtime 套件
   - 記錄下載的檔案名稱和大小

3. **按照步驟 2 設置獨立環境**
   - 不要覆蓋或影響現有 Python 環境

4. **使用提供的腳本測試**
   - 如果成功 ✅ 完成任務
   - 如果失敗 ⚠️ 進入方案 2

---

## 📝 預期時間表

| 階段 | 預估時間 | 累計時間 |
|------|---------|---------|
| 下載套件 | 5-10 分鐘 | 10 分鐘 |
| 解壓和設置 | 10-15 分鐘 | 25 分鐘 |
| 配置和測試 | 10-20 分鐘 | 45 分鐘 |
| 如果需要調試 | +30 分鐘 | 75 分鐘 |

**總計：** 約 45-75 分鐘（取決於是否順利）

---

## 💡 重要提醒

1. **不要刪除或修改現有的 Python 環境**
   - 方案 1 使用獨立目錄
   - 臨時環境變數不會永久改變系統

2. **保存所有錯誤信息**
   - 如果失敗，錯誤信息對診斷很重要

3. **準備備用方案**
   - 如果官方套件不匹配，可能需要聯繫提供者
   - 或考慮從源碼編譯

4. **測試後恢復**
   - 關閉 PowerShell 後環境變數自動恢復
   - Python 環境不受影響

---

**創建日期：** 2026-01-02  
**最後更新：** 2026-01-02  
**狀態：** 準備執行
