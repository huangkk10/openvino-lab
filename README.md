# OpenVINO GenAI Lab

這是一個用於學習和實驗 OpenVINO GenAI 的專案環境。

## � 專案結構

```
openvino-lab/
├── venv/                          # Python 虛擬環境
├── docs/                          # 文檔
│   ├── README.md                  # 詳細使用指南
│   ├── SETUP_WINDOWS.md           # Windows 設置說明
│   ├── MODELS.md                  # 模型下載和轉換指南
│   └── TROUBLESHOOTING.md         # 常見問題解決
├── scripts/                       # 工具和測試腳本
│   ├── test_openvino.py          # 環境驗證測試
│   ├── setup.ps1                 # 自動化設置腳本
│   └── model_converter.py        # 模型轉換工具
├── examples/                      # 使用範例
│   ├── simple_inference.py       # 簡單推理範例
│   ├── batch_inference.py        # 批量推理範例
│   └── advanced_usage.py         # 進階用法
├── models/                        # 本地存儲的模型
│   └── .gitkeep                  # 佔位符
├── config/                        # 配置檔案
│   ├── .env.example              # 環境變量範本
│   └── config.yaml               # 項目配置
├── requirements.txt              # Python 依賴
├── pyproject.toml               # 項目元數據
├── .gitignore                   # Git 忽略規則
└── LICENSE                      # 授權條款
```

## 🚀 快速開始

### 1️⃣ 初次設置

```powershell
# 閱讀 Windows 設置指南（重要！）
cat docs/setup/SETUP_WINDOWS.md

# 或使用自動化設置腳本
.\scripts\setup.ps1
```

### 2️⃣ 啟動虛擬環境

```powershell
.\venv\Scripts\Activate.ps1
```

### 3️⃣ 運行推理（推薦方法）

```powershell
# 最簡單方式 - 單次推理
python scripts/run_inference_simple.py --prompt "What is machine learning?"

# 交互式模式
python scripts/run_inference_simple.py

# 演示（3 個範例）
python scripts/run_inference_simple.py demo
```

### 4️⃣ 驗證安裝

```powershell
python scripts/test_openvino.py
```

### 5️⃣ 選擇性：下載 OpenVINO 或其他模型（可選）

```powershell
# 方法 A：互動式菜單（推薦簡單）
.\scripts\download_model_interactive.ps1

# 方法 B：命令行（推薦快速）
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"

# 詳見快速參考：DOWNLOAD_QUICK_REFERENCE.md
```

## 📚 文檔結構

| 文檔 | 說明 |
|------|------|
| [`QUICKSTART.md`](QUICKSTART.md) | 📖 推理快速開始（1 分鐘） |
| [`DOWNLOAD_QUICK_REFERENCE.md`](DOWNLOAD_QUICK_REFERENCE.md) | ⬇️ **模型下載快速參考**（新增） |
| [`docs/setup/README.md`](docs/setup/README.md) | 📊 **9 階段進度和檢查表（推薦閱讀）** |
| [`docs/setup/STAGE_7_GUIDE_NEW.md`](docs/setup/STAGE_7_GUIDE_NEW.md) | **推理運行完整指南（必讀）** |
| [`docs/setup/STAGE_8_GUIDE.md`](docs/setup/STAGE_8_GUIDE.md) | **大型模型下載指南（可選進階）** |
| [`docs/setup/STAGE_9_GUIDE.md`](docs/setup/STAGE_9_GUIDE.md) | **性能基準測試指南（進階）** |
| [`docs/DOWNLOAD_HF_MODEL_GUIDE.md`](docs/DOWNLOAD_HF_MODEL_GUIDE.md) | ⬇️ **模型下載完整指南**（新增） |
| [`docs/PREPARE_MODELS_GUIDE.md`](docs/PREPARE_MODELS_GUIDE.md) | OpenVINO 模型下載（舊方案） |
| [`docs/SETUP_COMPLETE.md`](docs/SETUP_COMPLETE.md) | 完整設置報告和問題解決 |
| [`docs/setup/SETUP_WINDOWS.md`](docs/setup/SETUP_WINDOWS.md) | Windows 環境詳細步驟 |
| [`docs/README.md`](docs/README.md) | 詳細的功能說明 |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | 常見問題和解決方案 |

