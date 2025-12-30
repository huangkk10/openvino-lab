# 🚀 快速開始指南

## ✅ 環境已完全設置！現在就可以運行推理

```powershell
# 1. 激活環境
.\venv\Scripts\Activate.ps1

# 2. 運行推理（任選一種方式）
python scripts/run_inference_simple.py --prompt "What is AI?"
```

## 常用命令（複製即用）

| 命令 | 說明 |
|------|------|
| `python scripts/run_inference_simple.py --prompt "問題"` | 單次推理 |
| `python scripts/run_inference_simple.py` | 交互式模式（無窮對話） |
| `python scripts/run_inference_simple.py demo` | 演示（3 個範例） |
| `python scripts/run_inference_simple.py --device GPU` | 使用 GPU（如果有） |
| `python scripts/run_inference_simple.py --max-tokens 200` | 調整輸出長度 |

## 首次使用注意事項

- ⏳ **首次運行會下載模型**（~2.2GB，2-5 分鐘）
- 💾 **模型位置**：`~/.cache/huggingface/`
- 🔄 **後續快速**：使用快取，無需重新下載

## 使用的模型

- **模型**：TinyLlama-1.1B-Chat-v1.0
- **來源**：HuggingFace（huggingface.co）
- **大小**：約 2.2GB
- **推薦**：CPU 對話慢，有 GPU 時性能更好

## 性能預期

| 硬件 | 速度 | 說明 |
|------|------|------|
| CPU | 20-50 詞/秒 | 慢但穩定 |
| GPU | 100-300 詞/秒 | 快速推薦 |

## 配置調整

編輯 `config/.env`：

```bash
DEFAULT_DEVICE=CPU          # CPU 或 GPU
MAX_NEW_TOKENS=100         # 最大生成令牌數
TEMPERATURE=0.7            # 創意度（0.1 保守，1.0 創意）
TOP_P=0.9                  # 多樣性採樣
```

## 故障排除

### 下載很慢
```powershell
# 使用 HuggingFace 鏡像
$env:HF_ENDPOINT="https://hf-mirror.com"
```

### 顯存不足
```powershell
# 減少生成長度
python scripts/run_inference_simple.py --max-tokens 50
```

### 推理很慢
```powershell
# 如果有 CUDA GPU，使用 GPU
python scripts/run_inference_simple.py --device GPU
```

## 進一步了解

- 📖 **完整設置報告**：`docs/SETUP_COMPLETE.md`
- � **詳細推理指南**：`docs/setup/STAGE_7_GUIDE_NEW.md`
- ⚙️ **可選模型下載**：`docs/PREPARE_MODELS_GUIDE.md`
- 📊 **進度檢查表**：`docs/setup/README.md`

---

## 一行代碼啟動（複製整段）

```powershell
.\venv\Scripts\Activate.ps1; python scripts/run_inference_simple.py --prompt "Hello, what can you do?"
```