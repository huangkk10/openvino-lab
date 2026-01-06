# 🚀 一鍵執行 Benchmark - 快速開始指南

**最後更新：** 2026-01-06  
**版本：** 1.0

---

## 📋 簡介

本指南提供 3 種方式一鍵執行 Benchmark，無需手動設定環境變數。

| 方式 | 檔案 | 特點 | 推薦 |
|------|------|------|------|
| **方式 A** | `run_benchmark.bat` | 雙擊即開，無需 PowerShell | ⭐⭐⭐ |
| **方式 B** | `setup_and_run_benchmark.ps1` | 功能最完整，可自訂參數 | ⭐⭐⭐ |
| **方式 C** | `run_benchmark.ps1` | 簡單版本 | ⭐⭐ |

---

## 🎯 快速開始（最簡單）

### **方式 A：雙擊 `.bat` 檔案（推薦新手）**

1. 在檔案總管中進入 `C:\Users\svd\codes\openvino-lab`
2. **雙擊** `run_benchmark.bat`
3. 等待執行完成，按任意鍵關閉

**優點：**
- ✅ 最簡單，完全自動化
- ✅ 無需打開 PowerShell
- ✅ 自動設定 PATH
- ✅ 適合每次快速執行

**缺點：**
- ❌ 無法自訂參數
- ❌ 環境變數設定為臨時有效

---

## 💻 進階用法

### **方式 B：PowerShell 完整版本（推薦進階用戶）**

在 PowerShell 中執行（進入 `C:\Users\svd\codes\openvino-lab`）：

#### **基本執行（預設參數）**
```powershell
.\setup_and_run_benchmark.ps1
```

#### **自訂參數執行**
```powershell
# 設定迭代次數與最大 token
.\setup_and_run_benchmark.ps1 -NumIter 3 -MaxTokens 50

# 使用 CPU 而不是 GPU
.\setup_and_run_benchmark.ps1 -Device CPU

# 自訂提示詞
.\setup_and_run_benchmark.ps1 -Prompt "Hello, how are you?"

# 跳過環境變數設定（假設已設定）
.\setup_and_run_benchmark.ps1 -SkipSetup
```

#### **參數說明**

| 參數 | 預設值 | 說明 |
|------|--------|------|
| `-Device` | GPU | 執行設備 (GPU / CPU) |
| `-NumIter` | 1 | 執行迭代次數 |
| `-MaxTokens` | 20 | 最多生成 token 數 |
| `-Warmup` | 0 | 預熱迭代次數 |
| `-Prompt` | "The Sky is blue because" | 輸入提示詞 |
| `-CacheDir` | ".ccache" | 編譯快取目錄 |
| `-SkipSetup` | (無) | 跳過環境變數設定 |

**優點：**
- ✅ 功能最完整
- ✅ 可自訂所有參數
- ✅ 自動設定永久環境變數（如有管理員權限）
- ✅ 詳細的執行步驟提示

**缺點：**
- ❌ 需要在 PowerShell 中執行

---

### **方式 C：簡化 PowerShell 版本**

```powershell
.\run_benchmark.ps1

# 自訂迭代次數
.\run_benchmark.ps1 -NumIter 3 -MaxTokens 50
```

**優點：**
- ✅ 程式碼簡潔
- ✅ 快速啟動

**缺點：**
- ❌ 功能較少
- ❌ 無法自訂某些參數

---

## ⚙️ 環境變數設定選項

### **選項 1：永久設定（一次性）**

在 PowerShell 中以管理員身份執行：

```powershell
[Environment]::SetEnvironmentVariable(
    'PATH',
    'C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin;' + [Environment]::GetEnvironmentVariable('PATH', 'User'),
    'User'
)
```

完成後，任何新的 PowerShell 視窗都可直接執行：

```powershell
& ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" -m ".\models\open_llama_7b_v2-int4-ov" -d GPU ...
```

### **選項 2：臨時設定（單次會話）**

在 PowerShell 中執行：

```powershell
$env:PATH = ".\nvme_dsm_test\openvino_cpp_runtime\bin;" + $env:PATH
```

然後執行 benchmark（此會話有效，關閉 PowerShell 後失效）。

### **選項 3：使用腳本自動設定**

直接執行 `setup_and_run_benchmark.ps1`：
- 如有管理員權限 → 自動設定永久環境變數
- 如無管理員權限 → 自動設定臨時環境變數

---

## 📊 執行結果示例

成功執行後，你會看到類似的輸出：

