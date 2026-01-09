# 🦙 Llama 快速參考卡片

> 快速指令參考 - 適合打印或保存

---

## 🚀 啟動環境

```powershell
.\venv\Scripts\Activate.ps1
```

---

## ✅ 檢查環境

```powershell
.\venv\Scripts\python.exe examples\check_llama_env.py
```

---

## 💬 快速問答（最簡單）

```powershell
# 單次問答
.\venv\Scripts\python.exe scripts\run_inference_simple.py `
  --prompt "Your question here"

# 交互式
.\venv\Scripts\python.exe scripts\run_inference_simple.py

# 演示模式
.\venv\Scripts\python.exe scripts\run_inference_simple.py demo
```

---

## 🎯 使用新範例

### 1. 快速開始（單一問題）

```powershell
# CPU
.\venv\Scripts\python.exe examples\llama_quick_start.py

# GPU
.\venv\Scripts\python.exe examples\llama_quick_start.py GPU
```

### 2. 交互式聊天機器人

```powershell
# CPU
.\venv\Scripts\python.exe examples\llama_chatbot.py

# GPU
.\venv\Scripts\python.exe examples\llama_chatbot.py GPU
```

### 3. 批量測試（多個問題）

```powershell
# 預設問題集
.\venv\Scripts\python.exe examples\llama_batch_inference.py

# GPU 模式
.\venv\Scripts\python.exe examples\llama_batch_inference.py GPU

# 自訂問題
.\venv\Scripts\python.exe examples\llama_batch_inference.py --custom
```

---

## 📊 效能測試

```powershell
# CPU 基準測試
.\venv\Scripts\python.exe scripts\run_benchmark.py `
  --model ".\models\open_llama_7b_v2-int4-ov" `
  --device CPU

# GPU 基準測試
.\venv\Scripts\python.exe scripts\run_benchmark.py `
  --model ".\models\open_llama_7b_v2-int4-ov" `
  --device GPU
```

---

## 🔧 常用 Python API

### 基本使用

```python
import openvino_genai as ov_genai

# 載入模型
pipe = ov_genai.LLMPipeline(
    "./models/open_llama_7b_v2-int4-ov",
    "CPU"  # 或 "GPU"
)

# 生成文本
result = pipe.generate("Your prompt", max_new_tokens=100)
print(result)
```

### 進階配置

```python
# 創意生成（高隨機性）
result = pipe.generate(
    prompt,
    max_new_tokens=200,
    temperature=0.9,
    top_p=0.95,
    do_sample=True
)

# 確定性生成（低隨機性）
result = pipe.generate(
    prompt,
    max_new_tokens=100,
    temperature=0.1,
    do_sample=False
)
```

---

## 📦 下載其他 Llama 模型

```powershell
# 互動式（推薦）
.\scripts\download_model_interactive.ps1

# 命令行
python .\scripts\download_hf_model.py `
  --repo-id "meta-llama/Llama-2-7b-chat-hf"

# 轉換本地模型
optimum-cli export openvino `
  --model meta-llama/Llama-2-7b-chat-hf `
  --weight-format int4 `
  --output-dir .\models\llama-2-7b-chat-int4 `
  --trust-remote-code
```

---

## 🔍 檢查設備

```powershell
# 列出可用設備
python -c "import openvino as ov; print('\n'.join(ov.Core().available_devices))"

# 您的設備：CPU, GPU.0, GPU.1, NPU
```

---

## 🐛 疑難排解

### 模型找不到
```powershell
# 檢查模型
Test-Path .\models\open_llama_7b_v2-int4-ov
ls .\models\open_llama_7b_v2-int4-ov\openvino_*.xml
```

### GPU 無法使用
```powershell
# 檢查 GPU 驅動
python -c "import openvino as ov; print('GPU' in ov.Core().available_devices)"
```

### 記憶體不足
- 使用 INT4 量化模型
- 減少 `max_new_tokens`
- 關閉其他應用程式

---

## 📚 完整文檔

詳細說明請參考：
- **完整計畫：** `LLAMA_SETUP_PLAN.md`
- **快速開始：** `QUICKSTART.md`
- **下載指南：** `DOWNLOAD_QUICK_REFERENCE.md`

---

## 🎓 學習路徑

1. ✅ **檢查環境** - `check_llama_env.py`
2. 🚀 **快速測試** - `llama_quick_start.py`
3. 💬 **交互聊天** - `llama_chatbot.py`
4. 📊 **批量測試** - `llama_batch_inference.py`
5. ⚡ **效能優化** - GPU 測試
6. 🌐 **Web 應用** - Streamlit/FastAPI
7. 🔧 **進階功能** - RAG、Fine-tuning

---

## ⚡ 一鍵測試

```powershell
# 最快速的測試方式
.\venv\Scripts\Activate.ps1
.\venv\Scripts\python.exe examples\llama_quick_start.py
```

---

**最後更新：** 2026-01-09  
**狀態：** ✅ 環境完整，可直接使用！

🦙✨ 祝您使用愉快！
