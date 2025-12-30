# OpenVINO GenAI 詳細使用指南

這份文檔提供 OpenVINO GenAI 的詳細功能和使用方法。

## 📦 已安裝的套件

- **openvino-genai** - OpenVINO GenAI 主要套件
- **openvino** - OpenVINO 運行時
- **openvino-tokenizers** - Tokenizer 支援
- **optimum[openvino]** - Hugging Face Optimum 與 OpenVINO 整合
- **transformers** - Hugging Face Transformers 庫

## 🎯 支援的場景

OpenVINO GenAI 支援以下生成式 AI 場景：

### 1. 文字生成
使用大語言模型（LLM）進行文本生成、對話和內容創建。

**支援的模型：**
- Llama 系列（Meta Llama 2, 3）
- Phi 系列（Microsoft Phi）
- Qwen 系列（Alibaba Qwen）
- TinyLlama（小型輕量級）
- Mistral
- Gemma

**範例：**
```python
import openvino_genai as ov_genai

pipe = ov_genai.LLMPipeline("path/to/model", "CPU")
result = pipe.generate("What is artificial intelligence?", max_new_tokens=100)
print(result)
```

### 2. 視覺語言模型 (VLM)
分析圖像內容並生成描述或回答視覺相關的問題。

**支援的模型：**
- LLaVa（Large Language and Vision Assistant）
- MiniCPM-V
- Qwen-VL

**範例：**
```python
import openvino_genai as ov_genai
from PIL import Image

pipe = ov_genai.VLMPipeline("path/to/vlm/model", "CPU")
image = Image.open("image.jpg")
result = pipe.generate(image, "Describe this image")
print(result)
```

### 3. 圖像生成
使用擴散模型生成新的圖像。

**支援的模型：**
- Stable Diffusion
- Flux
- ControlNet（控制圖像生成）

**範例：**
```python
import openvino_genai as ov_genai

pipe = ov_genai.ImageGenerationPipeline("path/to/model", "CPU")
result = pipe.generate("A cat sitting on a sunny windowsill")
result.save("output.png")
```

### 4. 語音識別 (ASR)
使用 Whisper 模型進行語音轉文本。

**支援的模型：**
- OpenAI Whisper（多語言）

**範例：**
```python
import openvino_genai as ov_genai

pipe = ov_genai.ASRPipeline("path/to/whisper/model", "CPU")
result = pipe.infer("audio.wav")
print(result)
```

### 5. 語音生成 (TTS)
使用 SpeechT5 進行文本轉語音。

**支援的模型：**
- SpeechT5

**範例：**
```python
import openvino_genai as ov_genai

pipe = ov_genai.TTSPipeline("path/to/speecht5/model", "CPU")
pipe.synthesize("Hello, this is a test", "output.wav")
```

### 6. 文本嵌入
生成文本的向量表示，用於語義搜索。

**支援的模型：**
- BERT 類模型
- BGE Embedding
- E5

**範例：**
```python
import openvino_genai as ov_genai

pipe = ov_genai.EmbeddingPipeline("path/to/embedding/model", "CPU")
embedding = pipe.embed("What is OpenVINO?")
print(embedding.shape)  # (1, 768) 或其他維度
```

### 7. 文本重排序 (Reranking)
重新評估搜索結果的相關性，用於 RAG 工作流。

**範例：**
```python
import openvino_genai as ov_genai

pipe = ov_genai.RerankingPipeline("path/to/reranker/model", "CPU")
scores = pipe.rerank(query, documents)
sorted_docs = sorted(zip(documents, scores), key=lambda x: x[1], reverse=True)
```

## 💡 推理設備選擇

OpenVINO 支援多種推理設備，您可以根據硬體選擇：

### CPU（中央處理器）
- **優點：** 通用、兼容性好、易於部署
- **缺點：** 速度相對較慢
- **適用場景：** 一般推理、邊緣設備

