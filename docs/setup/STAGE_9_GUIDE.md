# Stage 9：性能基準測試指南（進階）

> **狀態：** ✅ 已測試驗證  
> **前置要求：** 已完成 Stage 1-8（至少 Stage 1-7 + 下載大型模型）  
> **預計時間：** 30-60 分鐘（編譯 + 測試）  
> **技術需求：** C++ 編譯環境、CMake  
> **實測性能：** open_llama (CPU) - 14.99 tokens/s ⭐⭐⭐

---

## 🎉 實測結果

### 測試環境
- **OpenVINO 版本**: 2025.4.1
- **模型**: open_llama (4.25 GB, INT4 量化)
- **設備**: CPU
- **提示詞**: "The Sky is blue because"
- **生成 Tokens**: 20

### 性能指標

```
OpenVINO Runtime
    Version : 2025.4.1
    Build   : 2025.4.1-20426-82bbf0292c5-releases/2025/4

Prompt token size: 6
Output token size: 20
Load time: 4891.00 ms
Generate time: 3576.51 ± 0.00 ms
Tokenization time: 0.32 ± 0.00 ms
Detokenization time: 0.42 ± 0.00 ms
TTFT: 2308.16 ± 0.00 ms
TPOT: 66.73 ± 3.84 ms/token
Throughput: 14.99 ± 0.86 tokens/s
```

### 關鍵數據
- ⚡ **吞吐量**: 14.99 tokens/秒（CPU 模式下為良好性能）
- ⏱️ **首Token時間 (TTFT)**: 2.31 秒
- 🔄 **每Token時間 (TPOT)**: 66.73 ms
- 📥 **模型加載時間**: 4.89 秒

---

## 📋 概述

Stage 9 是**進階性能測試功能**，使用 OpenVINO GenAI 官方的 C++ benchmark 工具測試模型推理性能。

### 💡 什麼是 Benchmark？

Benchmark（基準測試）用於：
- 📊 測量推理速度（tokens/second）
- ⏱️ 評估延遲時間（首字延遲、平均延遲）
- 💾 監控資源使用（CPU、GPU、記憶體）
- 🔄 比較不同配置的性能差異

### 🎯 何時需要 Stage 9？

| 情況 | 是否需要 Stage 9 |
|------|-----------------|
| 只想快速體驗推理 | ❌ 不需要（Stage 7 已足夠） |
| 想了解推理性能指標 | ✅ 需要 |
| 需要優化推理速度 | ✅ 需要（先測試再優化） |
| 比較不同模型性能 | ✅ 需要 |
| 比較 CPU vs GPU 性能 | ✅ 需要 |
| 撰寫技術報告 | ✅ 需要（提供數據支持） |
| 沒有 C++ 編譯環境 | ✅ **可以！使用預編譯執行檔** |
| 不想花時間設置編譯工具 | ✅ **可以！使用預編譯執行檔** |

> **💡 重要提醒：** 專案中已包含**預編譯好的 `benchmark_genai.exe`**，位於 `nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\`，可以**直接使用，無需安裝 Visual Studio 或 CMake**！如果您想深入了解編譯過程或自訂修改源碼，可以參考後面的「從源碼編譯」章節。

---

## 🚀 快速開始

### 💡 快速參考（複製即用）

**⭐ 最快速（使用預編譯執行檔）：**
```powershell
# 使用專案中已編譯好的 benchmark_genai.exe（無需自己編譯！）
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1 `
    --cache_dir ".ccache"
```

**使用 Helper 腳本：**
```powershell
.\scripts\run_benchmark_easy.ps1 -Device CPU -NumIter 1
```

**標準測試（5 次迭代）：**
```powershell
.\scripts\run_benchmark_easy.ps1 -Model "./models/open_llama" -Device CPU -NumIter 5
```

**不用 Helper 腳本（完全獨立 - 需自己編譯）：**
```powershell
$env:PATH="C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;$env:PATH";& "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe" -m "C:\Users\svd\codes\openvino-lab\models\open_llama" -d CPU -p "The Sky is blue because" --nw 0 --mt 20 -n 1
```

---

### 前置準備

```powershell
# 1. 確保已完成 Stage 8（下載大型模型）
ls ./models/open_llama

# 2. 確保虛擬環境已激活（如使用 Python 腳本）
.\venv\Scripts\Activate.ps1
```

### 方法 1：使用預編譯的 Benchmark 執行檔（推薦 - 最簡單）⭐⭐⭐

**✨ 優點：無需安裝 Visual Studio、CMake，無需編譯！**

專案中已包含預編譯好的 `benchmark_genai.exe`，可直接使用：

```powershell
# 基本用法 - CPU 模式
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d CPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1

# GPU 模式（推薦 - 更快）
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1 `
    --cache_dir ".ccache"

# 精確測試（5 次迭代取平均）
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 2 `
    --mt 50 `
    -n 5 `
    --cache_dir ".ccache"
```

**預期輸出範例：**
```
Compiled Cache Dir: compiled_cache
OpenVINO Runtime
    Version : 2025.4.1
    Build   : 2025.4.1-20426-82bbf0292c5-releases/2025/4

Using CACHE_DIR: .ccache
Prompt token size:6
Output token size:20
Load time: 5860.00 ms
Generate time: 1850.92 ± 0.00 ms
Tokenization time: 0.53 ± 0.00 ms
Detokenization time: 0.51 ± 0.00 ms
TTFT: 131.27 ± 0.00 ms
TPOT: 90.47 ± 19.17 ms/token
Throughput: 11.05 ± 2.34 tokens/s
```

**參數說明：**
- `-m` : 模型路徑
- `-d` : 設備（CPU/GPU/NPU）
- `-p` : 測試提示詞
- `--nw` : 預熱次數（0 = 跳過預熱）
- `--mt` : 最大生成 token 數
- `-n` : 迭代次數
- `--cache_dir` : 編譯快取目錄（加速後續執行）

### 方法 2：使用 PowerShell Helper 腳本⭐⭐

```powershell
# 自動處理路徑和環境變數，直接從任何目錄執行
.\scripts\run_benchmark_easy.ps1 -Model "./models/open_llama" -Device CPU -NumIter 1

# 或使用完整參數
.\scripts\run_benchmark_easy.ps1 `
    -Model "./models/open_llama" `
    -Device CPU `
    -Prompt "The Sky is blue because" `
    -MaxTokens 20 `
    -NumWarmup 0 `
    -NumIter 1
```

**優點：**
- ✅ 自動處理 DLL 路徑設置
- ✅ 自動檢查模型和執行檔存在性
- ✅ 從任何目錄執行（無需 cd）
- ✅ 清晰的進度提示

### 方法 2：使用 Python 包裝腳本

