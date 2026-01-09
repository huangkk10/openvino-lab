# AI Agent 執行批處理文件 - 快速示範

## 🚀 一分鐘快速示範

### 步驟 1: 啟動 AI Agent

在 PowerShell 中執行：
```powershell
cd C:\Users\svd\codes\openvino-lab
.\run_agent.bat
```

### 步驟 2: 等待 Agent 初始化

您會看到：
```
Initializing Llama AI Agent...
  Loading SafetyChecker...
  Loading Llama model for intent recognition...
  Initializing tool router...
  Setting up executors...
  Initializing logger...
✓ Llama AI Agent initialized successfully!

================================================================================
🤖 Llama AI Agent - Interactive Mode
================================================================================

You: 
```

### 步驟 3: 執行批處理文件

輸入以下命令（選擇其中一個）：

#### 選項 A: 直接命令
```
run examples\run_llama_chatbot.bat
```

#### 選項 B: 自然語言
```
execute the chatbot batch file
```

#### 選項 C: 完整路徑
```
run C:\Users\svd\codes\openvino-lab\examples\run_llama_chatbot.bat
```

### 步驟 4: 確認執行

Agent 會顯示：
```
⚠️  Confirmation required:
   Execute command: examples\run_llama_chatbot.bat
   Proceed? (yes/no): 
```

輸入 `yes` 並按 Enter。

### 步驟 5: 查看結果

Agent 會執行批處理文件並顯示輸出：
```
🤖 Agent: ✓ Command executed successfully:

=== Llama Chatbot - Quick Run Hint ===
[批處理文件的輸出]
```

## 💡 其他有用的命令

在 Agent 中嘗試：

### 查看所有批處理文件
```
You: list all bat files
```

### 讀取批處理文件內容
```
You: read examples\run_llama_chatbot.bat
```

### 創建新的批處理文件
```
You: create test.bat with echo Hello World
```

### 執行 Python 腳本
```
You: run python examples\check_llama_env.py
```

### 查看目錄內容
```
You: list examples folder
```

### 退出 Agent
```
You: quit
```

## 🎬 完整示範腳本

複製並按順序執行：

```
# 在 PowerShell 中
cd C:\Users\svd\codes\openvino-lab
.\run_agent.bat

# Agent 啟動後，依次輸入：

# 1. 列出批處理文件
list all bat files

# 2. 讀取批處理文件
read run_agent.bat

# 3. 執行批處理文件
run examples\run_llama_chatbot.bat

# 4. 確認執行
yes

# 5. 查看日誌
read config\logs\agent_log.txt

# 6. 退出
quit
```

## 📊 預期輸出示例

```
PS C:\Users\svd\codes\openvino-lab> .\run_agent.bat
Initializing Llama AI Agent...
  Loading SafetyChecker...
  Loading Llama model for intent recognition...
  Initializing tool router...
  Setting up executors...
  Initializing logger...
✓ Llama AI Agent initialized successfully!

================================================================================
🤖 Llama AI Agent - Interactive Mode
================================================================================

I can help you with:
  • Execute shell commands (e.g., 'run dir', 'list files')
  • Read files (e.g., 'read README.md')
  • Write files (e.g., 'create test.txt with hello')
  • List directories (e.g., 'list examples folder')
  • Run Python code (e.g., 'calculate 2+2')

Type 'quit', 'exit', or 'bye' to end the session.
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

You: quit

👋 Goodbye! Ending session...
```

## 🎯 關鍵點

1. ✅ AI Agent 會自動理解您的意圖
2. ✅ 執行前會要求確認（安全保護）
3. ✅ 所有操作都會記錄到日誌
4. ✅ 支援自然語言命令
5. ✅ 可以執行任何批處理文件

## 🔗 相關文檔

- [AI Agent 完整使用指南](AI_AGENT_GUIDE.md)
- [AI Agent 詳細計劃](AI_AGENT_PLAN.md)
- [批處理執行完整指南](AI_AGENT_BAT_EXECUTION_GUIDE.md)

---

**準備好了嗎？現在就啟動 AI Agent 試試吧！** 🚀
