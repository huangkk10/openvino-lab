# 🦙 Llama 模型 + OpenVINO GenAI 使用計畫

> **建立日期：** 2026-01-09  
> **專案：** OpenVINO GenAI Lab  
> **目標：** 使用 Llama 模型搭配 OpenVINO GenAI API 進行文本生成

---

## 📋 目錄

1. [環境檢查](#1-環境檢查)
2. [環境設置補充](#2-環境設置補充)
3. [Llama 模型準備](#3-llama-模型準備)
4. [OpenVINO GenAI API 使用](#4-openvino-genai-api-使用)
5. [實作範例](#5-實作範例)
6. [進階使用](#6-進階使用)
7. [疑難排解](#7-疑難排解)

---

## 1. 環境檢查 ✅

### 1.1 當前環境狀態

| 項目 | 狀態 | 版本/說明 |
|------|------|-----------|
| Python | ✅ 已安裝 | 3.11.4 |
| Virtual Environment | ✅ 使用中 | venv |
| OpenVINO | ✅ 已安裝 | 2025.4.1 |
| OpenVINO GenAI | ✅ 已安裝 | 2025.4.1.0 |
| OpenVINO Tokenizers | ✅ 已安裝 | 2025.4.1.0 |
| Transformers | ✅ 已安裝 | 4.57.3 |
| Llama 模型 | ✅ 已下載 | open_llama_7b_v2-int4-ov |

### 1.2 模型檔案確認

模型位置：`models/open_llama_7b_v2-int4-ov/`

必要檔案清單：
- ✅ `openvino_model.xml` - 模型結構
- ✅ `openvino_model.bin` - 模型權重
- ✅ `openvino_tokenizer.xml` - Tokenizer 結構
- ✅ `openvino_tokenizer.bin` - Tokenizer 權重
- ✅ `openvino_detokenizer.xml` - Detokenizer 結構
- ✅ `openvino_detokenizer.bin` - Detokenizer 權重
- ✅ `config.json` - 模型配置
- ✅ `tokenizer_config.json` - Tokenizer 配置

**結論：環境完整，可以直接使用！** 🎉

---

## 2. 環境設置補充

### 2.1 啟動虛擬環境（每次使用前）

```powershell
# 啟動 venv
.\venv\Scripts\Activate.ps1

# 驗證環境
python --version
python -c "import openvino_genai; print(f'OpenVINO GenAI: {openvino_genai.__version__}')"
```

### 2.2 檢查可用設備

```powershell
# 列出可用的推理設備
.\venv\Scripts\python.exe -c "import openvino as ov; print('\n'.join(ov.Core().available_devices))"
```

### 2.3 可選：安裝額外工具

```powershell
# 如需更好的終端輸出（可選）
pip install rich colorama

# 如需進度條（可選）
pip install tqdm
```

---

## 3. Llama 模型準備

### 3.1 當前可用的 Llama 模型

**✅ 已就緒：Open Llama 7B (INT4 量化版本)**
- 路徑：`models/open_llama_7b_v2-int4-ov/`
- 大小：約 4GB（INT4 量化）
- 用途：通用文本生成
- 優點：速度快、記憶體佔用小

### 3.2 其他可選的 Llama 模型（未來擴展）

| 模型 | HuggingFace ID | 用途 |
|------|----------------|------|
| Llama 2 7B | `meta-llama/Llama-2-7b-chat-hf` | Meta 官方聊天模型 |
| Llama 2 13B | `meta-llama/Llama-2-13b-chat-hf` | 更強大的版本 |
| Llama 3 8B | `meta-llama/Meta-Llama-3-8B-Instruct` | 最新 Llama 3 |
| CodeLlama | `codellama/CodeLlama-7b-Instruct-hf` | 程式碼生成 |

### 3.3 下載新的 Llama 模型（可選）

```powershell
# 方法 1：使用互動式腳本（推薦）
.\scripts\download_model_interactive.ps1

# 方法 2：直接下載 OpenVINO 格式
python .\scripts\download_hf_model.py --repo-id "meta-llama/Llama-2-7b-chat-hf"

# 方法 3：從 HuggingFace 下載後轉換
optimum-cli export openvino `
  --model meta-llama/Llama-2-7b-chat-hf `
  --weight-format int4 `
  --output-dir .\models\llama-2-7b-chat-int4 `
  --trust-remote-code
```

**注意：** Meta Llama 模型需要在 HuggingFace 上接受授權條款。

---

## 4. OpenVINO GenAI API 使用

### 4.1 核心 API 概覽

```python
import openvino_genai as ov_genai

# 基本使用模式
pipe = ov_genai.LLMPipeline(model_path, device)
result = pipe.generate(prompt, max_new_tokens=100)
```

### 4.2 主要類別和方法

#### 4.2.1 `LLMPipeline` - 主要推理類別

```python
# 初始化
pipe = ov_genai.LLMPipeline(
    model_path: str,          # 模型路徑
    device: str = "CPU",      # 設備：CPU, GPU, NPU
    **kwargs                  # 其他配置
)

# 生成文本
result = pipe.generate(
    prompt: str,              # 輸入提示
    max_new_tokens: int,      # 最大生成 token 數
    **generation_config       # 生成配置
)
```

#### 4.2.2 生成配置參數

```python
generation_config = {
    "max_new_tokens": 100,       # 最大生成長度
    "temperature": 0.7,           # 溫度（0.0-1.0，越高越隨機）
    "top_p": 0.9,                 # Nucleus sampling
    "top_k": 50,                  # Top-K sampling
    "do_sample": True,            # 是否採樣
    "repetition_penalty": 1.1,    # 重複懲罰
}

result = pipe.generate(prompt, **generation_config)
```

### 4.3 設備選擇策略

| 設備 | 適用場景 | 優點 | 缺點 |
|------|----------|------|------|
| CPU | 開發、測試 | 兼容性好 | 較慢 |
| GPU | 生產、批量 | 快速 | 需要驅動 |
| NPU | 邊緣設備 | 低功耗 | 需硬體支援 |

---

## 5. 實作範例

### 5.1 快速開始：簡單問答

建立檔案：`examples/llama_quick_start.py`

```python
"""
Llama 模型快速開始
使用 OpenVINO GenAI API 進行簡單問答
"""

import openvino_genai as ov_genai

def main():
    # 設定
    model_path = "./models/open_llama_7b_v2-int4-ov"
    device = "CPU"  # 或 "GPU"
    
    print(f"載入模型: {model_path}")
    print(f"使用設備: {device}\n")
    
    # 初始化管道
    pipe = ov_genai.LLMPipeline(model_path, device)
    
    # 問題
    prompt = "What is artificial intelligence?"
    
    print(f"問題: {prompt}\n")
    print("回答: ", end="", flush=True)
    
    # 生成回答
    result = pipe.generate(prompt, max_new_tokens=100)
    print(result)
    
if __name__ == "__main__":
    main()
```

**執行：**
```powershell
.\venv\Scripts\python.exe examples\llama_quick_start.py
```

### 5.2 進階：交互式聊天機器人

建立檔案：`examples/llama_chatbot.py`

```python
"""
Llama 交互式聊天機器人
使用 OpenVINO GenAI API
"""

import openvino_genai as ov_genai
import sys

def chat_bot(model_path: str, device: str = "CPU"):
    """交互式聊天"""
    print(f"載入模型: {model_path}")
    pipe = ov_genai.LLMPipeline(model_path, device)
    
    print("\n" + "="*60)
    print("🦙 Llama 聊天機器人（輸入 'quit' 退出）")
    print("="*60 + "\n")
    
    while True:
        # 獲取用戶輸入
        try:
            user_input = input("You: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\n\n再見！")
            break
        
        if not user_input:
            continue
        
        if user_input.lower() in ['quit', 'exit', 'bye']:
            print("\n再見！")
            break
        
        # 生成回應
        print("Llama: ", end="", flush=True)
        try:
            response = pipe.generate(
                user_input,
                max_new_tokens=150,
                temperature=0.7,
                top_p=0.9
            )
            print(response + "\n")
        except Exception as e:
            print(f"\n錯誤: {e}\n")

def main():
    model_path = "./models/open_llama_7b_v2-int4-ov"
    device = "CPU"
    
    if len(sys.argv) > 1:
        device = sys.argv[1]
    
    chat_bot(model_path, device)

if __name__ == "__main__":
    main()
```

**執行：**
```powershell
# CPU 模式
.\venv\Scripts\python.exe examples\llama_chatbot.py

# GPU 模式
.\venv\Scripts\python.exe examples\llama_chatbot.py GPU
```

### 5.3 批量處理：多問題測試

建立檔案：`examples/llama_batch_inference.py`

```python
"""
Llama 批量推理
測試多個問題
"""

import openvino_genai as ov_genai
import time

def batch_inference(model_path: str, device: str = "CPU"):
    """批量推理測試"""
    print(f"載入模型: {model_path}")
    pipe = ov_genai.LLMPipeline(model_path, device)
    
    # 測試問題集
    prompts = [
        "What is machine learning?",
        "Explain the concept of neural networks.",
        "What are the benefits of artificial intelligence?",
        "How does deep learning work?",
        "What is the difference between AI and ML?"
    ]
    
    print("\n" + "="*60)
    print(f"批量測試（共 {len(prompts)} 個問題）")
    print("="*60 + "\n")
    
    results = []
    total_time = 0
    
    for i, prompt in enumerate(prompts, 1):
        print(f"[{i}/{len(prompts)}] {prompt}")
        print("-" * 60)
        
        start_time = time.time()
        result = pipe.generate(
            prompt,
            max_new_tokens=100,
            temperature=0.7
        )
        elapsed = time.time() - start_time
        
        print(f"回答: {result}")
        print(f"⏱️ 耗時: {elapsed:.2f} 秒\n")
        
        results.append({
            "prompt": prompt,
            "result": result,
            "time": elapsed
        })
        total_time += elapsed
    
    # 統計
    print("="*60)
    print(f"✅ 完成！總耗時: {total_time:.2f} 秒")
    print(f"📊 平均每題: {total_time/len(prompts):.2f} 秒")
    print("="*60)
    
    return results

def main():
    model_path = "./models/open_llama_7b_v2-int4-ov"
    device = "CPU"
    
    batch_inference(model_path, device)

if __name__ == "__main__":
    main()
```

**執行：**
```powershell
.\venv\Scripts\python.exe examples\llama_batch_inference.py
```

### 5.4 使用現有腳本（最簡單）

您已經有現成的腳本可以直接使用：

```powershell
# 方法 1：簡單推理（單次）
.\venv\Scripts\python.exe scripts\run_inference_simple.py `
  --prompt "What is OpenVINO?" `
  --model ".\models\open_llama_7b_v2-int4-ov" `
  --device CPU

# 方法 2：交互式模式
.\venv\Scripts\python.exe scripts\run_inference_simple.py

# 方法 3：演示模式
.\venv\Scripts\python.exe scripts\run_inference_simple.py demo
```

---

## 6. 進階使用

### 6.1 效能優化

#### 6.1.1 使用 GPU 加速

```python
# GPU 推理
pipe = ov_genai.LLMPipeline(model_path, "GPU")

# GPU 配置（可選）
pipe = ov_genai.LLMPipeline(
    model_path, 
    "GPU",
    config={"PERFORMANCE_HINT": "LATENCY"}  # 或 "THROUGHPUT"
)
```

#### 6.1.2 批量處理優化

```python
# 批量生成（如果 API 支援）
prompts = ["Q1", "Q2", "Q3"]
results = [pipe.generate(p, max_new_tokens=100) for p in prompts]
```

### 6.2 客製化生成參數

```python
# 創意生成（高隨機性）
creative_config = {
    "max_new_tokens": 200,
    "temperature": 0.9,      # 高溫度
    "top_p": 0.95,
    "do_sample": True
}

# 確定性生成（低隨機性）
deterministic_config = {
    "max_new_tokens": 100,
    "temperature": 0.1,      # 低溫度
    "top_p": 0.9,
    "do_sample": False
}

# 使用
result = pipe.generate(prompt, **creative_config)
```

### 6.3 與其他工具整合

#### 6.3.1 整合 Streamlit（Web UI）

```python
# 需要安裝：pip install streamlit
import streamlit as st
import openvino_genai as ov_genai

@st.cache_resource
def load_model():
    return ov_genai.LLMPipeline("./models/open_llama_7b_v2-int4-ov", "CPU")

st.title("🦙 Llama Chatbot")

pipe = load_model()
prompt = st.text_input("輸入問題：")

if st.button("生成"):
    with st.spinner("生成中..."):
        result = pipe.generate(prompt, max_new_tokens=150)
        st.write(result)
```

運行：
```powershell
pip install streamlit
streamlit run app.py
```

#### 6.3.2 整合 FastAPI（REST API）

```python
# 需要安裝：pip install fastapi uvicorn
from fastapi import FastAPI
import openvino_genai as ov_genai

app = FastAPI()
pipe = ov_genai.LLMPipeline("./models/open_llama_7b_v2-int4-ov", "CPU")

@app.post("/generate")
async def generate(prompt: str, max_tokens: int = 100):
    result = pipe.generate(prompt, max_new_tokens=max_tokens)
    return {"result": result}
```

運行：
```powershell
pip install fastapi uvicorn
uvicorn api:app --reload
```

---

## 7. 疑難排解

### 7.1 常見問題

#### Q1: 模型載入失敗

```
FileNotFoundError: [Errno 2] No such file or directory
```

**解決方案：**
```powershell
# 檢查模型是否存在
Test-Path .\models\open_llama_7b_v2-int4-ov

# 檢查必要檔案
ls .\models\open_llama_7b_v2-int4-ov\openvino_*.xml
```

#### Q2: GPU 不可用

```
RuntimeError: GPU device is not available
```

**解決方案：**
```powershell
# 檢查可用設備
python -c "import openvino as ov; print(ov.Core().available_devices)"

# 改用 CPU
pipe = ov_genai.LLMPipeline(model_path, "CPU")
```

#### Q3: 記憶體不足

```
MemoryError or Out of Memory
```

**解決方案：**
1. 使用更小的模型（INT4 量化）
2. 減少 `max_new_tokens`
3. 關閉其他程式

#### Q4: 生成速度慢

**優化策略：**
```python
# 1. 使用 GPU
pipe = ov_genai.LLMPipeline(model_path, "GPU")

# 2. 減少生成長度
result = pipe.generate(prompt, max_new_tokens=50)  # 減少長度

# 3. 使用效能提示
pipe = ov_genai.LLMPipeline(
    model_path, 
    "GPU",
    config={"PERFORMANCE_HINT": "LATENCY"}
)
```

### 7.2 除錯工具

```powershell
# 詳細日誌
$env:OPENVINO_LOG_LEVEL="DEBUG"
python your_script.py

# 檢查 OpenVINO 版本
python -c "import openvino as ov; print(ov.__version__)"

# 檢查 GenAI 版本
python -c "import openvino_genai as ov_genai; print(ov_genai.__version__)"
```

---

## 📝 快速指令備忘錄

```powershell
# 啟動環境
.\venv\Scripts\Activate.ps1

# 快速推理（使用現有腳本）
.\venv\Scripts\python.exe scripts\run_inference_simple.py --prompt "Your question here"

# 交互式聊天
.\venv\Scripts\python.exe scripts\run_inference_simple.py

# 建立新的 Python 腳本
New-Item -Path examples\my_llama_app.py -ItemType File

# 執行腳本
.\venv\Scripts\python.exe examples\my_llama_app.py

# 檢查環境
python -c "import openvino_genai; print('✅ Ready!')"
```

---

## 🎯 下一步行動

### 立即可做（0-5 分鐘）

1. ✅ **測試現有模型**
   ```powershell
   .\venv\Scripts\python.exe scripts\run_inference_simple.py demo
   ```

2. ✅ **建立第一個腳本**
   - 複製上面的 `llama_quick_start.py` 範例
   - 執行看看效果

### 短期目標（今天）

3. 📝 **建立交互式聊天機器人**
   - 使用 `llama_chatbot.py` 範例
   - 客製化問候語和提示

4. 🧪 **測試不同參數**
   - 調整 `temperature`（0.1 - 1.0）
   - 測試 `max_new_tokens` 影響

### 中期目標（本週）

5. 🚀 **下載更多 Llama 模型**
   - Llama 2 Chat
   - CodeLlama（如果需要程式碼生成）

6. 🌐 **建立 Web 介面**
   - Streamlit 或 FastAPI
   - 讓其他人也能使用

### 長期目標（進階）

7. ⚡ **效能優化**
   - GPU 加速測試
   - 批量處理優化

8. 🔧 **整合到專案**
   - RAG（檢索增強生成）
   - Fine-tuning 微調

---

## 📚 參考資源

### 官方文檔
- [OpenVINO GenAI 文檔](https://openvinotoolkit.github.io/openvino.genai/)
- [OpenVINO GenAI GitHub](https://github.com/openvinotoolkit/openvino.genai)
- [OpenVINO 文檔](https://docs.openvino.ai/)

### Llama 模型資源
- [Meta Llama](https://ai.meta.com/llama/)
- [Hugging Face Llama Models](https://huggingface.co/models?search=llama)
- [OpenVINO Llama 範例](https://github.com/openvinotoolkit/openvino.genai/tree/master/samples/python/chat_sample)

### 社群資源
- [OpenVINO 論壇](https://community.intel.com/t5/Intel-Distribution-of-OpenVINO/bd-p/distribution-openvino-toolkit)
- [GitHub Issues](https://github.com/openvinotoolkit/openvino.genai/issues)

---

## ✅ 檢查清單

### 環境設置
- [x] Python 3.11.4 已安裝
- [x] venv 虛擬環境已建立
- [x] OpenVINO GenAI 2025.4.1.0 已安裝
- [x] Transformers 4.57.3 已安裝
- [x] Open Llama 7B INT4 模型已下載

### 功能驗證
- [ ] 執行簡單推理測試
- [ ] 測試交互式聊天
- [ ] 驗證 GPU 推理（如有）
- [ ] 測試批量處理

### 進階功能
- [ ] 建立自訂應用
- [ ] 整合 Web 介面
- [ ] 效能優化測試
- [ ] 下載其他 Llama 模型

---

**最後更新：** 2026-01-09  
**狀態：** ✅ 環境完整，可以開始使用！

**馬上開始：**
```powershell
.\venv\Scripts\Activate.ps1
.\venv\Scripts\python.exe scripts\run_inference_simple.py demo
```

祝您使用愉快！🦙✨