```powershell
# 運行 benchmark（自動處理編譯）
python scripts/run_benchmark.py `
    --model "./models/open_llama" `
    --device CPU `
    --prompt "The Sky is blue because"
```

### 方法 3：直接使用 C++ Benchmark（進階用戶 - 需手動設置路徑）

```powershell
# 設置環境變數
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;" + `
            "C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;" + `
            $env:PATH

# 進入正確目錄
cd "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release"

# 執行 benchmark
.\benchmark_genai.exe -m "C:\Users\svd\codes\openvino-lab\models\open_llama" -d CPU -p "Test" --mt 20 -n 1
```

---

## � 使用預編譯 Benchmark 執行檔（推薦入門）

### 🎯 為什麼使用預編譯執行檔？

專案中已包含預編譯好的 `benchmark_genai.exe`，具有以下優勢：

✅ **無需安裝開發工具** - 不需要 Visual Studio、CMake  
✅ **立即可用** - 下載專案後直接執行  
✅ **完整功能** - 支援所有 benchmark 功能  
✅ **與 OpenVINO 2025.4.1 匹配** - 經過測試驗證  
✅ **節省時間** - 跳過 10-15 分鐘的編譯過程  

### 📂 執行檔位置

```
nvme_dsm_test\
└── benchmark_app\
    └── OpenVINO_AI_apps_v01\
        ├── benchmark_genai.exe  ⭐ 主執行檔
        └── HowTo.txt            📖 使用說明
```

### 🚀 快速開始範例

#### 範例 1：CPU 模式基本測試

```powershell
# 最簡單的方式
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d CPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1
```

**預期輸出：**
```
OpenVINO Runtime
    Version : 2025.4.1
    Build   : 2025.4.1-20426-82bbf0292c5-releases/2025/4

Prompt token size:6
Output token size:20
Load time: 4891.00 ms
Generate time: 3576.51 ± 0.00 ms
Throughput: 14.99 ± 0.86 tokens/s
```

#### 範例 2：GPU 模式（更快，使用編譯快取）

```powershell
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1 `
    --cache_dir ".ccache"
```

**預期輸出：**
```
Compiled Cache Dir: compiled_cache
Using CACHE_DIR: .ccache
Prompt token size:6
Output token size:20
Load time: 5860.00 ms
Generate time: 1850.92 ± 0.00 ms
TTFT: 131.27 ± 0.00 ms
TPOT: 90.47 ± 19.17 ms/token
Throughput: 11.05 ± 2.34 tokens/s
```

#### 範例 3：精確測試（多次迭代取平均值）

```powershell
# 執行 5 次取平均，使用 2 次預熱
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 2 `
    --mt 50 `
    -n 5 `
    --cache_dir ".ccache"
```

#### 範例 4：壓力測試（長文本生成）

```powershell
# 生成 200 個 tokens
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "Write a detailed explanation of artificial intelligence" `
    --nw 2 `
    --mt 200 `
    -n 3 `
    --cache_dir ".ccache"
```

### 📝 參數詳解

| 參數 | 必需 | 說明 | 預設值 | 範例 |
|------|------|------|--------|------|
| `-m, --model` | ✅ | 模型路徑 | - | `.\models\open_llama_7b_v2-int4-ov` |
| `-d, --device` | ❌ | 推理設備 | CPU | `CPU`, `GPU`, `NPU` |
| `-p, --prompt` | ❌ | 測試提示詞 | `""` | `"The Sky is blue because"` |
| `--pf` | ❌ | 從文件讀取提示詞 | - | `prompts.txt` |
| `--nw` | ❌ | 預熱次數 | 1 | `0`（跳過）, `2`, `5` |
| `--mt` | ❌ | 最大生成 token 數 | 20 | `10`, `50`, `100`, `200` |
| `-n, --num_iter` | ❌ | 測試迭代次數 | 3 | `1`, `5`, `10` |
| `--cache_dir` | ❌ | 編譯快取目錄 | `""` | `.ccache` |
| `-h, --help` | ❌ | 顯示幫助信息 | - | - |

### 💡 使用技巧

#### 技巧 1：使用相對路徑簡化命令

```powershell
# 在專案根目錄執行
cd C:\Users\svd\codes\openvino-lab

# 使用相對路徑
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU
```

#### 技巧 2：創建 PowerShell 別名

```powershell
# 創建便捷別名
Set-Alias -Name bench -Value "$PWD\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe"

# 之後只需
bench -m ".\models\open_llama_7b_v2-int4-ov" -d GPU --mt 20 -n 1
```

#### 技巧 3：使用編譯快取加速（首次執行會慢）

```powershell
# 第一次執行（較慢 - 需要編譯模型）
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    --cache_dir ".ccache"

# 後續執行（快很多 - 使用快取）
# 執行相同命令，會自動載入快取
```

#### 技巧 4：批次測試不同配置

```powershell
# 創建測試腳本
$devices = @("CPU", "GPU")
$tokenCounts = @(20, 50, 100)

foreach ($device in $devices) {
    foreach ($tokens in $tokenCounts) {
        Write-Host "`n[*] Testing: Device=$device, Tokens=$tokens" -ForegroundColor Cyan
        
        .\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
            -m ".\models\open_llama_7b_v2-int4-ov" `
            -d $device `
            -p "The Sky is blue because" `
            --nw 0 `
            --mt $tokens `
            -n 3
    }
}
```

### 🔧 常見問題

#### Q1：執行檔執行失敗（Exit code 1）- ⭐ 最常見

```
Command exited with code 1
(無任何輸出)
```

**原因：**
執行檔 (C++ 編譯) 缺少必要的 DLL 依賴，或 DLL 版本不相容：
- `openvino_genai.dll` - GenAI 核心庫
- `openvino_tokenizers.dll` - 分詞庫
- `icudt70.dll`, `icuuc70.dll` - Unicode 支援
- 執行檔可能編譯於不同的 OpenVINO 版本或環境

**推薦解決方案 A：使用 Stage 7 推理腳本（最簡單）✅**

```powershell
# 啟動虛擬環境
.\venv\Scripts\Activate.ps1

# 執行推理腳本（已驗證完全可用）
python scripts/run_inference_simple.py `
    --prompt "The Sky is blue because" `
    --max-tokens 20

# 進行性能測試（5 次迭代）
$times = @()
for ($i = 1; $i -le 5; $i++) {
    $start = Get-Date
    python scripts/run_inference_simple.py --prompt "The Sky is blue because" --max-tokens 20 2>&1 | Out-Null
    $end = Get-Date
    $times += ($end - $start).TotalSeconds
}
$avg = ($times | Measure-Object -Average).Average
Write-Host "平均執行時間: $([math]::Round($avg, 2)) 秒"
Write-Host "平均吞吐量: $([math]::Round(20 / $avg, 2)) tokens/s"
```

