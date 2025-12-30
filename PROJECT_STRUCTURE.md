# 專案結構指南

OpenVINO GenAI Lab 的完整目錄結構和說明。

## 目錄結構

```
openvino-lab/
│
├── 📄 README.md                    # 主要說明文檔（起點）
├── 📄 LICENSE                      # Apache 2.0 授權
├── 📄 requirements.txt             # Python 依賴列表
├── 📄 pyproject.toml              # 項目元數據和配置
├── 📄 .gitignore                  # Git 忽略規則
│
├── 🗂️ venv/                        # Python 虛擬環境（自動生成）
│   └── 不應手動修改
│
├── 🗂️ docs/                        # 📚 文檔目錄
│   ├── README.md                  # 詳細使用指南
│   ├── SETUP_WINDOWS.md           # Windows 設置說明
│   ├── MODELS.md                  # 模型下載和轉換指南
│   └── TROUBLESHOOTING.md         # 常見問題和解決方案
│
├── 🗂️ scripts/                     # 🛠️ 工具和測試腳本
│   ├── test_openvino.py          # 環境驗證測試
│   ├── setup.ps1                 # 自動化 Windows 設置
│   ├── model_converter.py        # 模型轉換工具（可選）
│   └── 自訂工具...
│
├── 🗂️ examples/                    # 💡 使用範例
│   ├── simple_inference.py       # 簡單推理範例
│   ├── batch_inference.py        # 批量推理範例（可選）
│   ├── advanced_usage.py         # 進階用法範例（可選）
│   └── 更多範例...
│
├── 🗂️ models/                      # 🤖 本地模型存儲
│   ├── TinyLlama-1.1B-int4/      # 轉換後的模型目錄
│   │   ├── openvino_model.bin
│   │   ├── openvino_model.xml
│   │   └── config.json
│   ├── Llama-2-7b-int4/          # 更多模型...
│   └── .gitkeep                  # 佔位符（目錄跟蹤）
│
└── 🗂️ config/                      # ⚙️ 配置檔案
    ├── .env.example              # 環境變量範本
    ├── config.yaml               # 項目配置
    └── .env                      # 實際配置（由用戶創建）
```

## 各目錄說明

### 📚 `docs/` - 文檔目錄

存儲所有項目文檔，包括：
- **README.md** - 詳細的功能和使用說明
- **SETUP_WINDOWS.md** - Windows 特定的設置步驟
- **MODELS.md** - 模型轉換和管理指南
- **TROUBLESHOOTING.md** - 常見問題和解決方案

**建議閱讀順序：**
1. 根目錄的 README.md（導航和快速開始）
2. docs/SETUP_WINDOWS.md（初次設置）
3. docs/README.md（功能了解）
4. docs/MODELS.md（模型處理）
5. docs/TROUBLESHOOTING.md（遇到問題時）

### 🛠️ `scripts/` - 工具和腳本

包含輔助工具和測試腳本：
- **test_openvino.py** - 驗證環境安裝
- **setup.ps1** - Windows 自動化設置腳本
- **model_converter.py** - 模型轉換工具（待實現）
- 可根據需要添加更多工具

**運行方式：**
```powershell
# 測試環境
python scripts/test_openvino.py

# 自動設置（Windows）
.\scripts\setup.ps1

# 轉換模型
python scripts/model_converter.py --model "model-id" --output ./models
```

### 💡 `examples/` - 使用範例

包含各種場景的使用範例：
- **simple_inference.py** - 基礎文本生成推理
- **batch_inference.py** - 批量處理多個請求
- **advanced_usage.py** - 進階特性示例
- 可添加更多特定用途的範例

**運行範例：**
```powershell
# 簡單推理（需先轉換模型）
python examples/simple_inference.py ./models/TinyLlama-1.1B-int4

# 批量推理
python examples/batch_inference.py

# 進階用法
python examples/advanced_usage.py
```

### 🤖 `models/` - 模型存儲

存儲本地下載和轉換的模型：
- 每個模型一個子目錄（以模型名稱命名）
- 包含轉換後的 OpenVINO 格式檔案
- **.gitkeep** 用於使空目錄被 Git 追蹤

