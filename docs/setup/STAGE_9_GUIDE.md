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
| 沒有 C++ 編譯環境 | ❌ 不建議（需要額外設置） |
| 不想花時間設置編譯工具 | ❌ 可跳過（非必需功能） |

> **💡 重要提醒：** Stage 9 需要安裝 **Visual Studio Build Tools** 及 **C++ 工作負載**（約 3 GB），並需要編譯 C++ 程式。如果您只是想快速使用 OpenVINO 進行推理，**Stage 7 已經足夠**，可以跳過此階段。

---

## 🚀 快速開始

### 前置準備

```powershell
# 1. 確保已完成 Stage 8（下載大型模型）
ls ./models/open_llama_7b_v2-int4-ov

# 2. 確保虛擬環境已激活
.\venv\Scripts\Activate.ps1
```

### 方法 1：使用 Python 包裝腳本（推薦 - 最簡單）

```powershell
# 運行 benchmark（自動處理編譯）
python scripts/run_benchmark.py `
    --model "./models/open_llama_7b_v2-int4-ov" `
    --device GPU `
    --prompt "The Sky is blue because"
```

### 方法 2：使用 PowerShell 包裝（互動式）

```powershell
# 執行互動式 benchmark
.\scripts\run_benchmark.ps1
```

### 方法 3：直接使用 C++ Benchmark（進階用戶）

```powershell
# 手動編譯並執行（需要 CMake 和 Visual Studio）
# 詳見下方詳細步驟
```

---

## 📝 詳細步驟：設置 Benchmark 環境

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

```powershell
# 執行 10 次取平均
.\benchmark_genai.exe `
    -m "./models/open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    -nw 3 `
    -mt 20 `
    -n 10
```

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
.\scripts\run_benchmark.ps1

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

### ❌ 錯誤：找不到 benchmark_genai.exe

```
'benchmark_genai.exe' is not recognized
```

**解決方案：**
```powershell
# 檢查編譯是否成功
ls ./src/openvino.genai/samples/cpp/text_generation/build/Release/benchmark_genai.exe

# 如果不存在，重新編譯
cd ./src/openvino.genai/samples/cpp/text_generation/build
cmake --build . --config Release
```

### ❌ 錯誤：找不到模型文件

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

✅ 您已成功編譯 OpenVINO GenAI C++ 庫（869 個產物文件）  
✅ 成功編譯並運行官方 benchmark 工具  
✅ 了解了關鍵性能指標（吞吐量 14.99 tokens/s）  
✅ 可以比較不同配置的性能差異  
✅ 掌握了正確的命令參數格式  

**實際編譯時間：**
- CMake 配置：2-3 分鐘
- OpenVINO GenAI C++ 庫：5-10 分鐘
- Benchmark 工具：1-2 分鐘
- **總計：約 10-15 分鐘**

**下一步：**

- 🎯 根據 benchmark 結果優化配置
- 📊 測試不同模型和量化方案
- 🔄 比較 CPU vs GPU 性能（如果有 GPU）
- 🚀 應用到實際項目中
- 📝 撰寫性能報告

---

**Stage 9 狀態：** 🔬 進階性能測試（需要 C++ 編譯環境）  
**難度等級：** ⭐⭐⭐⭐ (進階)  
**最後更新：** 2025-12-30  
**版本：** 1.0