**優點：**
- ✅ 無需額外配置
- ✅ 自動處理依賴
- ✅ 已完全驗證可用
- ✅ 易於集成計時

**預期結果：**
```
平均執行時間: 4.57 秒
平均吞吐量: 4.37 tokens/s
```

**備選解決方案 B：設置 DLL 路徑（可能有風險）⚠️**

```powershell
# 1. 設置環境變數添加 DLL 位置
$env:PATH = "C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;" + $env:PATH

# 2. 嘗試執行
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    --mt 20 -n 1
```

**風險：** 仍可能失敗（版本不相容）

**終極解決方案 C：從源碼重新編譯**

如果 A、B 方案都不行，參考 STAGE_9_GUIDE.md 的「詳細步驟：從源碼編譯」章節重新編譯（需要 Visual Studio + CMake，時間 10-15 分鐘）。

---

#### Q2：找不到模型錯誤

```
Error loading model: File not found
```

**解決方案：**
```powershell
# 檢查模型是否存在
Test-Path ".\models\open_llama_7b_v2-int4-ov"

# 如果不存在，需要先下載模型（Stage 8）
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"
```

#### Q3：GPU 模式失敗

```
Device GPU is not available
```

**解決方案：**
```powershell
# 改用 CPU 模式
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d CPU `
    --mt 20 -n 1
```

#### Q4：執行檔無法運行

```
benchmark_genai.exe is not recognized
```

**解決方案：**
```powershell
# 確保在專案根目錄
cd C:\Users\svd\codes\openvino-lab

# 使用完整路徑
.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe -h
```

### 📊 性能比較：預編譯 vs 自行編譯

| 特性 | 預編譯執行檔 | 自行編譯 |
|------|-------------|----------|
| **設置時間** | 0 分鐘 ⭐ | 10-15 分鐘 |
| **需要工具** | 無 ⭐ | Visual Studio, CMake |
| **磁碟空間** | ~1 MB ⭐ | ~500 MB |
| **功能** | 完整 ✅ | 完整 ✅ |
| **性能** | 相同 ✅ | 相同 ✅ |
| **可自訂** | ❌ | ✅ |
| **適合對象** | 快速測試、一般用戶 | 開發者、需要修改源碼 |

**結論：** 對於**大多數用戶**，使用預編譯執行檔即可滿足需求，無需自行編譯。

---

## �📝 詳細步驟：從源碼編譯（進階用戶）

> **💡 提示：** 如果您只想使用 benchmark 功能，**可以跳過本章節**，直接使用上面的預編譯執行檔即可。以下內容適合想要：
> - 修改 benchmark 源碼
> - 了解編譯過程
> - 使用最新開發版本
> - 自訂編譯選項

的進階用戶。

### Step 1：檢查前置條件

```powershell
# 檢查 CMake
cmake --version
# 需要：CMake 3.13+
# 如果找不到命令，執行：winget install Kitware.CMake

# 檢查 Visual Studio（需要 C++ 編譯工具）
where cl
# 需要：Visual Studio 2019/2022 with C++ tools
# 如果找不到，執行：winget install Microsoft.VisualStudio.2022.BuildTools

# 檢查 Git
git --version
# 需要：Git 2.x+
```

**如果缺少工具，快速安裝：**

```powershell
# 安裝 CMake（必需）
winget install Kitware.CMake

# 重新載入 PATH（安裝後必須執行）
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 驗證 CMake
cmake --version

# 安裝 Visual Studio Build Tools（必需）
winget install Microsoft.VisualStudio.2022.BuildTools
```

> **⚠️ 重要提示：** 
> - 安裝 CMake 後，需要**重新啟動 PowerShell 終端機**或執行上述 PATH 刷新命令，`cmake` 命令才能被識別。
> - Visual Studio Build Tools 安裝後，需要**手動添加 C++ 工作負載**（詳見下方步驟）。

**使用圖形介面添加 C++ 工作負載：**

```powershell
# 啟動 Visual Studio Installer
Start-Process "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe"
```

然後在打開的視窗中：
1. 找到 **"Visual Studio Build Tools 2022"**
2. 點擊 **"修改"** 按鈕
3. 勾選 **"使用 C++ 的桌面開發"** (Desktop development with C++)
4. 點擊右下角的 **"修改"** 按鈕開始安裝
5. 等待 10-15 分鐘完成安裝

> **💡 提示：** 如果您覺得設置 C++ 編譯環境太複雜，可以**暫時跳過 Stage 9**，繼續使用 Stage 7 的 Python 推理功能即可。Benchmark 是進階功能，並非必需。

### Step 2：下載 OpenVINO GenAI 源碼

```powershell
# 創建源碼目錄
New-Item -ItemType Directory -Path "./src" -Force

# 克隆倉庫
cd src
git clone https://github.com/openvinotoolkit/openvino.genai.git
cd openvino.genai

# ⚠️ 重要：切換到與 OpenVINO 版本匹配的分支
git checkout releases/2025/4
git submodule update --init --recursive
```

### Step 3：編譯 OpenVINO GenAI C++ 庫

**⚠️ 注意：** 必須先編譯完整的 OpenVINO GenAI C++ 庫，才能編譯 benchmark 工具。

```powershell
# 創建編譯目錄
cd C:\Users\svd\codes\openvino-lab\src\openvino.genai
New-Item -ItemType Directory -Path "build_cpp" -Force
cd build_cpp

# 設置 OpenVINO 路徑（根據您的 Python 安裝位置調整）
$env:OpenVINO_DIR = "C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\cmake"

# 配置 CMake（使用 Visual Studio 2022 編譯器）
cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release -DENABLE_PYTHON=OFF

# 編譯（使用 8 個平行作業，約需 5-10 分鐘）
cmake --build . --config Release -j 8
```

**編譯成功後的產物：**
- ✅ **869 個編譯產物文件**（objects, libraries, executables）
- ✅ **openvino_genai.dll** (4.8 MB) - 主庫文件
- ✅ **依賴庫**：
  - `icudt70.dll`, `icuuc70.dll` (29 MB) - Unicode 支援
  - `openvino_tokenizers.dll` (2.5 MB) - Tokenizer 庫
  - `xgrammar.lib` (35 MB) - 語法生成庫
  - `gguflib.lib` (60 KB) - GGUF 格式支援

**驗證編譯結果：**
```powershell
# 檢查主庫
Test-Path ".\openvino_genai\openvino_genai.dll"  # 應該返回 True

