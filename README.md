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

### 3️⃣ 驗證安裝

```powershell
python scripts/test_openvino.py
```

### 4️⃣ 下載並轉換模型

```powershell
# 參考模型轉換指南
cat docs/MODELS.md
```

### 5️⃣ 運行範例

```powershell
# 簡單推理範例
python examples/simple_inference.py

# 批量推理範例
python examples/batch_inference.py
```

## 📚 文檔結構

| 文檔 | 說明 |
|------|------|
| [`docs/setup/README.md`](docs/setup/README.md) | Windows 設置導航 |
| [`docs/setup/SETUP_PROGRESS.md`](docs/setup/SETUP_PROGRESS.md) | **【推薦】** 7 階段進度追蹤和檢查表 |
| [`docs/setup/SETUP_WINDOWS.md`](docs/setup/SETUP_WINDOWS.md) | Windows 環境設置步驟 |
| [`docs/README.md`](docs/README.md) | 詳細的使用指南和功能說明 |
| [`docs/MODELS.md`](docs/MODELS.md) | 模型下載、轉換和最佳實踐 |
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

1. 開始前：[`docs/SETUP_WINDOWS.md`](docs/SETUP_WINDOWS.md) - 設置環境
2. 基礎知識：[`docs/README.md`](docs/README.md) - 功能概述
3. 工作流程：[`docs/MODELS.md`](docs/MODELS.md) - 模型處理
4. 遇到問題：[`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) - 解決方案
5. 動手實踐：[`examples/`](examples/) - 範例代碼
6. 項目結構：[`PROJECT_STRUCTURE.md`](PROJECT_STRUCTURE.md) - 了解組織方式

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
