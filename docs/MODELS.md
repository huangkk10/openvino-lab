# OpenVINO GenAI 模型指南

本文檔說明如何下載、轉換和管理模型。

## 🔄 模型轉換流程

OpenVINO GenAI 使用專有的 OpenVINO Intermediate Representation (IR) 格式。您需要從 Hugging Face 轉換模型。

### 前置要求

```powershell
pip install optimum[openvino]
```

### 基本轉換命令

```powershell
optimum-cli export openvino \
  --model <hugging-face-model-id> \
  --weight-format <format> \
  --output-dir <output-path> \
  --trust-remote-code
```

**參數說明：**
- `--model`: Hugging Face 模型 ID
- `--weight-format`: 量化格式 (int4, int8, fp16)
- `--output-dir`: 輸出目錄
- `--trust-remote-code`: 信任遠端代碼（某些模型需要）

## 📚 常見模型轉換範例

### 文字生成模型

#### TinyLlama（推薦開始使用）
```powershell
optimum-cli export openvino \
  --model TinyLlama/TinyLlama-1.1B-Chat-v1.0 \
  --weight-format int4 \
  --output-dir ./models/TinyLlama-1.1B-int4 \
  --trust-remote-code
```

**特性：**
- 大小：1.1B 參數
- 速度：非常快
- 質量：基本推理
- 用途：測試和開發

#### Phi-3（微軟小型模型）
```powershell
optimum-cli export openvino \
  --model microsoft/phi-3-mini-4k-instruct \
  --weight-format int4 \
  --output-dir ./models/Phi-3-mini-int4 \
  --trust-remote-code
```

**特性：**
- 大小：3.8B 參數
- 速度：快
- 質量：良好
- 用途：輕量級應用

#### Llama 2（中等規模）
```powershell
optimum-cli export openvino \
  --model meta-llama/Llama-2-7b-chat-hf \
  --weight-format int4 \
  --output-dir ./models/Llama-2-7b-int4 \
  --trust-remote-code
```

**特性：**
- 大小：7B 參數
- 速度：中等
- 質量：優秀
- 用途：通用任務
- **注意：** 需要 Hugging Face 驗證 token

#### Llama 3（最新）
```powershell
optimum-cli export openvino \
  --model meta-llama/Llama-2-13b-chat-hf \
  --weight-format int4 \
  --output-dir ./models/Llama-3-13b-int4 \
  --trust-remote-code
```

### 視覺語言模型 (VLM)

#### LLaVa
```powershell
optimum-cli export openvino \
  --model llava-hf/llava-1.5-7b-hf \
  --weight-format int4 \
  --output-dir ./models/LLaVa-7b-int4 \
  --trust-remote-code
```

#### MiniCPM-V
```powershell
optimum-cli export openvino \
  --model openbmb/MiniCPM-V \
  --weight-format int4 \
  --output-dir ./models/MiniCPM-V-int4 \
  --trust-remote-code
```

### 圖像生成模型

#### Stable Diffusion
```powershell
optimum-cli export openvino \
  --model runwayml/stable-diffusion-v1-5 \
  --weight-format int8 \
  --output-dir ./models/stable-diffusion-v1-5 \
  --trust-remote-code
```

### 語音模型

#### Whisper
```powershell
optimum-cli export openvino \
  --model openai/whisper-base \
  --weight-format int8 \
  --output-dir ./models/whisper-base \
  --trust-remote-code
```

### 嵌入模型

#### BGE Embeddings
```powershell
optimum-cli export openvino \
  --model BAAI/bge-base-zh-v1.5 \
  --weight-format fp16 \
  --output-dir ./models/bge-base-zh-v1.5 \
  --trust-remote-code
```

## 💾 本地模型管理

### 建議的目錄結構

```
models/
├── llm/
│   ├── TinyLlama-1.1B-int4/
│   ├── Phi-3-mini-int4/
│   └── Llama-2-7b-int4/
├── vlm/
│   ├── LLaVa-7b-int4/
│   └── MiniCPM-V-int4/
├── image_generation/
│   └── stable-diffusion-v1-5/
├── asr/
│   └── whisper-base/
└── embedding/
    └── bge-base-zh-v1.5/
```

### 模型轉換腳本

建議使用 `scripts/model_converter.py` 進行批量轉換：

```powershell
# 轉換單個模型
python scripts/model_converter.py \
  --model "TinyLlama/TinyLlama-1.1B-Chat-v1.0" \
  --output ./models \
  --format int4

# 批量轉換
python scripts/model_converter.py \
  --models "./config/model_list.txt" \
  --output ./models \
  --format int4
```

## ⚙️ 量化格式選擇

| 格式 | 大小 | 速度 | 質量 | 用途 |
|------|------|------|------|------|
| FP32 | 最大 | 最慢 | 最佳 | 基準測試、精度驗證 |
| FP16 | 50% | 快 | 很好 | 質量優先 |
| INT8 | 25% | 很快 | 好 | 平衡 |
| INT4 | 12.5% | 最快 | 可接受 | 速度優先、邊緣設備 |

**建議：**
- 開發：INT4（快速迭代）
- 生產：INT8 或 FP16（質量和速度平衡）
- 邊緣設備：INT4（最小化資源使用）

## 🔐 Hugging Face 驗證

某些模型（如 Llama）需要 Hugging Face 驗證：

```powershell
# 設置 Hugging Face token
huggingface-cli login

# 或者設置環境變數
$env:HF_TOKEN = "your_token_here"
```

## 📊 模型推薦

### 快速開始
- **TinyLlama** - 1.1B，最快
- 用途：測試環境、演示

### 通用用途
- **Phi-3 Mini** - 3.8B，很快
- **Llama 2 7B** - 7B，平衡
- 用途：生產應用、API 服務

### 高質量
- **Llama 2 13B** 或更大
- **Mistral 7B**
- 用途：需要高質量輸出

### 視覺任務
- **LLaVa 7B** - 圖像理解
- **MiniCPM-V** - 輕量級視覺

## 🚀 加速模型下載

### 使用鏡像源（中國用戶）

```powershell
# 設置 Hugging Face 鏡像
$env:HF_ENDPOINT = "https://hf-mirror.com"

# 然後執行轉換命令
optimum-cli export openvino --model "model-id" ...
```

### 並行下載

```bash
# 使用 aria2 加速
aria2c "https://huggingface.co/.../file"
```

## ✅ 模型驗證

轉換後驗證模型：

```powershell
# 測試模型是否可加載
python -c "
import openvino_genai as ov_genai
pipe = ov_genai.LLMPipeline('./models/TinyLlama-1.1B-int4', 'CPU')
print('Model loaded successfully!')
result = pipe.generate('Hello', max_new_tokens=10)
print(result)
"
```

## 📝 模型列表配置

建議維護 `config/model_list.txt`：

```
TinyLlama/TinyLlama-1.1B-Chat-v1.0
microsoft/phi-3-mini-4k-instruct
meta-llama/Llama-2-7b-chat-hf
llava-hf/llava-1.5-7b-hf
BAAI/bge-base-zh-v1.5
```

然後批量轉換：

```powershell
python scripts/model_converter.py --models config/model_list.txt --output ./models
```

## 🔗 有用的資源

- [Hugging Face Model Hub](https://huggingface.co/models)
- [Supported Models by OpenVINO](https://github.com/openvinotoolkit/openvino.genai)
- [Optimum Intel 文檔](https://huggingface.co/docs/optimum/intel/overview)
- [OpenVINO GenAI Samples](https://github.com/openvinotoolkit/openvino.genai/tree/master/samples)