# 檢查所有 DLL
Get-ChildItem -Path ".\openvino_genai" -Filter "*.dll"
```

**預計編譯時間：**
- CMake 配置：~2-3 分鐘
- 完整編譯：~5-10 分鐘（取決於 CPU 性能）
- 總計：**約 10-15 分鐘**

### Step 4：編譯 Benchmark 程式

現在編譯 benchmark_genai.exe 工具：

```powershell
# 進入 samples 目錄
cd C:\Users\svd\codes\openvino-lab\src\openvino.genai\samples\cpp\text_generation

# 創建 build 目錄
New-Item -ItemType Directory -Path "build_cpp" -Force
cd build_cpp

# 設置環境變數
$env:OpenVINO_DIR = "C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\cmake"
$env:OpenVINOGenAI_DIR = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp"

# 配置 CMake
cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release

# 編譯（約 1-2 分鐘）
cmake --build . --config Release
```

**編譯成功後：**
- ✅ **benchmark_genai.exe** (220 KB)
- 📂 位置：`Release\benchmark_genai.exe`
- 📂 完整路徑：`C:\Users\svd\codes\openvino-lab\src\openvino.genai\samples\cpp\text_generation\build_cpp\Release\benchmark_genai.exe`

**或者使用已編譯好的（推薦）：**
```powershell
# 主 build 中已經包含編譯好的 benchmark
$benchmarkPath = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
Test-Path $benchmarkPath  # 應該返回 True
```

### Step 5：運行 Benchmark

**⚠️ 重要：必須設置 DLL 路徑**

```powershell
# 設置 DLL 搜索路徑（必需！）
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;" + `
            "C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;" + `
            $env:PATH

# 進入 benchmark 目錄
cd C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release

# 執行 benchmark（基本用法）
.\benchmark_genai.exe `
    -m "C:\Users\svd\codes\openvino-lab\models\open_llama" `
    -d CPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1
```

**常見錯誤排除：**

1. **如果出現 DLL 缺失錯誤：**
   ```powershell
   # 確保已設置 PATH
   $env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;" + `
               "C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;" + `
               $env:PATH
   ```

2. **如果找不到模型：**
   ```powershell
   # 檢查模型路徑
   Test-Path "C:\Users\svd\codes\openvino-lab\models\open_llama"
   ```

3. **GPU 模式失敗：**
   - GPU 需要 Intel 集成顯卡或獨立 GPU
   - 如果沒有 GPU，使用 `-d CPU` 即可

---

---

## 🎯 在 PowerShell 中執行 Benchmark

由於 benchmark 工具的路徑和環境變數設置比較複雜，以下提供多種在 PowerShell 中執行的方法，從最簡單到最複雜。

### 方法 1：使用 Helper 腳本（推薦 - 最簡單）⭐⭐⭐

**優點：** 一行命令，自動處理所有複雜性

```powershell
# 基本用法（使用預設參數）
.\scripts\run_benchmark_easy.ps1

# 指定模型和設備
.\scripts\run_benchmark_easy.ps1 -Model "./models/open_llama" -Device CPU

# 完整參數
.\scripts\run_benchmark_easy.ps1 `
    -Model "./models/open_llama" `
    -Device CPU `
    -Prompt "The Sky is blue because" `
    -MaxTokens 20 `
    -NumWarmup 0 `
    -NumIter 5
```

**腳本功能：**
- ✅ 自動解析相對路徑為絕對路徑
- ✅ 自動設置 DLL 搜尋路徑
- ✅ 自動檢查模型和執行檔存在性
- ✅ 清晰的進度提示和錯誤信息

### 方法 2：參數陣列 + 完整路徑（推薦 - 穩健）⭐⭐⭐

**優點：** 不依賴助手腳本，完全控制，適合腳本化

```powershell
# 設置環境變數
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;" + `
            "C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;" + `
            $env:PATH

# 使用參數陣列執行
$benchmarkExe = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
$modelPath = "C:\Users\svd\codes\openvino-lab\models\open_llama"

$args = @(
    '-m', $modelPath,
    '-d', 'CPU',
    '-p', 'The Sky is blue because',
    '--nw', '0',
    '--mt', '20',
    '-n', '5'
)

& $benchmarkExe @args
```

### 方法 3：直接命令（簡潔方式）⭐⭐

**優點：** 直接、簡明，適合快速測試

```powershell
# 設置 PATH
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;$env:PATH"

# 執行（使用完整路徑）
& "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe" `
    -m "C:\Users\svd\codes\openvino-lab\models\open_llama" `
    -d CPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 5
```

### 方法 4：先 CD 再執行（傳統方式）⭐

**優點：** 熟悉的工作流，適合互動式使用

```powershell
# 1. 設置環境變數
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;" + `
            "C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;" + `
            $env:PATH

# 2. 進入正確目錄
cd "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release"

# 3. 執行（使用絕對路徑指定模型）
.\benchmark_genai.exe `
    -m "C:\Users\svd\codes\openvino-lab\models\open_llama" `
    -d CPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 5
```

---

### 對比表：各方法的優缺點

| 方法 | 簡單度 | 控制度 | 依賴性 | 適用場景 |
|------|--------|--------|--------|---------|
| **方法 1（Helper）** | ⭐⭐⭐ | ⭐⭐ | Helper 腳本 | 日常使用、自動化測試 |
| **方法 2（陣列）** | ⭐⭐ | ⭐⭐⭐ | 無 | 編寫複雜腳本、CI/CD |
| **方法 3（直接）** | ⭐⭐ | ⭐⭐⭐ | 無 | 一次性執行 |
| **方法 4（CD）** | ⭐⭐⭐ | ⭐⭐⭐ | 無 | 互動式工作、快速測試 |

---

### 實際使用範例

#### 場景 A：快速測試（1 次迭代）

```powershell
# 最簡單的方式
.\scripts\run_benchmark_easy.ps1 -Model "./models/open_llama" -Device CPU -NumIter 1
```

#### 場景 B：準確測試（5 次迭代取平均）

```powershell
# 使用 Helper 腳本
.\scripts\run_benchmark_easy.ps1 `
    -Model "./models/open_llama" `
    -Device CPU `
    -NumWarmup 2 `
    -MaxTokens 50 `
    -NumIter 5
```

#### 場景 C：批次測試多個配置

```powershell
# 使用參數陣列，編寫循環腳本
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;$env:PATH"

$benchmarkExe = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
$modelPath = "C:\Users\svd\codes\openvino-lab\models\open_llama"

$devices = @("CPU", "GPU")
$tokenCounts = @(20, 50, 100)

foreach ($device in $devices) {
    foreach ($tokens in $tokenCounts) {
        Write-Host "`n[*] Testing: Device=$device, MaxTokens=$tokens" -ForegroundColor Cyan
        
        $args = @(
            '-m', $modelPath,
            '-d', $device,
            '-p', 'The Sky is blue because',
            '--nw', '2',
            '--mt', [string]$tokens,
            '-n', '3'
        )
        
        & $benchmarkExe @args
    }
}
```

#### 場景 D：保存結果到文件

```powershell
# 執行 benchmark 並保存結果
$output = & "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe" `
    -m "C:\Users\svd\codes\openvino-lab\models\open_llama" `
    -d CPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1

