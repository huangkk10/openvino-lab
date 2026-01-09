# AI Agent 執行批處理文件指南

## 🎯 如何使用 AI Agent 執行 .bat 文件

### 快速開始

1. **啟動 AI Agent**
```powershell
.\run_agent.bat
```

2. **執行批處理文件**

AI Agent 啟動後，在提示符輸入以下任一命令：

```
You: run examples\run_llama_chatbot.bat
```

或使用自然語言：

```
You: execute the chatbot batch file
```

```
You: run run_llama_chatbot.bat in examples folder
```

## 📝 實際示例對話

### 示例 1: 執行批處理文件

```
================================================================================
🤖 Llama AI Agent - Interactive Mode
================================================================================

You: run examples\run_llama_chatbot.bat

🔍 Analyzing your request...
   Intent: execute_command (confidence: 0.85)
   Executing...

⚠️  Confirmation required:
   Execute command: examples\run_llama_chatbot.bat
   Proceed? (yes/no): yes

🤖 Agent: ✓ Command executed successfully:

=== Llama Chatbot - Quick Run Hint ===

1) Activate the virtual environment (PowerShell):
   .\venv\Scripts\Activate.ps1

2) Or activate for cmd (if using cmd.exe):
   .\venv\Scripts\activate.bat

3) Run the chatbot (from repo root):
   .\venv\Scripts\python.exe examples\llama_chatbot.py [DEVICE]

Example: CPU
   .\venv\Scripts\python.exe examples\llama_chatbot.py CPU

Example: GPU
   .\venv\Scripts\python.exe examples\llama_chatbot.py GPU

======================================
```

### 示例 2: 查看批處理文件內容

```
You: read examples\run_llama_chatbot.bat

🔍 Analyzing your request...
   Intent: read_file (confidence: 0.92)
   Executing...

🤖 Agent: ✓ File content (445 bytes):
@echo off
REM Print-only launcher for Llama chatbot (no execution)
...
[文件內容]
```

### 示例 3: 列出所有批處理文件

```
You: list batch files

🔍 Analyzing your request...
   Intent: execute_command (confidence: 0.75)
   Executing...

⚠️  Confirmation required:
   Execute command: dir *.bat /s /b
   Proceed? (yes/no): yes

🤖 Agent: ✓ Command executed successfully:
C:\Users\svd\codes\openvino-lab\run_agent.bat
C:\Users\svd\codes\openvino-lab\examples\run_llama_chatbot.bat
```

## 🔧 更實用的批處理文件範例

如果您想要 AI Agent 真正執行 Llama chatbot（而不只是顯示提示），可以創建一個新的批處理文件：

### 創建實際執行的批處理文件

使用 AI Agent 創建：

```
You: create a file examples\start_chatbot.bat with the following content:
@echo off
call venv\Scripts\activate.bat
python examples\llama_chatbot.py CPU
```

然後執行：

```
You: run examples\start_chatbot.bat
```

## 💡 進階用法

### 1. 帶參數執行

```
You: run examples\start_chatbot.bat GPU
```

### 2. 在特定目錄執行

```
You: run command in examples folder: start_chatbot.bat
```

### 3. 檢查批處理文件是否存在

```
You: check if run_llama_chatbot.bat exists in examples
```

### 4. 創建新的批處理文件

```
You: create a batch file to run benchmark
```

然後 Agent 會要求您提供內容，或者直接：

```
You: create file test.bat with content: @echo off & echo Hello & pause
```

## 🔒 安全提示

當 AI Agent 執行批處理文件時：

1. **確認提示**: Agent 會顯示要執行的命令並要求確認
2. **安全檢查**: 會檢查命令是否包含危險操作
3. **日誌記錄**: 所有執行都會記錄到 `config/logs/agent_log.txt`

### 被阻擋的危險命令

以下命令會被自動阻擋：
- `format` - 格式化磁碟
- `del /s` - 遞迴刪除
- `shutdown` - 關機
- `restart` - 重啟

## 📊 完整工作流程

### 使用 AI Agent 管理批處理文件

```
# 1. 啟動 Agent
.\run_agent.bat

# 2. 查看有哪些批處理文件
You: list all bat files in the project

# 3. 讀取特定批處理文件
You: read run_agent.bat

# 4. 創建新的批處理文件
You: create test.bat with echo hello world

# 5. 執行批處理文件
You: run test.bat

# 6. 檢查執行結果（查看日誌）
You: read config\logs\agent_log.txt

# 7. 退出
You: quit
```

## 🎨 實際應用場景

### 場景 1: 自動化測試

```
You: create a batch file to run all tests
Agent: [要求內容或自動生成]

You: run the test batch file
Agent: [執行並顯示結果]
```

### 場景 2: 快速啟動多個程序

```
You: create startup.bat to launch chatbot and logger
Agent: [創建文件]

You: execute startup.bat
Agent: [啟動所有程序]
```

### 場景 3: 環境檢查

```
You: run examples\check_llama_env.py as batch
Agent: [執行環境檢查]
```

## 🐛 故障排除

### 問題 1: 批處理文件找不到

```
❌ File not found: test.bat
```

**解決方法**: 使用完整路徑
```
You: run examples\test.bat
```

### 問題 2: 權限被拒絕

```
❌ Command blocked: Path is outside project root
```

**解決方法**: 確保文件在項目目錄內

### 問題 3: 批處理文件執行失敗

查看日誌：
```
You: read config\logs\agent_log.txt
```

## 📚 相關命令速查

| 意圖 | 示例命令 |
|------|---------|
| 執行批處理 | `run test.bat` |
| 讀取批處理 | `read test.bat` |
| 列出批處理 | `list bat files` |
| 創建批處理 | `create test.bat with echo hello` |
| 檢查批處理 | `check if test.bat exists` |
| 查看執行記錄 | `read agent log` |

## 🎓 實戰練習

### 練習 1: 執行現有批處理

```bash
# 啟動 Agent
.\run_agent.bat

# 在 Agent 中執行
You: run examples\run_llama_chatbot.bat
```

### 練習 2: 創建並執行新批處理

```bash
# 在 Agent 中
You: create hello.bat with @echo off and echo Hello Agent! and pause

# 執行它
You: run hello.bat
```

### 練習 3: 批處理文件管理

```bash
# 列出所有批處理文件
You: list all bat files

# 讀取特定文件
You: read run_agent.bat

# 複製文件（通過創建新文件）
You: create backup.bat with the same content as run_agent.bat
```

## ✨ 進階技巧

### 技巧 1: 鏈式命令

```
You: list examples folder, then read run_llama_chatbot.bat, then execute it
```

### 技巧 2: 條件執行

```
You: if test.bat exists, run it, otherwise create it first
```

### 技巧 3: 批量操作

```
You: run all test batch files in examples folder
```

## 📝 總結

使用 AI Agent 執行批處理文件非常簡單：

1. ✅ 啟動 Agent: `.\run_agent.bat`
2. ✅ 自然語言命令: `run examples\test.bat`
3. ✅ 確認執行: 輸入 `yes`
4. ✅ 查看結果: Agent 顯示輸出

AI Agent 讓批處理文件的使用變得更加直觀和安全！

---

**提示**: 所有操作都會記錄到 `config/logs/agent_log.txt`，您可以隨時查看執行歷史。
