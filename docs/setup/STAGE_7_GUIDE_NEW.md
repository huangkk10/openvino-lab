# Stage 7️⃣ - 推理設置和使用指南

## 📋 概覽

**目標：** 設置並運行 TinyLlama 模型推理

**所需時間：** 
- 快速開始：2-3 分鐘（首次自動下載模型 ~2.2GB）
- 完整設置：5-10 分鐘

**核心工具：**
- `run_inference_simple.py` - **推薦** - 標準推理腳本（開箱即用）
- `prepare_models.ps1` - 可選 - 下載 OpenVINO 優化模型（用於未來兼容性）

---

## 🚀 快速開始（推薦）

### 步驟 1：激活虛擬環境

```powershell
cd c:\Users\svd\codes\openvino-lab
.\venv\Scripts\Activate.ps1
```

✅ 您應該看到 `(venv)` 前綴

### 步驟 2：運行推理

#### 方式 A：單次推理（快速測試）

```powershell
python scripts/run_inference_simple.py --prompt "What is machine learning?"
```

#### 方式 B：交互式模式（推薦）

```powershell
python scripts/run_inference_simple.py
```

然後輸入任何問題，輸入 `exit` 退出。

#### 方式 C：演示模式

```powershell
python scripts/run_inference_simple.py demo
```

---

## 📦 使用的模型

### 推薦模型（當前使用）

**模型名稱**：`TinyLlama/TinyLlama-1.1B-Chat-v1.0`

| 項目 | 詳情 |
|------|------|
| **格式** | PyTorch (.safetensors) |
| **大小** | 1.1B 參數 |
| **下載大小** | ~2.2GB |
| **來源** | HuggingFace 官方 |
| **推理方式** | 標準 Transformers |
| **下載位置** | `~/.cache/huggingface/hub/` |
| **狀態** | ✅ **正在使用** |

**優點**：
- ✅ 開箱即用
- ✅ 首次自動下載
- ✅ 兼容性好

### 可選：OpenVINO 優化模型

```powershell
.\scripts\prepare_models.ps1
```

**可用版本**：
- `TinyLlama-1.1B-Chat-int4` - 600MB
- `TinyLlama-1.1B-Chat-int8` - 800MB  
- `TinyLlama-1.1B-Chat-fp16` - 1.2GB

**狀態**：已下載但未使用（等待 OpenVINO GenAI 兼容性修復）

---

## ⚙️ 配置調整

### 編輯 `config/.env`

```bash
# 推理設備
DEFAULT_DEVICE=CPU              # 選項：CPU, GPU, NPU

# 推理參數
MAX_NEW_TOKENS=100             # 最大生成令牌數
TEMPERATURE=0.7                # 溫度（0-1，越低越確定）
TOP_P=0.9                      # Top-P 採樣
TOP_K=50                       # Top-K 採樣
```

### 命令行調整

```powershell
# 使用 GPU
python scripts/run_inference_simple.py --device GPU

# 增加輸出長度
python scripts/run_inference_simple.py --max-tokens 200

# 更確定的回答
# 編輯 config/.env，設置 TEMPERATURE=0.3
```

---

## 📁 模型位置

### 自動下載的模型

```
~/.cache/huggingface/hub/models--TinyLlama--TinyLlama-1.1B-Chat-v1.0/
```

在 Windows：`C:\Users\svd\.cache\huggingface\hub\...`

### 可選的 OpenVINO 模型

```
./models/TinyLlama-1.1B-Chat-int4/
./models/TinyLlama-1.1B-Chat-int8/
./models/TinyLlama-1.1B-Chat-fp16/
```

---

## 🐛 故障排除

### ❌ 下載慢

```powershell
$env:HF_ENDPOINT="https://hf-mirror.com"
python scripts/run_inference_simple.py --prompt "test"
```

### ❌ 推理慢

如果有 CUDA GPU，使用 GPU：
```powershell
python scripts/run_inference_simple.py --device GPU
```

### ❌ 記憶體不足

減少輸出長度：
```powershell
python scripts/run_inference_simple.py --max-tokens 50
```

---

## 📊 性能預期

### CPU
- 首次加載：10-15 秒
- 推理速度：20-50 詞/秒
- 記憶體：~3GB

### GPU（如果有 CUDA）
- 首次加載：5-10 秒
- 推理速度：100-300 詞/秒
- 記憶體：~2-3GB VRAM

---

## 🔗 快速命令

```powershell
# 激活環境
.\venv\Scripts\Activate.ps1

# 單次推理
python scripts/run_inference_simple.py --prompt "Your question"

# 交互式模式
python scripts/run_inference_simple.py

# 演示
python scripts/run_inference_simple.py demo

# 使用 GPU
python scripts/run_inference_simple.py --device GPU

# 下載 OpenVINO 模型（可選）
.\scripts\prepare_models.ps1
```

---

## ✅ 完成檢查表

- [ ] 虛擬環境已激活
- [ ] 運行了推理腳本
- [ ] 模型已下載
- [ ] 推理結果正常
- [ ] （可選）調整了參數

全部完成？🎉 **推理環境已設置完成！**