# 保存到文件
$output | Out-File -FilePath "benchmark_result_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt" -Encoding UTF8

Write-Host "結果已保存" -ForegroundColor Green
```

---

### PowerShell 最佳實踐

#### 1. 設置會話級別環境變數（推薦）

```powershell
# 在 PowerShell 開啟時執行一次，所有後續命令都能使用
$env:BENCHMARK_EXE = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
$env:BENCHMARK_MODEL = "C:\Users\svd\codes\openvino-lab\models\open_llama"
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;$env:PATH"

# 之後可直接使用
& $env:BENCHMARK_EXE -m $env:BENCHMARK_MODEL -d CPU --mt 20 -n 1
```

#### 2. 建立 PowerShell 配置檔案（高級）

如果你經常使用，可以在 PowerShell 配置檔案中設置環境變數。

```powershell
# 尋找你的 PowerShell 配置檔案路徑
$PROFILE

# 編輯配置檔案（如不存在會自動建立）
notepad $PROFILE
```

在檔案中加入：

```powershell
# OpenVINO Benchmark 環境設置
$env:BENCHMARK_EXE = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
$env:BENCHMARK_MODEL = "C:\Users\svd\codes\openvino-lab\models\open_llama"
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;$env:PATH"

# 定義便捷函數
function Run-Benchmark {
    param(
        [string]$Model = $env:BENCHMARK_MODEL,
        [string]$Device = "CPU",
        [string]$Prompt = "The Sky is blue because",
        [int]$MaxTokens = 20,
        [int]$NumWarmup = 0,
        [int]$NumIter = 1
    )
    
    & $env:BENCHMARK_EXE `
        -m $Model `
        -d $Device `
        -p $Prompt `
        --nw $NumWarmup `
        --mt $MaxTokens `
        -n $NumIter
}

# 之後只需輸入
# Run-Benchmark -Device CPU -MaxTokens 20 -NumIter 5
```

重新啟動 PowerShell，配置會自動載入。

#### 3. 建立 PowerShell 別名（便捷）

```powershell
# 為 benchmark 創建簡短別名
Set-Alias -Name bench -Value "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"

# 之後只需：
bench -m "C:\Users\svd\codes\openvino-lab\models\open_llama" -d CPU --mt 20 -n 1
```

---

### 常見問題與解決

#### Q1：為什麼需要設置 `$env:PATH`？

**A：** `benchmark_genai.exe` 依賴多個 DLL 文件：
- `openvino_genai.dll`（GenAI 主庫）
- `openvino_tokenizers.dll`（分詞器）
- `icudt70.dll`, `icuuc70.dll`（Unicode 支援）

Windows 需要知道這些 DLL 在哪裡，所以必須添加到 `PATH` 環境變數。

#### Q2：可以不設置 `PATH` 嗎？

**A：** 可以，但要複製 DLL 文件到執行檔目錄或當前目錄：

```powershell
# 複製 DLL 到 benchmark 執行檔目錄
Copy-Item "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai\*.dll" `
          "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\" `
          -Force

# 之後不需要設置 PATH，直接執行
.\benchmark_genai.exe -m "C:\Users\svd\codes\openvino-lab\models\open_llama" -d CPU --mt 20 -n 1
```

但**不推薦**，因為會產生重複檔案。

#### Q3：如何重複執行，但每次參數不同？

**A：** 使用函數或循環：

```powershell
# 函數方式
function Test-Benchmark {
    param([string]$Device, [int]$Tokens)
    
    $env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;$env:PATH"
    
    & "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe" `
        -m "C:\Users\svd\codes\openvino-lab\models\open_llama" `
        -d $Device `
        -p "The Sky is blue because" `
        --nw 0 `
        --mt $Tokens `
        -n 3
}

# 執行
Test-Benchmark -Device CPU -Tokens 20
Test-Benchmark -Device CPU -Tokens 50
Test-Benchmark -Device GPU -Tokens 20
```

---

## 📊 Benchmark 參數說明

### 命令參數

```bash
benchmark_genai.exe [OPTIONS]
```

| 參數 | 全名 | 說明 | 預設值 | 範例 |
|------|------|------|--------|------|
| `-m` | `--model` | 模型路徑 | 必需 | `./models/open_llama` |
| `-d` | `--device` | 推理設備 | `CPU` | `CPU`, `GPU`, `NPU` |
| `-p` | `--prompt` | 測試提示詞 | `""` | `"The Sky is blue because"` |
| `--nw` | `--num-warmup` | 預熱次數 | `1` | `0`（跳過預熱）, `5` |
| `--mt` | `--max-tokens` | 最大生成令牌數 | `20` | `10`, `50`, `100` |
| `-n` | `--num-iter` | 測試迭代次數 | `3` | `1`, `5`, `10` |
| `--pf` | *(file)* | 從文件讀取提示詞 | - | `prompts.txt` |
| `-h` | `--help` | 顯示幫助信息 | - | - |

**⚠️ 重要：參數格式規則**
- 單字母參數：`-m`, `-d`, `-p`, `-n` → 使用**單破折號**
- 多字母參數：`--nw`, `--mt`, `--pf` → 使用**雙破折號**
- 錯誤示例：`-nw` ❌ `-mt` ❌（會導致 "Argument 'w' failed to parse" 錯誤）
- 正確示例：`--nw` ✅ `--mt` ✅

### 範例命令

#### 1. CPU 基準測試（預設）

```powershell
.\benchmark_genai.exe `
    -m "path/to/model" `
    -d CPU `
    -p "What is AI?" `
    --mt 50
```

#### 2. GPU 基準測試（推薦）

```powershell
.\benchmark_genai.exe `
    -m "path/to/model" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1
```

**⚠️ 重要提示：參數格式**
- `--nw` 使用**雙破折號**（不是 `-nw`）
- `--mt` 使用**雙破折號**（不是 `-mt`）
- 單字母參數用單破折號：`-m`, `-d`, `-p`, `-n`

#### 3. 多次迭代測試（更準確）

```powershell
.\benchmark_genai.exe `
    -m "path/to/model" `
    -d GPU `
    -p "Explain quantum computing" `
    --nw 3 `
    --mt 100 `
    -n 10
```

#### 4. 跳過預熱（快速測試）

```powershell
.\benchmark_genai.exe `
    -m "path/to/model" `
    -d CPU `
    -p "Hello world" `
    --nw 0 `
    --mt 20 `
    -n 1
```

