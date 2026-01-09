# Llama AI Agent 使用指南

## 📖 簡介

Llama AI Agent 是一個結合 Llama 大語言模型和系統工具執行的智能助手。它能夠：

- 🤖 **理解自然語言**: 使用 Llama 模型理解您的意圖
- 🛠️ **執行系統命令**: 運行 shell 命令並返回結果
- 📁 **操作文件**: 讀取、寫入、列出文件和目錄
- 🐍 **運行 Python 代碼**: 執行 Python 代碼片段
- 🔒 **安全保護**: 多層安全檢查，保護系統安全

## 🚀 快速開始

### 方法 1: 使用批處理腳本（推薦）

直接雙擊運行：
```
run_agent.bat
```

### 方法 2: 命令行

```powershell
# 啟動虛擬環境
.\venv\Scripts\Activate.ps1

# 運行 Agent
python examples\llama_agent.py
```

## 💬 使用示例

### 執行命令
```
You: run dir
You: list all python files
You: show me the directory contents
```

### 文件操作
```
You: read README.md
You: show me config.yaml
You: create a file test.txt with hello world
You: list files in examples folder
```

### Python 代碼
```
You: calculate 2 + 2
You: run python code: import sys; print(sys.version)
```

### 一般對話
```
You: hello
You: what can you do?
You: help me
```

## 🔒 安全機制

AI Agent 包含多層安全保護：

### 1. 路徑限制
- ✅ 只能操作項目根目錄內的文件
- ❌ 無法訪問系統目錄（如 `C:\Windows`）
- ❌ 無法訪問敏感目錄（如 `.ssh`, `.aws`）

### 2. 命令黑名單
禁止執行的危險命令：
- `format` - 格式化磁碟
- `del /s` - 遞迴刪除
- `rm -rf` - 強制刪除
- `shutdown` / `restart` / `reboot` - 系統控制
- `mkfs` - 文件系統格式化

### 3. 用戶確認
在執行以下操作前會要求確認：
- 執行任何命令
- 寫入文件
- 運行 Python 代碼

您可以在 `config/agent_config.yaml` 中修改 `require_confirmation` 設定。

### 4. 超時保護
- 命令執行超時: 30 秒
- Python 執行超時: 10 秒

### 5. 操作日誌
所有操作都會記錄到 `config/logs/agent_log.txt`，包括：
- 意圖識別結果
- 執行的命令
- 安全檢查結果
- 用戶確認記錄

## ⚙️ 配置

編輯 `config/agent_config.yaml` 來自定義設定：

```yaml
security:
  project_root: "C:\\Users\\svd\\codes\\openvino-lab"  # 項目根目錄
  require_confirmation: true                            # 是否需要確認
  forbidden_commands: [...]                             # 禁止的命令
  forbidden_paths: [...]                                # 禁止的路徑
  timeout:
    command: 30                                         # 命令超時（秒）
    python: 10                                          # Python 超時（秒）

logging:
  enabled: true                                         # 啟用日誌
  log_file: "config/logs/agent_log.txt"                # 日誌文件

model:
  path: "./models/open_llama_7b_v2-int4-ov"           # 模型路徑
  device: "CPU"                                         # 使用設備
```

## 📂 項目結構

```
examples/
├── llama_agent.py              # 主程式
└── agent/                      # Agent 套件
    ├── __init__.py
    ├── safety_checker.py       # 安全檢查器
    ├── intent_recognizer.py    # 意圖識別器
    ├── tool_router.py          # 工具路由器
    ├── logger.py               # 日誌系統
    └── executors/              # 執行器
        ├── __init__.py
        ├── command.py          # 命令執行器
        └── file.py             # 文件操作器

config/
├── agent_config.yaml           # 配置文件
└── logs/
    └── agent_log.txt           # 操作日誌
```

## 🔧 架構說明

### 工作流程

```
用戶輸入
    ↓
IntentRecognizer (Llama 分析意圖)
    ↓
ToolRouter (路由到對應工具)
    ↓
SafetyChecker (安全檢查)
    ↓
用戶確認 (如果需要)
    ↓
Executor (實際執行)
    ↓
Logger (記錄操作)
    ↓
返回結果
```

### 核心組件

1. **SafetyChecker**: 驗證路徑和命令的安全性
2. **IntentRecognizer**: 使用 Llama 識別用戶意圖
3. **ToolRouter**: 將意圖路由到對應的工具
4. **CommandExecutor**: 執行 shell 命令
5. **FileOperator**: 執行文件操作
6. **AgentLogger**: 記錄所有操作

## 🐛 故障排除

### 模型加載失敗
```
❌ Failed to initialize Llama model
```

**解決方法**:
1. 確認模型路徑正確: `./models/open_llama_7b_v2-int4-ov`
2. 檢查模型文件完整性
3. 運行環境檢查: `python examples/check_llama_env.py`

### 無法執行命令
```
❌ Command blocked: Path is outside project root
```

**解決方法**:
1. 確認要操作的路徑在項目根目錄內
2. 檢查 `config/agent_config.yaml` 中的 `project_root` 設定
3. 查看 `forbidden_paths` 列表

### 意圖識別不準確

**解決方法**:
1. 使用更明確的語言描述
2. 直接說明動作，如 "run dir" 而不是 "我想看看文件"
3. 查看日誌了解 Llama 的識別結果

## 📝 開發計劃

根據 `docs/llama/AI_AGENT_PLAN.md`，當前已完成：

- ✅ Phase 1: 核心框架（SafetyChecker, IntentRecognizer, ToolRouter）
- ✅ Phase 2: 工具執行器（CommandExecutor, FileOperator, Logger）
- ✅ Phase 3: 主程式和對話循環

未來計劃：
- ⏳ Phase 4: 進階功能（錯誤恢復、歷史記錄）
- ⏳ Phase 5: 完整測試
- ⏳ Phase 6: 優化和文檔

## 🤝 貢獻

如果您發現問題或有改進建議，請：
1. 查看操作日誌: `config/logs/agent_log.txt`
2. 記錄問題詳情
3. 提出改進方案

## 📚 相關文檔

- [AI Agent 詳細計劃](../docs/llama/AI_AGENT_PLAN.md)
- [Llama 設置指南](../docs/llama/SETUP_PLAN.md)
- [快速參考](../docs/llama/QUICK_REFERENCE.md)

## ⚠️ 注意事項

1. **首次使用**: 建議在測試環境中先試用
2. **命令確認**: 不要跳過確認步驟，仔細檢查要執行的命令
3. **日誌檢查**: 定期查看日誌，了解 Agent 的行為
4. **安全設定**: 不要輕易修改安全相關配置
5. **模型限制**: Llama 可能無法完美理解所有指令，請使用明確的語言

## 📞 幫助

如果遇到問題：
1. 查看本文檔的故障排除部分
2. 檢查 `config/logs/agent_log.txt` 日誌
3. 運行環境檢查: `python examples/check_llama_env.py`
4. 查看詳細計劃: `docs/llama/AI_AGENT_PLAN.md`

---

**祝您使用愉快！🎉**
