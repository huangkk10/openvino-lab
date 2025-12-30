# 快速參考：模型、Git 和文件管理

## 📁 模型下載位置

```
運行命令：
.\scripts\prepare_models.ps1

下載位置：
c:\Users\svd\codes\openvino-lab\models\
│
├── TinyLlama-1.1B-int4\      (~600 MB)
├── Qwen2-1.5B-int4\          (~800 MB)
└── phi-2-int4\               (~1.2 GB)
```

## 🔐 Git 忽略配置（已設置）

### 哪些文件被忽略？

```
models/              ← 所有 AI 模型文件（大文件）
config/.env          ← 本地環境變數（敏感信息）
venv/                ← 虛擬環境（本地生成）
__pycache__/         ← Python 緩存
*.log                ← 日誌文件
```

### 哪些文件會被提交？

```
✅ config/.env.example       ← 配置模板
✅ scripts/                  ← 所有腳本
✅ requirements.txt          ← 依賴清單
✅ docs/                     ← 文檔
✅ README.md                 ← 說明
```

## 📊 典型倉庫大小對比

| 場景 | 文件大小 |
|------|---------|
| 僅代碼和文檔（提交的） | ~100 KB |
| 加上虛擬環境（本地） | ~500 MB |
| 加上模型（本地） | ~1-2 GB |

**推薦做法：** ✅ 只提交代碼和文檔

## 🚀 常見工作流程

### 新開發者克隆倉庫

```powershell
# 1. 克隆倉庫（~100 KB）
git clone <repo-url>
cd openvino-lab

# 2. 本地生成虛擬環境
python -m venv venv
.\venv\Scripts\Activate.ps1

# 3. 本地安裝依賴
pip install -r requirements.txt

# 4. 本地下載模型
.\scripts\prepare_models.ps1
```

**總計下載：** ~100 KB（從 Git）+ 500+ MB（本地安裝）

### 驗證 Git 忽略規則

```powershell
# 檢查模型是否被忽略
git check-ignore -v models/

# 輸出應該是：
# models/  .gitignore:22:models/
```

### 提交代碼變更

```powershell
# 查看狀態（應該不含 models/, venv/, config/.env）
git status

# 提交
git add .
git commit -m "Add new feature"
git push
```

## ⚠️ 常見錯誤

### ❌ 誤提交大文件

```powershell
# 如果不小心提交了模型
git rm --cached models/
echo "models/" >> .gitignore
git commit -m "Remove models from tracking"
```

### ❌ Git 倉庫變得很大

```powershell
# 檢查倉庫大小
git count-objects -v | grep "size-pack"

# 如果很大，可能是因為提交了大文件
# 需要使用 git-filter-branch 或 BFG 清理歷史
```

## 📋 .gitignore 核心部分

```
# ==================== Python 虛擬環境 ====================
venv/
env/

# ==================== AI 模型和大型文件 ====================
models/                    ← 關鍵！模型文件
*.safetensors
*.onnx
*.bin
*.pt

# ==================== 環境配置 ====================
.env                       ← 關鍵！本地配置
config/.env

# ==================== Python 相關 ====================
__pycache__/
*.pyc
*.egg-info/

# 完整版本見：../.gitignore
```

## 🎯 檢查清單

- [ ] 已運行 `.\scripts\prepare_models.ps1`
- [ ] 模型已下載到 `./models/` 目錄
- [ ] `.gitignore` 包含 `models/` 和 `config/.env`
- [ ] `git status` 中看不到模型文件
- [ ] `config/.env.example` 已提交到 Git
- [ ] `config/.env` 未被提交

## 📖 詳細文檔

- 📖 [.gitignore 完整說明](GITIGNORE_GUIDE.md)
- 📖 [Stage 7 模型準備指南](STAGE_7_GUIDE.md)
- 📖 [Git 工作流程](../../.gitignore)

---

**關鍵要點：**
- 🔑 模型文件（很大）→ 本地下載，不提交到 Git
- 🔑 環境配置（敏感）→ 本地使用，不提交到 Git
- 🔑 代碼和模板 → 提交到 Git，所有人共享