#### 5. 實際測試命令（已驗證✅）

```powershell
# 設置環境變數（必需）
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;" + `
            "C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;" + `
            $env:PATH

# 執行 benchmark
cd C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release
.\benchmark_genai.exe `
    -m "C:\Users\svd\codes\openvino-lab\models\open_llama" `
    -d CPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1
```

---

## 📈 理解 Benchmark 輸出

### 典型輸出範例

```
Loading model: ./models/open_llama_7b_v2-int4-ov
Device: GPU

Prompt: "The Sky is blue because"
Max new tokens: 20

Running warmup iterations: 0
Running benchmark iterations: 1

=== Benchmark Results ===

Generation time: 2.456 seconds
Total tokens generated: 20
Throughput: 8.14 tokens/second

Time to first token (TTFT): 245 ms
Average token latency: 123 ms

Prompt processing time: 156 ms
Generation time (pure): 2.300 seconds
```

### 關鍵指標解釋

| 指標 | 英文 | 說明 | 理想值 |
|------|------|------|--------|
| **吞吐量** | Throughput | 每秒生成令牌數 | 越高越好（> 10 tok/s） |
| **首字延遲** | TTFT (Time To First Token) | 第一個字出現的時間 | 越低越好（< 500ms） |
| **平均延遲** | Average Token Latency | 每個令牌平均生成時間 | 越低越好（< 200ms） |
| **生成時間** | Generation Time | 總生成時間 | 取決於令牌數 |

### 性能等級參考

#### CPU 性能

| 等級 | 吞吐量 (tok/s) | 首字延遲 (ms) | 評價 |
|------|---------------|--------------|------|
| 優秀 | > 30 | < 200 | ⭐⭐⭐⭐⭐ |
| 良好 | 20-30 | 200-400 | ⭐⭐⭐⭐ |
| 可用 | 10-20 | 400-800 | ⭐⭐⭐ |
| 緩慢 | 5-10 | 800-1500 | ⭐⭐ |
| 很慢 | < 5 | > 1500 | ⭐ |

#### GPU 性能

| 等級 | 吞吐量 (tok/s) | 首字延遲 (ms) | 評價 |
|------|---------------|--------------|------|
| 優秀 | > 100 | < 100 | ⭐⭐⭐⭐⭐ |
| 良好 | 50-100 | 100-200 | ⭐⭐⭐⭐ |
| 可用 | 30-50 | 200-400 | ⭐⭐⭐ |
| 一般 | 15-30 | 400-800 | ⭐⭐ |
| 待優化 | < 15 | > 800 | ⭐ |

---

## 🔬 進階測試場景

### 場景 1：CPU vs GPU 性能對比

```powershell
# CPU 測試
.\benchmark_genai.exe -m "./models/open_llama_7b_v2-int4-ov" -d CPU -p "Test" -mt 50 -n 5

# GPU 測試
.\benchmark_genai.exe -m "./models/open_llama_7b_v2-int4-ov" -d GPU -p "Test" -mt 50 -n 5

# 比較結果
```

### 場景 2：不同提示詞長度的影響

```powershell
# 短提示詞
.\benchmark_genai.exe -m "model" -d GPU -p "Hi" -mt 50

# 中等提示詞
.\benchmark_genai.exe -m "model" -d GPU -p "Explain machine learning in detail" -mt 50

# 長提示詞
.\benchmark_genai.exe -m "model" -d GPU -p "Write a comprehensive essay about artificial intelligence, including its history, current applications, and future implications for society" -mt 50
```

### 場景 3：不同生成長度的性能

```powershell
# 短文本生成
.\benchmark_genai.exe -m "model" -d GPU -p "Test" -mt 10

# 中等文本生成
.\benchmark_genai.exe -m "model" -d GPU -p "Test" -mt 50

# 長文本生成
.\benchmark_genai.exe -m "model" -d GPU -p "Test" -mt 200
```

### 場景 4：批次測試（平均值）

**⭐ 使用 Helper 腳本（推薦）：**
```powershell
# 簡單方式 - 執行 10 次取平均
.\scripts\run_benchmark_easy.ps1 -Model "./models/open_llama" -Device CPU -NumWarmup 3 -MaxTokens 20 -NumIter 10
```

**手動方式（需先設置環境）：**
```powershell
# 1. 設置環境變數
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;" + `
            "C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;" + `
            $env:PATH

# 2. 進入正確目錄
cd "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release"

# 3. 執行 benchmark（執行 10 次取平均）
.\benchmark_genai.exe `
    -m "C:\Users\svd\codes\openvino-lab\models\open_llama" `
    -d CPU `
    -p "The Sky is blue because" `
    --nw 3 `
    --mt 20 `
    -n 10
```

**⚠️ 重點：**
- 使用 helper 腳本時，無需手動設置路徑和 cd 目錄
- 手動方式時，必須先 `cd` 到 benchmark 執行檔所在目錄
- 使用絕對路徑避免「找不到模型」的錯誤

---

## 🛠️ 使用包裝腳本（簡化操作）

### Python 包裝腳本

我已為您準備了 Python 包裝腳本，簡化 benchmark 執行：

```powershell
# 基本用法
python scripts/run_benchmark.py `
    --model "./models/open_llama_7b_v2-int4-ov" `
    --device GPU

# 完整參數
python scripts/run_benchmark.py `
    --model "./models/open_llama_7b_v2-int4-ov" `
    --device GPU `
    --prompt "The Sky is blue because" `
    --max-tokens 20 `
    --num-iter 5 `
    --num-warmup 2
```

### PowerShell 互動式腳本

```powershell
# 執行互動式 benchmark
.\scripts\benchmark\run_benchmark.ps1

# 會提示您選擇：
# 1. 選擇模型（自動掃描 ./models）
# 2. 選擇設備（CPU/GPU/NPU）
# 3. 輸入提示詞（或使用預設）
# 4. 設定參數（或使用預設）
```

---

## 📊 結果分析與優化建議

### 分析 Benchmark 結果

#### 吞吐量低（< 10 tok/s on GPU）

**可能原因：**
1. GPU 驅動未正確安裝
2. 模型量化不夠（使用 int8 或 int4）
3. 批次大小太小

**優化建議：**
```powershell
# 檢查 GPU 驅動
nvidia-smi

# 使用更小的量化模型（int4）
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"
```

#### 首字延遲高（> 500ms）

**可能原因：**
1. 模型加載時間
2. 提示詞編碼時間
3. GPU 預熱不足

**優化建議：**
```powershell
# 增加預熱次數
.\benchmark_genai.exe ... -nw 5

# 使用較短的提示詞
.\benchmark_genai.exe ... -p "Test"
```

#### 記憶體不足

**可能原因：**
1. 模型太大
2. 生成長度太長