## 🛠️ 工具和腳本

### 環境驗證
```powershell
python scripts/test_openvino.py
```

### 自動設置（可選）
```powershell
.\scripts\setup.ps1
```

### 模型轉換
```powershell
python scripts/model_converter.py --model "model-name" --output ./models
```

## 🎯 支援的場景

OpenVINO GenAI 支援以下生成式 AI 場景：

1. **文字生成** - 使用 LLM（Llama, Phi, Qwen 等）
2. **視覺語言模型** - 圖像分析（LLaVa, MiniCPM-V 等）
3. **圖像生成** - Stable Diffusion & Flux 模型
4. **語音識別** - Whisper 模型
5. **語音生成** - SpeechT5 TTS 模型
6. **文本嵌入** - 語義搜索
7. **文本重排序** - RAG 工作流

## � 安裝清單

- ✅ Python 3.10+
- ✅ Visual C++ Redistributable（見 [`docs/SETUP_WINDOWS.md`](docs/SETUP_WINDOWS.md)）
- ✅ OpenVINO GenAI
- ✅ Optimum CLI
- ✅ PyTorch & Transformers

## 🎯 支援的 AI 場景

1. **文字生成** - LLM 推理（Llama, Phi, Qwen 等）
2. **視覺語言模型** - 圖像分析（LLaVa, MiniCPM-V）
3. **圖像生成** - Stable Diffusion & Flux
4. **語音識別** - Whisper
5. **語音生成** - SpeechT5
6. **文本嵌入** - 語義搜索
7. **文本重排序** - RAG 工作流

## 💾 配置

環境變量配置見 [`config/.env.example`](config/.env.example)

複製並自訂：
```powershell
Copy-Item config/.env.example config/.env
# 編輯 config/.env 以配置您的設置
```

## 📖 推薦閱讀順序

1. **快速開始**：[`QUICKSTART.md`](QUICKSTART.md) - 一頁快速參考
2. **完整設置**：[`docs/setup/README.md`](docs/setup/README.md) - 9 階段進度檢查表
3. **推理指南**：[`docs/setup/STAGE_7_GUIDE_NEW.md`](docs/setup/STAGE_7_GUIDE_NEW.md) - 如何運行推理（推薦）
4. **模型下載（可選）**：[`docs/setup/STAGE_8_GUIDE.md`](docs/setup/STAGE_8_GUIDE.md) - 大型模型下載（進階）
5. **性能測試（進階）**：[`docs/setup/STAGE_9_GUIDE.md`](docs/setup/STAGE_9_GUIDE.md) - Benchmark 基準測試
6. **下載工具**：[`DOWNLOAD_QUICK_REFERENCE.md`](DOWNLOAD_QUICK_REFERENCE.md) - 模型下載快速參考
7. **完整報告**：[`docs/SETUP_COMPLETE.md`](docs/SETUP_COMPLETE.md) - 問題解決方案
8. **遇到問題**：[`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) - 常見問題解決
9. **深入了解**：[`docs/README.md`](docs/README.md) - 詳細功能說明

## 🔗 相關資源

- [OpenVINO GenAI 官方文檔](https://openvinotoolkit.github.io/openvino.genai/)
- [OpenVINO GenAI GitHub](https://github.com/openvinotoolkit/openvino.genai)
- [Hugging Face Models](https://huggingface.co/models)
- [Optimum Intel](https://huggingface.co/docs/optimum/intel/overview)

## 🤝 貢獻和反饋

這是一個學習專案。歡迎提出改進建議和分享您的實驗！

## 📄 授權

本專案遵循 Apache License 2.0。詳見 [`LICENSE`](LICENSE) 文件。

---

**快速提示：** 第一次使用時，請務必先閱讀 [`docs/SETUP_WINDOWS.md`](docs/SETUP_WINDOWS.md)！