```python
pipe = ov_genai.LLMPipeline("model_path", "CPU")
```

### GPU（圖形處理器）
- **優點：** 速度快、高吞吐量
- **缺點：** 需要特定硬體、功耗高
- **適用場景：** 實時推理、批量處理

```python
pipe = ov_genai.LLMPipeline("model_path", "GPU")
```

### NPU（神經處理器）
- **優點：** 能效高、低功耗
- **缺點：** 限制於特定硬體（Intel AI Boost）
- **適用場景：** 邊緣設備、移動應用

```python
pipe = ov_genai.LLMPipeline("model_path", "NPU")
```

### 多設備組合
```python
# 混合使用多個設備
pipe = ov_genai.LLMPipeline("model_path", "CPU_GPU")
```

## ⚙️ 推理優化

### 量化 (Quantization)
減少模型大小和計算量。

**支援的量化格式：**
- INT8 量化
- INT4 量化（更激進的壓縮）
- FP16 精度

**範例（模型轉換時）：**
```bash
# INT4 量化（推薦）
optimum-cli export openvino --model "model-id" --weight-format int4 --output-dir ./model_int4

# INT8 量化
optimum-cli export openvino --model "model-id" --weight-format int8 --output-dir ./model_int8
```

### 批量推理
同時處理多個輸入以提高吞吐量。

```python
prompts = [
    "What is AI?",
    "Explain machine learning.",
    "Tell me about neural networks."
]

pipe = ov_genai.LLMPipeline("model_path", "CPU")
results = pipe.generate(prompts, max_new_tokens=50)
for prompt, result in zip(prompts, results):
    print(f"Q: {prompt}\nA: {result}\n")
```

### 續配 (Prefix Caching)
快取常用的前綴以加快推理速度。

```python
# 系統提示詞
system_prompt = "You are a helpful AI assistant."

pipe = ov_genai.LLMPipeline("model_path", "CPU")

# 首次請求會緩存前綴
result1 = pipe.generate(system_prompt + "What is Python?")

# 後續請求重用緩存
result2 = pipe.generate(system_prompt + "What is Java?")
```

## 🔧 常見配置

### 環境變數

```bash
# 日誌級別
export OV_LOG_LEVEL=DEBUG

# 線程數
export OV_NUM_THREADS=4

# GPU 選擇
export OV_GPU_DEVICE=0
```

### 超參數

```python
# 推理參數
generate_kwargs = {
    "max_new_tokens": 100,        # 最多生成 100 個 token
    "top_k": 50,                  # Top-K 採樣
    "top_p": 0.9,                 # Top-P (nucleus) 採樣
    "temperature": 0.7,           # 溫度（控制隨機性）
    "do_sample": True,            # 是否使用採樣
    "repetition_penalty": 1.1,    # 重複懲罰
    "num_beams": 1,               # Beam search 寬度
}

pipe = ov_genai.LLMPipeline("model_path", "CPU")
result = pipe.generate("Your prompt", **generate_kwargs)
```

## 📊 性能最佳實踐

1. **使用適當的量化格式**
   - INT4 最激進，速度快
   - INT8 平衡質量和速度
   - FP16 保持質量

2. **選擇合適的設備**
   - CPU：通用、低功耗
   - GPU：速度快、高吞吐
   - NPU：能效高

3. **批量處理**
   - 一次處理多個請求以提高效率

4. **快取和預熱**
   - 使用續配快取常用前綴
   - 第一個推理可能較慢（即時編譯）

5. **監控資源**
   - 監控 CPU/GPU 使用率
   - 適當調整線程數

## 🔗 相關資源

- [Hugging Face Models](https://huggingface.co/models)
- [Optimum Intel 文檔](https://huggingface.co/docs/optimum/intel/overview)
- [OpenVINO 官方支援的模型](https://github.com/openvinotoolkit/openvino.genai/blob/master/README.md)