**優化建議：**
```powershell
# 減少最大令牌數
.\benchmark_genai.exe ... -mt 20

# 使用更小的模型
# TinyLlama 1.1B 而非 OpenLLaMA 7B
```

---

## 🔧 故障排除

### ❌ 錯誤：找不到 benchmark_genai.exe（最常見）

```
'.\benchmark_genai.exe' is not recognized as the name of a cmdlet...
```

**原因：** 執行檔不在目前目錄，而在 `src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\`

**解決方案：**

**方案 A：使用 Helper 腳本（推薦）✅**
```powershell
# 從任何目錄執行，自動處理路徑
.\scripts\run_benchmark_easy.ps1 -Model "./models/open_llama" -Device CPU -NumIter 1
```

**方案 B：手動方式**
```powershell
# 1. 進入正確目錄
cd "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release"

# 2. 或使用完整路徑
$benchmarkExe = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
& $benchmarkExe -m "C:\Users\svd\codes\openvino-lab\models\open_llama" -d CPU -p "Test" --mt 20 -n 1
```

### ❌ 錯誤：找不到 benchmark_genai.exe

```
Error loading model: File not found
```

**解決方案：**
```powershell
# 確認模型路徑
ls ./models/open_llama_7b_v2-int4-ov

# 使用絕對路徑
$modelPath = (Resolve-Path "./models/open_llama_7b_v2-int4-ov").Path
.\benchmark_genai.exe -m "$modelPath" ...
```

### ❌ 錯誤：找不到 cmake 命令

```
cmake : The term 'cmake' is not recognized as the name of a cmdlet...
```

**解決方案：**
```powershell
# 方法 1：使用 winget 安裝 CMake（推薦）
winget install Kitware.CMake

# 方法 2：重新啟動 PowerShell 終端機
# 關閉目前終端機並開啟新的 PowerShell

# 方法 3：手動刷新 PATH（在目前終端機）
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 驗證安裝
cmake --version
```

### ❌ 錯誤：CMake 找不到 Visual Studio

```
CMake Error: Generator 'Visual Studio 17 2022' could not find any instance of Visual Studio.
```

**原因：** Visual Studio Build Tools 已安裝，但缺少 C++ 工作負載。

**解決方案（圖形介面 - 推薦）：**

```powershell
# 1. 啟動 Visual Studio Installer
Start-Process "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe"
```

在打開的視窗中：
1. 找到 **"Visual Studio Build Tools 2022"**
2. 點擊 **"修改"** (Modify) 按鈕
3. 在工作負載列表中，勾選：
   - ✅ **"使用 C++ 的桌面開發"** (Desktop development with C++)
4. 點擊右下角的 **"修改"** 按鈕
5. 等待下載和安裝完成（約 10-15 分鐘，約 2-3 GB）

**解決方案（命令行 - 進階）：**

```powershell
# 關閉所有 Visual Studio Installer 實例後執行
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" modify `
    --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --includeRecommended `
    --passive
```

**安裝完成後驗證：**

```powershell
# 驗證 C++ 編譯器
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" `
    -latest `
    -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    -property installationPath

# 應該顯示：C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools
```

### ❌ 錯誤：CMake 配置失敗

```
CMake Error: Could not find CMAKE_C_COMPILER
```

**解決方案：**
```powershell
# 安裝 Visual Studio Build Tools
winget install Microsoft.VisualStudio.2022.BuildTools

# 或使用 Visual Studio Installer 安裝 "Desktop development with C++"
```

### ❌ 錯誤：GPU 不可用

```
Device GPU is not available
```

**解決方案：**
```powershell
# 檢查 GPU 驅動
nvidia-smi

# 使用 CPU 代替
.\benchmark_genai.exe -m "model" -d CPU ...

# 或安裝 OpenVINO GPU 插件
pip install openvino-gpu-plugin
```

### ❌ 錯誤：記憶體不足

```
Out of memory error
```

**解決方案：**
```powershell
# 關閉其他應用程式
# 減少生成長度
.\benchmark_genai.exe ... -mt 10

# 使用更小的模型
```

---

## 📖 相關文檔