**建議組織方式：**
```
models/
├── llm/                    # 語言模型
│   ├── TinyLlama-1.1B-int4/
│   ├── Phi-3-mini-int4/
│   └── Llama-2-7b-int4/
├── vlm/                    # 視覺語言模型
│   └── LLaVa-7b-int4/
├── image/                  # 圖像生成
│   └── stable-diffusion-v1-5/
└── embedding/              # 嵌入模型
    └── bge-base-zh-v1.5/
```

### ⚙️ `config/` - 配置檔案

存儲項目配置和環境變數：
- **.env.example** - 環境變量範本（提供給所有人）
- **.env** - 實際配置（個人設置，不提交到 Git）
- **config.yaml** - 項目配置文件

**配置流程：**
```powershell
# 複製範本
Copy-Item config/.env.example config/.env

# 編輯自訂設置
# 打開 config/.env 並修改所需的變數
```

## 工作流程

### 第一次使用（初次設置）

```powershell
# 1. 閱讀設置指南
cat docs/SETUP_WINDOWS.md

# 2. 運行自動化設置（可選）
.\scripts\setup.ps1

# 或手動設置：
# - 安裝 Visual C++ Redistributable
# - 創建虛擬環境
# - 安裝依賴

# 3. 測試環境
python scripts/test_openvino.py

# 4. 複製配置範本
Copy-Item config/.env.example config/.env
```

### 日常開發

```powershell
# 1. 啟動虛擬環境
.\venv\Scripts\Activate.ps1

# 2. 轉換模型（如需要）
# 參考 docs/MODELS.md

# 3. 運行開發代碼
python examples/simple_inference.py

# 4. 完成後退出虛擬環境
deactivate
```

### 添加新功能

```
1. 在 examples/ 添加使用範例
2. 在 docs/ 更新相應文檔
3. 如需新工具，添加到 scripts/
4. 更新根目錄 README.md（如有重大變更）
```

## 文件命名規約

- **Python 檔案：** `snake_case.py`
- **PowerShell 腳本：** `PascalCase.ps1` 或 `snake_case.ps1`
- **文檔文件：** `UPPER_CASE.md`
- **配置文件：** `.yaml`, `.json`, `.env`
- **目錄名：** `snake_case` 或 `PascalCase`

## Git 管理

### 被追蹤的檔案
- 所有 Python 源代碼
- 文檔（docs/）
- 配置範本（config/.env.example）
- 項目配置（pyproject.toml）

### 被忽略的檔案（.gitignore）
- `venv/` - 虛擬環境
- `models/*` - 本地模型（除 .gitkeep）
- `config/.env` - 個人配置
- `*.log` - 日誌檔案
- `__pycache__/` - Python 快取
- `.DS_Store` - macOS 檔案
- `Thumbs.db` - Windows 快取

## 維護和擴展

### 添加新的範例
1. 在 `examples/` 創建新的 Python 文件
2. 使用清晰的代碼註釋
3. 在文件開始處說明用途
4. 在 README 中添加簡短說明

### 添加新的文檔
1. 在 `docs/` 創建新的 Markdown 文件
2. 使用清晰的標題和結構
3. 在主 README 中添加連結
4. 遵循現有文檔的格式

### 更新依賴
1. 更新 `requirements.txt`：
   ```powershell
   pip freeze > requirements.txt
   ```
2. 更新 `pyproject.toml` 的版本約束
3. 測試更新不會破壞現有功能

## 常見任務

### 清理環境
```powershell
# 刪除虛擬環境
Remove-Item -Recurse -Force venv

# 重新創建
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 檢查目錄大小
```powershell
# 模型目錄大小
(Get-ChildItem -Path .\models -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB

# 虛擬環境大小
(Get-ChildItem -Path .\venv -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB
```

### 備份重要文件
```powershell
# 備份模型
Compress-Archive -Path .\models -DestinationPath models_backup.zip

# 備份配置
Copy-Item config\.env config\.env.backup
```

## 支援和幫助

- 📖 查看 `docs/TROUBLESHOOTING.md` 解決常見問題
- 🔗 訪問 [OpenVINO GenAI GitHub](https://github.com/openvinotoolkit/openvino.genai)
- 💬 查看項目 Issues 和討論

---

**提示：** 定期查看和更新文檔，保持項目組織清晰！