```
╔════════════════════════════════════════════════════════════╗
║          一鍵 Benchmark 設定與執行                        ║
╚════════════════════════════════════════════════════════════╝

[1] 檢查系統環境
   工作目錄: C:\Users\svd\codes\openvino-lab
✅ 找到 benchmark 執行檔
✅ 找到模型路徑
✅ 找到 OpenVINO runtime

[2] 設定 OpenVINO PATH 環境變數
✅ 永久 PATH 設定完成
✅ 會話 PATH 設定完成

[3] 驗證 OpenVINO 可用性
✅ benchmark 執行檔驗證成功

╔════════════════════════════════════════════════════════════╗
║                    執行 Benchmark                         ║
╚════════════════════════════════════════════════════════════╝

參數設定：
  Model:        .\models\open_llama_7b_v2-int4-ov
  Device:       GPU
  Prompt:       The Sky is blue because
  ...

正在執行 benchmark...

OpenVINO Runtime
    Version : 2025.4.1
    Build   : 2025.4.1-20426-82bbf0292c5-releases/2025/4

Using CACHE_DIR: .ccache
Prompt token size:6
Output token size:20
Load time: 5907.00 ms
Generate time: 1262.09 ± 0.00 ms
TTFT: 113.03 ± 0.00 ms
TPOT: 60.44 ± 5.24 ms/token
Throughput: 16.55 ± 1.44 tokens/s

╔════════════════════════════════════════════════════════════╗
║                    執行結果                               ║
╚════════════════════════════════════════════════════════════╝

✅ Benchmark 執行完成
執行時間: 7.25 秒
```

---

## 🔧 故障排除

### **問題：執行後無輸出或閃退**

**解決方法：**

1. 確保在正確的工作目錄：
   ```powershell
   cd C:\Users\svd\codes\openvino-lab
   ```

2. 檢查必要檔案是否存在：
   ```powershell
   Test-Path .\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe
   Test-Path .\models\open_llama_7b_v2-int4-ov
   ```

3. 手動測試 benchmark：
   ```powershell
   $env:PATH = ".\nvme_dsm_test\openvino_cpp_runtime\bin;" + $env:PATH
   & ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" --help
   ```

### **問題：Exit Code -1073741515**

**原因：** OpenVINO DLL 未找到

**解決方法：**
- 使用 `setup_and_run_benchmark.ps1` 自動設定環境變數
- 或手動設定 PATH（見上面「環境變數設定選項」）

### **問題：GPU 無法使用**

**可能原因：**
- GPU 驅動未裝
- GPU 不支援
- CUDA/OpenVINO GPU 外掛程式問題

**臨時解決：** 改用 CPU
```powershell
.\setup_and_run_benchmark.ps1 -Device CPU
```

---

## 📝 建議使用流程

### **首次執行（推薦）**

1. 在管理員 PowerShell 中執行一次完整版本：
   ```powershell
   .\setup_and_run_benchmark.ps1
   ```
   這會自動設定永久環境變數

2. 之後可以使用任何簡化版本或直接執行 `.bat` 檔案

### **日常執行（之後）**

- 快速執行：雙擊 `run_benchmark.bat`
- 自訂參數：`.\setup_and_run_benchmark.ps1 -NumIter 5`

---

## 🎓 進階：修改腳本

### **自訂預設參數**

編輯 `setup_and_run_benchmark.ps1` 的 `param()` 部分：

```powershell
param(
    [switch]$SkipSetup = $false,
    [string]$Device = "GPU",           # 改為 "CPU" 使用 CPU
    [string]$Model = "...",
    [string]$Prompt = "新的提示詞",    # 改為你想要的預設提示
    [int]$NumIter = 3,                 # 改為預設迭代次數
    ...
)
```

### **添加執行後自動保存結果**

在腳本最後添加：

```powershell
# 保存結果到檔案
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$outputFile = "benchmark_result_$timestamp.txt"
# ... 將輸出重定向保存
```

---

## ✅ 檢查清單

- [x] `run_benchmark.bat` 已建立（.bat 批次檔案）
- [x] `setup_and_run_benchmark.ps1` 已建立（完整 PowerShell 版本）
- [x] `run_benchmark.ps1` 已建立（簡化 PowerShell 版本）
- [x] `ONE_CLICK_QUICK_START.md` 已建立（本文檔）

---

## 🚀 一句話快速開始

```powershell
cd C:\Users\svd\codes\openvino-lab; .\setup_and_run_benchmark.ps1
```

或直接雙擊 `run_benchmark.bat`！

---

**需要幫助？** 查看 [STAGE_7_CONFIGURE_DSM_HINTS.md](./docs/benchmark/STAGE_7_CONFIGURE_DSM_HINTS.md) 中的故障排除章節。
