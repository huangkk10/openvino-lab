# 模型下載和 Git 配置完全指南

## 📍 您的問題解答

### Q1: 模型會下載到哪個資料夾？

**答：** 默認下載到項目根目錄的 `models/` 文件夾

```
c:\Users\svd\codes\openvino-lab\
└── models\
    ├── TinyLlama-1.1B-int4\       ← 運行腳本時選項 1
    ├── Qwen2-1.5B-int4\           ← 運行腳本時選項 2
    └── phi-2-int4\                ← 運行腳本時選項 3
```

每個模型會創建自己的子目錄，包含：
- `config.json` - 模型配置
- `tokenizer.json` - 分詞器文件
- `model.safetensors` - 模型權重（最大的文件）
- 其他支持文件

### Q2: 是否已設定 .gitignore？

**答：** ✅ **已設定完成！**

#### 已配置的忽略規則

```
✅ models/              ← 所有模型文件（關鍵！）
✅ config/.env          ← 本地環境配置
✅ venv/                ← 虛擬環境
✅ __pycache__/         ← Python 緩存
✅ *.log                ← 日誌文件
✅ .vscode/             ← IDE 配置
... 等等 20+ 條規則
```

#### 驗證配置

```powershell
# 確認 models/ 被忽略
git check-ignore -v models/
# 輸出：.gitignore:22:models/   models/

# 確認 config/.env 被忽略
git check-ignore -v config/.env
# 輸出：.gitignore:65:config/.env   config/.env

# 確認 venv/ 被忽略
git check-ignore -v venv/
# 輸出：.gitignore:2:venv/   venv/
```

---

## 📊 文件結構和大小

### 項目目錄結構

```
openvino-lab/
│
├── 📄 .gitignore                    [1.3 KB] ✅ 提交到 Git
├── 📄 requirements.txt              [2 KB]   ✅ 提交到 Git
├── 📄 README.md                     [5 KB]   ✅ 提交到 Git
│
├── 📁 config/
│   ├── config.yaml                  [2 KB]   ✅ 提交到 Git
│   ├── .env.example                 [2 KB]   ✅ 提交到 Git
│   └── .env                         [2 KB]   ❌ 不提交（本地）
│
├── 📁 docs/
│   ├── setup/
│   │   ├── README.md
│   │   ├── SETUP_PROGRESS.md
│   │   ├── STAGE_7_GUIDE.md         ✅ 提交到 Git
│   │   └── GITIGNORE_GUIDE.md       ✅ 提交到 Git
│   └── QUICK_REFERENCE.md           ✅ 提交到 Git
│
├── 📁 scripts/
│   ├── test_openvino.py             ✅ 提交到 Git
│   ├── prepare_models.ps1           ✅ 提交到 Git
│   └── run_inference.py             ✅ 提交到 Git
│
├── 📁 venv/                         [500 MB] ❌ 不提交（本地）
│   └── Scripts/, Lib/, ...
│
└── 📁 models/                       [500 MB - 10 GB] ❌ 不提交（本地）
    ├── TinyLlama-1.1B-int4/
    ├── Qwen2-1.5B-int4/
    └── phi-2-int4/
```

### 大小分析

| 類別 | 大小 | 提交到 Git? | 每人需要? |
|------|------|-----------|---------|
| 代碼和文檔 | ~50 KB | ✅ 是 | 共享一份 |
| Python 虛擬環境 | ~500 MB | ❌ 否 | 各自生成 |
| TinyLlama 模型 | ~600 MB | ❌ 否 | 各自下載 |
| Qwen2 模型 | ~800 MB | ❌ 否 | 各自下載 |
| phi-2 模型 | ~1.2 GB | ❌ 否 | 各自下載 |

---

## 🚀 工作流程

### 第一次設置（您已經完成）

```powershell
# 1. 克隆倉庫
git clone <repo-url>
cd openvino-lab

# 2. 創建虛擬環境（本地，被 .gitignore 忽略）
python -m venv venv

# 3. 激活虛擬環境
.\venv\Scripts\Activate.ps1

# 4. 安裝依賴
pip install -r requirements.txt

# 5. 複製環境配置（本地，被 .gitignore 忽略）
Copy-Item config\.env.example config\.env

# 6. 下載模型（本地，被 .gitignore 忽略）
.\scripts\prepare_models.ps1

# ✅ 完成！所有設置都在本地，不會提交到 Git
```