- [OpenVINO GenAI Benchmark 源碼](https://github.com/openvinotoolkit/openvino.genai/blob/master/samples/cpp/text_generation/benchmark_genai.cpp)
- [`STAGE_8_GUIDE.md`](STAGE_8_GUIDE.md) - 大型模型下載
- [`STAGE_7_GUIDE_NEW.md`](STAGE_7_GUIDE_NEW.md) - 基礎推理
- [`../DOWNLOAD_HF_MODEL_GUIDE.md`](../DOWNLOAD_HF_MODEL_GUIDE.md) - 模型下載指南

---

## 💡 最佳實踐

### Benchmark 前的準備

- ✅ 確保系統空閒（關閉不必要的程式）
- ✅ 使用穩定的電源（筆記本插電）
- ✅ GPU 溫度正常（< 80°C）
- ✅ 執行多次取平均值（`-n 5` 或更多）

### Benchmark 參數建議

| 目的 | 預熱次數 | 迭代次數 | 生成長度 |
|------|---------|---------|---------|
| 快速測試 | 0 | 1 | 20 |
| 常規測試 | 2 | 5 | 50 |
| 精確測試 | 5 | 10 | 100 |
| 壓力測試 | 3 | 10 | 200 |

### 記錄結果

建議建立 benchmark 結果記錄表：

```markdown
| 日期 | 模型 | 設備 | 吞吐量 | 首字延遲 | 備註 |
|------|------|------|--------|---------|------|
| 2025-12-30 | OpenLLaMA 7B int4 | GPU | 45 tok/s | 180ms | 預設配置 |
| 2025-12-30 | OpenLLaMA 7B int4 | CPU | 12 tok/s | 850ms | 預設配置 |
```

---

## 🎓 進階主題

### 自訂 Benchmark 腳本

您可以修改 C++ 源碼來自訂 benchmark 行為：

```cpp
// 位置：samples/cpp/text_generation/benchmark_genai.cpp

// 自訂配置
config.max_new_tokens = 100;
config.temperature = 0.7;
config.top_p = 0.9;

// 添加自訂指標
auto start = std::chrono::high_resolution_clock::now();
// ... 執行推理
auto end = std::chrono::high_resolution_clock::now();
auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
```

### 批次處理多個提示詞

```powershell
# 創建提示詞文件
$prompts = @(
    "What is AI?",
    "Explain quantum computing",
    "The history of computers"
)

foreach ($prompt in $prompts) {
    Write-Host "Testing prompt: $prompt" -ForegroundColor Cyan
    .\benchmark_genai.exe -m "model" -d GPU -p "$prompt" -mt 50 -n 3
    Write-Host ""
}
```

### 導出結果到 CSV

```powershell
# 使用 Python 腳本導出
python scripts/run_benchmark.py `
    --model "./models/open_llama_7b_v2-int4-ov" `
    --device GPU `
    --output results.csv `
    --num-iter 10
```

---

## 📦 編譯結果總結

### 成功編譯的產物

#### 1. OpenVINO GenAI C++ 主庫
- **編譯時間**：約 5-10 分鐘（8 核心平行編譯）
- **產物數量**：869 個文件（objects, libraries, executables）
- **主庫文件**：
  - `openvino_genai.dll` (4.8 MB) - 主動態連結庫
  - `openvino_genai_c.dll` (133 KB) - C 語言綁定
  - `openvino_tokenizers.dll` (2.5 MB) - Tokenizer 支援

#### 2. 依賴庫
- **ICU (Unicode 支援)**：
  - `icudt70.dll` (29.5 MB) - Unicode 資料
  - `icuuc70.dll` (2.2 MB) - Unicode 通用庫
  - 17 個靜態庫 (.lib) 文件
  
- **文法生成庫**：
  - `xgrammar.lib` (35 MB) - 結構化輸出支援
  
- **模型格式支援**：
  - `gguflib.lib` (60 KB) - GGUF 格式讀取

#### 3. Benchmark 工具
- **編譯時間**：約 1-2 分鐘
- **可執行文件**：
  - `benchmark_genai.exe` (220 KB) - C++ 版本
  - `benchmark_genai_c.exe` (16 KB) - C 版本
  
- **位置**：
  ```
  C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\
    ├── openvino_genai\              # DLL 目錄
    │   ├── openvino_genai.dll
    │   ├── icudt70.dll
    │   ├── icuuc70.dll
    │   └── openvino_tokenizers.dll
    └── samples\cpp\text_generation\Release\
        └── benchmark_genai.exe       # Benchmark 工具
  ```

#### 4. 實測性能基準
- **測試環境**：Windows 11, CPU 模式
- **模型**：open_llama (4.25 GB, INT4 量化)
- **結果**：
  - 吞吐量：**14.99 tokens/秒**
  - 首 Token 時間：2.31 秒
  - 每 Token 時間：66.73 ms
  - 模型加載時間：4.89 秒

---

## ⚠️ 已知限制與注意事項

### 編譯相關

1. **必須使用匹配的版本分支**
   - ✅ 使用 `releases/2025/4` 分支（與 Python OpenVINO 2025.4.1 匹配）
   - ❌ 不要使用 `master` 分支（需要 OpenVINO 2026.0.0）

2. **DLL 路徑設置是必需的**
   ```powershell
   # 每次運行前必須設置
   $env:PATH = "<genai_dlls>;<openvino_dlls>;$env:PATH"
   ```

3. **參數格式嚴格要求**
   - 單字母：`-m`, `-d`, `-p`, `-n`（單破折號）
   - 多字母：`--nw`, `--mt`, `--pf`（雙破折號）
   - ❌ 錯誤：`-nw`, `-mt` 會導致解析錯誤

### GPU 模式限制

- GPU 模式需要 Intel 集成顯卡或獨立 GPU
- 如果沒有 GPU 或驅動未安裝，會執行失敗（無錯誤訊息）
- **建議**：優先使用 CPU 模式進行測試

### 建議替代方案

如果編譯過程遇到困難：
- ✅ 使用 **Stage 7 的 Python 推理腳本**（功能完整、設置簡單）
- ✅ 使用提供的 `quick_benchmark.ps1` 互動式工具
- ✅ Python 腳本也可以測量推理性能（通過計時實現）

> **✅ 實際驗證（2025-12-30）**：
> - Visual Studio Build Tools 2022 + C++ 工作負載安裝成功
> - CMake 4.2.1 正確識別 MSVC 19.44 編譯器
> - OpenVINO GenAI C++ 庫編譯成功（869 個產物文件）
> - benchmark_genai.exe 成功編譯並運行
> - 實測性能：open_llama CPU 模式 14.99 tokens/s

---

## ✅ 檢查清單

完成 Stage 9 後，確認以下項目：

**環境設置：**
- [x] CMake 已安裝（版本 ≥ 3.13，建議 4.2.1）
- [x] Visual Studio Build Tools 2022 已安裝
- [x] C++ 工作負載已安裝（MSVC ≥ 19.44）
- [x] Git 已安裝並能正常使用

**源碼與編譯：**
- [x] OpenVINO GenAI 源碼已克隆
- [x] 已切換到正確的分支（`releases/2025/4`）
- [x] 子模組已更新（`git submodule update --init --recursive`）
- [x] OpenVINO GenAI C++ 庫已成功編譯
  - [x] openvino_genai.dll (4.8 MB) 存在
  - [x] 依賴庫（ICU, xgrammar, gguflib）已編譯
- [x] benchmark_genai.exe 已成功編譯（220 KB）

**測試與驗證：**
- [x] DLL 路徑已正確設置
- [x] 至少完成一次 CPU benchmark
- [ ] 至少完成一次 GPU benchmark（如果有 GPU）
- [x] 記錄了關鍵性能指標（吞吐量、TTFT、TPOT）
- [x] 理解了 benchmark 輸出含義
- [x] 了解正確的參數格式（--nw, --mt）

---

## 📝 總結

**Stage 9 完成後：**

✅ 您已成功使用 benchmark 工具測試模型性能  
✅ 了解了關鍵性能指標（吞吐量、TTFT、TPOT）  
✅ 可以比較不同配置的性能差異  
✅ 掌握了正確的命令參數格式  

**兩種使用方式：**

1. **預編譯執行檔（推薦）⭐**
   - ✅ 無需安裝開發工具
   - ✅ 立即可用
   - ✅ 位置：`nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe`
   
2. **從源碼編譯（進階）**
   - ✅ 可自訂修改
   - ✅ 使用最新版本
   - ⏱️ 編譯時間：10-15 分鐘

**實際性能數據：**
- **CPU 模式：** 14.99 tokens/s
- **GPU 模式：** 11.05 tokens/s
- **首 Token 時間：** 131-2308 ms
- **模型加載時間：** 4.9-5.9 秒

**下一步：**

- 🎯 根據 benchmark 結果優化配置
- 📊 測試不同模型和量化方案
- 🔄 比較 CPU vs GPU 性能
- 🚀 應用到實際項目中
- 📝 撰寫性能報告

---

**Stage 9 狀態：** ✅ 已完成！（提供預編譯執行檔 + 編譯指南）  
**難度等級：** 
- 使用預編譯：⭐ (簡單)
- 從源碼編譯：⭐⭐⭐⭐ (進階)  
**最後更新：** 2025-12-30 / 2026-01-02  
**版本：** 2.0
