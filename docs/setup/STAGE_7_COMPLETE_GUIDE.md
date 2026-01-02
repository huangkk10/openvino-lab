# 第 7️⃣ 階段：推理設置完整指南

本指南涵蓋 OpenVINO GenAI 環境設置的第 7 階段：設置並運行 AI 模型推理。

---

## 📋 目錄

- [概述](#概述)
- [前置條件](#前置條件)
- [必要套件](#必要套件)
- [快速開始](#快速開始)
  - [單次推理](#方式-a單次推理快速測試)
  - [交互式模式](#方式-b交互式模式推薦)
  - [演示模式](#方式-c演示模式)
- [詳細使用說明](#詳細使用說明)
- [推理參數說明](#推理參數說明)
- [實際測試結果](#實際測試結果)
- [常見問題](#常見問題)
- [故障排除](#故障排除)

---

## 概述

**目標：** 使用 TinyLlama-1.1B 模型執行 AI 推理任務，驗證整個環境設置的完整性。

**所需時間：**
- 快速開始：2-3 分鐘（首次自動下載模型 ~2.2GB）
- 完整設置：5-10 分鐘

**核心組件：**
- **模型**：TinyLlama-1.1B-Chat-v1.0 (PyTorch)
- **推理框架**：Hugging Face Transformers
- **運行環境**：Python 虛擬環境

---

## 前置條件

✅ 已完成以下階段：
- [第 1 階段：前置準備](README.md#第-1️⃣-階段前置準備)
- [第 2 階段：系統依賴](STAGE_2_GUIDE.md)
- [第 3 階段：虛擬環境](README.md#第-3️⃣-階段虛擬環境)
- [第 4 階段：套件安裝](README.md#第-4️⃣-階段套件安裝)
- [第 5 階段：環境驗證](README.md#第-5️⃣-階段環境驗證)
- [第 6 階段：配置設置](STAGE_6_GUIDE.md)

✅ 已驗證：
```powershell
python scripts/test_openvino.py
```

應該輸出：
```
✓ OpenVINO GenAI 導入成功
✓ OpenVINO 導入成功
✓ OpenVINO Tokenizers 導入成功
✓ Optimum Intel 導入成功
```

---

## 必要套件

### 核心套件（requirements.txt）

以下套件已通過 `pip install -r requirements.txt` 安裝：

```
torch==2.9.1              # PyTorch 深度學習框架
transformers==4.57.3      # Hugging Face Transformers
openvino==2025.4.1        # OpenVINO 推理引擎
openvino-genai==2025.4.1  # OpenVINO GenAI
```

### 額外套件（Stage 7 專用）

```powershell
pip install python-dotenv  # 加載 .env 環境變數
pip install accelerate     # 加速模型加載
pip install hf_xet        # 加速 Hugging Face 下載（可選）
```

### 驗證安裝

```powershell
# 啟動虛擬環境
.\venv\Scripts\Activate.ps1

# 驗證關鍵套件
python -c "import torch; print('PyTorch:', torch.__version__)"
python -c "import transformers; print('Transformers:', transformers.__version__)"
python -c "from dotenv import load_dotenv; print('python-dotenv: OK')"
```

---

## 快速開始

### 步驟 1：激活虛擬環境

```powershell
cd c:\Users\svd\codes\openvino-lab
.\venv\Scripts\Activate.ps1
```

✅ 您應該看到 `(venv)` 前綴在命令提示符前面

### 步驟 2：運行推理

選擇以下任意方式開始推理：

---

#### 方式 A：單次推理（快速測試）

**用途**：快速測試推理功能，獲得單個答案

```powershell
python scripts/run_inference_simple.py --prompt "What is machine learning?"
```

**參數說明**：
- `--prompt` - 輸入提示文本
- `--max-tokens` - 最大生成 token 數（可選，默認 100）
- `--device` - 推理設備（可選，CPU/GPU，默認自動）

**範例**：

```powershell
# 簡短答案
python scripts/run_inference_simple.py --prompt "What is AI?" --max-tokens 30

# 較長答案
python scripts/run_inference_simple.py --prompt "Explain machine learning" --max-tokens 150

# 指定 GPU
python scripts/run_inference_simple.py --prompt "What is Python?" --device GPU
```

**預期輸出**：
```
============================================================
                       TinyLlama 推理示例
============================================================

📝 輸入提示: What is machine learning?
⚙️  參數設置:
   - device: AUTO
   - max_tokens: 100
   - temperature: 0.7
   - top_p: 0.9

💻 推理設備: CPU

⏳ 正在加載分詞器...
✅ 分詞器加載成功
⏳ 正在加載模型（首次會下載，約 2.2GB）...
✅ 模型加載成功

⏳ 正在準備輸入（使用 Chat 模板）...
✅ 輸入已準備

⏳ 正在生成文本...

============================================================
📤 生成結果:
============================================================
[生成的文本...]
============================================================
```

---

#### 方式 B：交互式模式（推薦）

**用途**：連續進行多次推理，無需重複加載模型

```powershell
python scripts/run_inference_simple.py
```

**使用說明**：

```
============================================================
                   TinyLlama 交互式推理
============================================================

設備: AUTO
最大令牌數: 100
溫度: 0.7

輸入 'exit' 或 'quit' 退出

============================================================

⏳ 正在加載分詞器...
✅ 分詞器已加載
⏳ 正在加載模型...
✅ 模型已加載

>>> 請輸入提示文本: What is Python?

⏳ 正在生成...

✅ 結果:
Python is a high-level programming language known for its simplicity...

------------------------------------------------------------

>>> 請輸入提示文本: Explain AI

⏳ 正在生成...

✅ 結果:
Artificial Intelligence (AI) refers to the development of computer systems...

------------------------------------------------------------

>>> 請輸入提示文本: exit

👋 再見！
```

**優點**：
- ✅ 模型只加載一次
- ✅ 多次推理無需重新加載
- ✅ 適合探索式使用
- ✅ 更快的迭代速度

---

#### 方式 C：演示模式

**用途**：自動運行預設的示範提示

```powershell
python scripts/run_inference_simple.py demo
```

**自動運行**：
1. "What is Python?"
2. "Explain machine learning in simple terms."
3. "How does artificial intelligence work?"

**用途**：
- 驗證環境設置
- 展示模型能力
- 測試不同類型的提示

---

## 詳細使用說明

### 推理腳本位置

```
scripts/run_inference_simple.py
└─ 核心推理腳本
   ├─ 自動下載模型（TinyLlama-1.1B）
   ├─ 支持 Chat 模板格式化
   ├─ 支持三種運行模式
   └─ 加載 .env 環境變數
```

### 配置來源

推理腳本會按優先級加載配置：

1. **命令行參數**（最高優先級）
   ```powershell
   --prompt "..."
   --max-tokens 100
   --device GPU
   ```

2. **.env 環境變數**
   ```bash
   DEFAULT_DEVICE=AUTO
   MAX_NEW_TOKENS=100
   TEMPERATURE=0.7
   TOP_P=0.9
   ```

3. **程式碼預設值**（最低優先級）

---

## 推理參數說明

### 基礎參數

| 參數 | 含義 | 示例 | 說明 |
|------|------|------|------|
| `--prompt` | 輸入提示 | "What is AI?" | 必需，提示文本 |
| `--max-tokens` | 最大生成 tokens | 100 | 可選，控制輸出長度 |
| `--device` | 推理設備 | GPU | 可選，CPU/GPU |

### 高級參數（.env 配置）

| 參數 | 範圍 | 默認值 | 說明 |
|------|------|--------|------|
| `TEMPERATURE` | 0.0-1.0 | 0.7 | 隨機性控制 |
| `TOP_K` | 1-100 | 50 | Top-K 採樣 |
| `TOP_P` | 0.0-1.0 | 0.9 | Nucleus 採樣 |
| `DEFAULT_DEVICE` | CPU/GPU/NPU/AUTO | AUTO | 推理設備選擇 |

### 參數調整建議

#### 場景 1：精確答案（代碼、數學）
```bash
TEMPERATURE=0.2
MAX_NEW_TOKENS=100
TOP_P=0.9
```

#### 場景 2：創意內容（故事、寫作）
```bash
TEMPERATURE=0.9
MAX_NEW_TOKENS=200
TOP_P=0.95
```

#### 場景 3：平衡對話（推薦）
```bash
TEMPERATURE=0.7
MAX_NEW_TOKENS=150
TOP_P=0.9
```

---

## 實際測試結果

### ✅ 驗證測試（2026-01-02）

**測試環境**：
- Windows 10/11
- Python 3.11.4
- PyTorch 2.9.1
- Transformers 4.57.3

**測試過程**：

```powershell
# 激活環境
.\venv\Scripts\Activate.ps1

# 執行推理
python scripts/run_inference_simple.py --prompt "Explain AI in one sentence." --max-tokens 40
```

**測試結果**：

| 步驟 | 狀態 | 說明 |
|------|------|------|
| 加載分詞器 | ✅ 成功 | Tokenizer 正常加載 |
| 加載模型 | ✅ 成功 | TinyLlama-1.1B 正常加載 |
| 準備輸入 | ✅ 成功 | Chat 模板格式化成功 |
| 執行推理 | ✅ 成功 | 文本生成完成 |

**推理輸出**：

```
提示: "Explain AI in one sentence."

結果: 
"AI is an acronym for Artificial Intelligence, a field of computer science 
that involves creating intelligent machines that can perform tasks normally 
performed by humans."

推理時間: ~30-60 秒（取決於硬件）
生成 tokens: 40
```

**性能指標**：

| 指標 | 值 | 說明 |
|------|-----|------|
| 設備 | CPU | 使用 CPU 推理 |
| 吞吐量 | ~10-20 tok/s | CPU 推理速度 |
| 首字延遲 | ~3-5 秒 | 首個 token 出現時間 |

### ✅ 環境驗證

```powershell
python scripts/test_openvino.py
```

**輸出**（已驗證）：
```
✓ OpenVINO GenAI 導入成功
✓ OpenVINO 導入成功
✓ OpenVINO Tokenizers 導入成功
✓ Optimum Intel 導入成功

OpenVINO 版本: 2025.4.1-20426
可用設備: CPU, GPU.0, GPU.1, NPU
```

---

## 常見問題

### ❓ 首次運行需要多長時間？

**答**：取決於網速和硬件：
- 模型下載：10Mbps 網速需 ~30-40 分鐘
- 模型加載：~10-15 秒
- 首個推理：~5-10 秒

**建議**：首次運行請耐心等待，後續使用會快得多（使用本地快取）。

---

### ❓ 模型存儲在哪裡？

**答**：模型被下載到 Hugging Face 的默認快取目錄：

```powershell
# 查看快取目錄
$env:HF_HOME

# 通常是
C:\Users\[用戶名]\.cache\huggingface\hub\

# 或者在 .env 中指定
HF_HOME=./models
```

---

### ❓ 如何加速下載？

**答**：

1. **安裝 hf_xet**（推薦）
   ```powershell
   pip install hf_xet
   ```

2. **使用鏡像源**（中國用戶）
   ```bash
   # 編輯 .env
   HF_ENDPOINT=https://hf-mirror.com
   ```

3. **預先下載**
   ```powershell
   python scripts/download_hf_model.py --repo-id "TinyLlama/TinyLlama-1.1B-Chat-v1.0"
   ```

---

### ❓ 如何使用 GPU？

**答**：

```powershell
# 檢查 GPU 可用性
python -c "import torch; print('CUDA available:', torch.cuda.is_available())"

# 使用 GPU 推理
python scripts/run_inference_simple.py --prompt "..." --device GPU

# 或在 .env 中設置
DEFAULT_DEVICE=GPU
```

---

### ❓ 可以同時運行多個推理嗎？

**答**：建議不要在同一個進程中並行推理。但可以：

1. **順序運行**（最簡單）
   ```powershell
   # 一個接一個
   python scripts/run_inference_simple.py --prompt "..."
   ```

2. **交互式模式**（推薦）
   ```powershell
   # 一次加載模型，多次推理
   python scripts/run_inference_simple.py
   ```

3. **並行進程**（進階）
   ```powershell
   # 開多個終端，分別運行
   # （需要足夠的 GPU 內存）
   ```

---

## 故障排除

### ❌ ModuleNotFoundError: No module named 'torch'

**原因**：虛擬環境未激活或套件未安裝

**解決方案**：

```powershell
# 1. 確認在項目目錄
cd c:\Users\svd\codes\openvino-lab

# 2. 激活虛擬環境
.\venv\Scripts\Activate.ps1

# 3. 驗證 PyTorch
python -c "import torch; print(torch.__version__)"

# 4. 如果失敗，重新安裝
pip install torch transformers accelerate
```

---

### ❌ CUDA out of memory

**原因**：GPU 內存不足

**解決方案**：

```powershell
# 使用 CPU 而不是 GPU
python scripts/run_inference_simple.py --device CPU

# 或減少 max-tokens
python scripts/run_inference_simple.py --max-tokens 50

# 或在 .env 中設置
DEFAULT_DEVICE=CPU
```

---

### ❌ 網絡超時（model download timeout）

**原因**：下載模型時網絡不穩定

**解決方案**：

```powershell
# 1. 使用鏡像源（中國用戶）
# 編輯 .env
HF_ENDPOINT=https://hf-mirror.com

# 2. 安裝 hf_xet 加速
pip install hf_xet

# 3. 手動下載
python scripts/download_hf_model.py --repo-id "TinyLlama/TinyLlama-1.1B-Chat-v1.0"
```

---

### ❌ 中文顯示為亂碼

**原因**：PowerShell 編碼問題

**解決方案**：

```powershell
# 臨時設置
$env:PYTHONIOENCODING='utf-8'

# 永久設置（系統環境變數）
[System.Environment]::SetEnvironmentVariable("PYTHONIOENCODING", "utf-8", "User")
```

---

## 性能優化

### CPU 推理優化

```bash
# .env 配置
OV_NUM_THREADS=4           # CPU 線程數（根據核心數調整）
OV_AFFINITY=CORE           # 啟用 CPU 綁定
TEMPERATURE=0.7            # 減小溫度提升速度
```

### GPU 推理優化

```bash
# .env 配置
DEFAULT_DEVICE=GPU
OV_GPU_DEVICE=0            # 選擇特定 GPU
MAX_NEW_TOKENS=100         # 控制生成長度
```

### 內存優化

```bash
# 減少內存占用
python scripts/run_inference_simple.py --max-tokens 50

# 或使用量化模型（Stage 8）
```

---

## 下一步

✅ 完成此階段後，您應該已經：
- ✅ 成功下載並加載 TinyLlama 模型
- ✅ 執行了推理任務
- ✅ 獲得了 AI 模型的輸出結果
- ✅ 驗證了整個 OpenVINO GenAI 環境

**可選進階階段：**

1. **📖 [第 8 階段：大型模型下載](STAGE_8_GUIDE.md)**
   - 下載 OpenLLaMA-7B 等更大的模型
   - 探索更多功能和模型

2. **📖 [第 9 階段：性能基準測試](STAGE_9_GUIDE.md)**
   - 使用 C++ benchmark 工具
   - 測試推理性能指標
   - 比較不同設備和配置

3. **📖 [返回設置指南](README.md)**
   - 查看其他設置階段
   - 完整的設置流程

---

## 相關資源

- 📖 [完整設置流程](SETUP_PROGRESS.md) - 所有 9 個階段的詳細說明
- ⚙️ [Windows 設置步驟](SETUP_WINDOWS.md) - 具體的操作說明
- 🔧 [配置設置指南](STAGE_6_GUIDE.md) - .env 和 config.yaml 詳解
- 🆘 [故障排除](../TROUBLESHOOTING.md) - 常見問題解決
- 🔗 [Hugging Face Transformers 文檔](https://huggingface.co/docs/transformers) - 官方文檔
- 🔗 [TinyLlama 模型頁面](https://huggingface.co/TinyLlama/TinyLlama-1.1B-Chat-v1.0) - 模型信息

---

**版本資訊：**
- 文檔版本：1.0.0
- 最後更新：2026-01-02
- 適用於：Windows 10/11, OpenVINO 2025.4+, PyTorch 2.9+
- 驗證狀態：✅ 已驗證並測試通過