### 日常開發工作流程

```powershell
# 激活虛擬環境
.\venv\Scripts\Activate.ps1

# 編輯代碼
notepad scripts\my_new_script.py

# 檢查狀態（應該看不到 models/, venv/, .env）
git status

# 提交代碼
git add scripts\my_new_script.py
git commit -m "Add new feature"
git push origin main
```

### 隊友協作工作流程

```powershell
# 隊友克隆倉庫
git clone <repo-url>
cd openvino-lab

# Git 只拉取了代碼和文檔（~50 KB）
# 隊友需要自己設置本地環境

# 創建虛擬環境
python -m venv venv
.\venv\Scripts\Activate.ps1

# 安裝依賴
pip install -r requirements.txt

# 複製環境配置
Copy-Item config\.env.example config\.env

# 下載模型（使用相同的腳本）
.\scripts\prepare_models.ps1

# 現在隊友有了完整的本地環境
# 所有配置都一樣，但模型是他們自己下載的
```

---

## 🔐 安全性考慮

### 為什麼要忽略 config/.env？

```
❌ 不要提交的內容示例：

DEFAULT_DEVICE=GPU                    # 本地特定配置
HF_TOKEN=hf_abc123xyz...             # 敏感 API Token
DATABASE_PASSWORD=secret123          # 數據庫密碼
OPENAI_API_KEY=sk_...                # API 密鑰
```

### 正確做法

```
✅ 提交 config/.env.example：
DEFAULT_DEVICE=CPU                    # 默認值，無敏感信息
# HF_TOKEN=                           # 空的，註釋說明
# DATABASE_PASSWORD=                  # 空的，說明用途
```

**規則：**
- 提交 `.env.example`（模板）到 Git
- 每個開發者複製為 `.env`（被忽略）並填入自己的值

---

## 📈 倉庫大小統計

### Git 倉庫大小

```powershell
# 檢查倉庫大小
git count-objects -v

# 預期輸出（配置正確時）：
# count: 50
# size: 50 KB
# in-pack: 40
# packs: 1
# size-pack: 30 KB
```

### 本地工作目錄大小

```powershell
# 檢查本地文件夾大小
(Get-ChildItem -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB

# 預期輸出：
# 1-2 GB（取決於下載的模型數量）
```

---

## ✅ 最終檢查清單

- [x] `.gitignore` 文件已更新
- [x] `models/` 目錄被正確忽略
- [x] `config/.env` 被正確忽略
- [x] `venv/` 被正確忽略
- [x] `config/.env.example` 會被提交
- [x] 腳本和代碼會被提交
- [x] 文檔會被提交

**驗證命令：**
```powershell
git status
# 應該顯示：
# 沒有提交的變更
# 沒有未追蹤的文件
```

---

## 📖 相關文檔

1. **詳細 .gitignore 說明** → [`GITIGNORE_GUIDE.md`](setup/GITIGNORE_GUIDE.md)
2. **模型準備完整指南** → [`STAGE_7_GUIDE.md`](setup/STAGE_7_GUIDE.md)
3. **快速參考卡片** → [`QUICK_REFERENCE.md`](QUICK_REFERENCE.md)
4. **實際 .gitignore 文件** → [`/.gitignore`](../.gitignore)

---

## 🎯 總結

| 問題 | 答案 |
|------|------|
| **模型下載位置？** | `./models/` 目錄 |
| **.gitignore 已設置？** | ✅ 已設置（完整 30+ 規則） |
| **模型會被提交嗎？** | ❌ 不會（被忽略） |
| **能否手動修改位置？** | ✅ 可以（編輯 `prepare_models.ps1` 第 26 行） |
| **多人協作如何工作？** | 各自本地下載，Git 只共享代碼 |
| **如何驗證配置？** | `git check-ignore -v models/` |

---

**設置日期：** 2025年12月30日  
**狀態：** ✅ 完成並驗證
