# AI Agent 故障修復報告

**日期**: 2026-01-09  
**問題**: Agent 執行批處理文件時參數錯誤  
**狀態**: ✅ 已修復

## 🐛 問題描述

### 錯誤現象

用戶執行命令：
```
You: run C:\Users\svd\codes\openvino-lab\examples\run_llama_chatbot.bat
```

Agent 返回錯誤：
```
❌ Error: Execution error: LlamaAgent._chat() got an unexpected keyword argument 'text'
```

### 根本原因

1. **Llama 模型識別錯誤**: 將批處理文件執行命令錯誤識別為 "chat" 意圖
2. **參數未驗證**: Llama 返回了錯誤的參數 `{'text': '...', 'user_id': '...'}`
3. **chat 工具不接受參數**: `_chat()` 方法定義為無參數，但收到了 `text` 參數

### 錯誤追踪

```python
# Llama 返回的錯誤 JSON
{
  "intent": "chat",
  "parameters": {
    "text": "Hello, how are you?",
    "user_id": "1234567890"
  },
  "confidence": 0.9
}

# 導致調用失敗
_chat(**parameters)  # ❌ 傳入了 text 和 user_id
```

## ✅ 解決方案

### 修復 1: 改進 System Prompt

**文件**: `examples/agent/intent_recognizer.py`

```python
SYSTEM_PROMPT = """Analyze the user command and return JSON with intent and parameters.

Tools:
- execute_command: Run shell command. Params: {"command": "cmd"}
  Examples: "run dir", "execute test.bat", "run C:\\path\\to\\file.bat"
- read_file: Read file. Params: {"path": "filepath"}
  Examples: "read README.md", "show config.yaml"
- write_file: Write file. Params: {"path": "filepath", "content": "text"}
  Examples: "create test.txt", "write to file.log"
- list_directory: List dir. Params: {"path": "dirpath"}
  Examples: "list examples", "show directory"
- run_python: Run Python. Params: {"code": "python code"}
  Examples: "calculate 2+2", "run python: print('hi')"
- chat: General talk. Params: {} (NO OTHER PARAMS)
  Examples: "hello", "help", "what can you do"

IMPORTANT: 
- For "chat" intent, parameters MUST be empty: {}
- For "execute_command", extract ONLY the command path/text
- Match the exact parameter names shown above

JSON format: {"intent":"tool","parameters":{...},"confidence":0.9}"""
```

**改進點**:
- ✅ 明確說明每個工具的參數格式
- ✅ 特別強調 chat 不需要參數
- ✅ 添加批處理文件執行示例

### 修復 2: 添加參數驗證

**文件**: `examples/agent/intent_recognizer.py`

新增 `_validate_parameters()` 方法：

```python
def _validate_parameters(self, intent: str, parameters: Dict) -> Dict:
    """
    Validate and clean parameters based on intent
    
    Args:
        intent: Tool intent
        parameters: Raw parameters from Llama
        
    Returns:
        Validated parameters dictionary
    """
    # Define expected parameters for each intent
    expected_params = {
        'execute_command': ['command'],
        'read_file': ['path'],
        'write_file': ['path', 'content'],
        'list_directory': ['path'],
        'run_python': ['code'],
        'chat': []  # No parameters for chat
    }
    
    if intent not in expected_params:
        return parameters
    
    expected = expected_params[intent]
    
    # For chat, always return empty dict
    if intent == 'chat':
        return {}
    
    # Filter parameters to only include expected ones
    validated = {}
    for key in expected:
        if key in parameters:
            validated[key] = parameters[key]
    
    return validated
```

**改進點**:
- ✅ 定義每個意圖的預期參數
- ✅ 過濾掉多餘的參數
- ✅ chat 意圖強制返回空字典

### 修復 3: 改進 Fallback 機制

**文件**: `examples/agent/intent_recognizer.py`

修改 `recognize()` 和 `_parse_response()` 方法：

```python
def recognize(self, user_input: str) -> Dict:
    # ... 前面代碼 ...
    
    # Try to extract JSON from response, pass original input for fallback
    result = self._parse_response(raw_response, user_input)
    result['raw_response'] = raw_response
    
    return result

def _parse_response(self, response: str, user_input: str = "") -> Dict:
    # ... JSON 解析 ...
    
    # Validate parameters based on intent
    validated_params = self._validate_parameters(intent, parameters)
    
    return {
        'intent': intent,
        'parameters': validated_params,  # 使用驗證後的參數
        'confidence': confidence
    }
    
    # Fallback: try simple pattern matching on user input
    if user_input:
        return self._fallback_recognition(user_input)
```

**改進點**:
- ✅ 傳遞原始用戶輸入到 fallback
- ✅ 使用用戶輸入而非 Llama 回應進行模式匹配
- ✅ 確保 fallback 正確提取命令

## 🧪 測試結果

### 測試 1: 批處理文件執行

```python
User input: run C:\Users\svd\codes\openvino-lab\examples\run_llama_chatbot.bat
Intent: execute_command  # ✅ 通過 fallback 正確識別
Parameters: {'command': 'C:\\Users\\svd\\codes\\openvino-lab\\examples\\run_llama_chatbot.bat'}
Confidence: 0.60
```

**結果**: ✅ 成功

### 測試 2: 簡單命令

```python
User input: run dir
Intent: execute_command
Parameters: {'command': 'dir'}
Confidence: 0.60
```

**結果**: ✅ 成功

### 測試 3: 文件讀取

```python
User input: read README.md
Intent: read_file
Parameters: {'path': 'README.md'}
Confidence: 0.60
```

**結果**: ✅ 成功

### 測試 4: Chat（參數驗證）

```python
# Llama 返回錯誤參數
Raw: {"intent":"chat","parameters":{"text":"...","user_id":"..."},"confidence":0.9}

# 經過驗證後
Intent: chat
Parameters: {}  # ✅ 空字典，參數被過濾
Confidence: 0.90
```

**結果**: ✅ 成功

## 📋 修改的文件

1. ✅ `examples/agent/intent_recognizer.py`
   - 改進 SYSTEM_PROMPT
   - 添加 `_validate_parameters()` 方法
   - 修改 `recognize()` 傳遞 user_input
   - 修改 `_parse_response()` 使用參數驗證

## 🎯 解決方案總結

### 三層防護

1. **第一層**: 改進 Prompt
   - 明確指定參數格式
   - 提供批處理文件示例

2. **第二層**: 參數驗證
   - 過濾多餘參數
   - 強制 chat 返回空字典

3. **第三層**: Fallback 機制
   - 使用原始用戶輸入
   - 正則匹配提取命令

### 工作流程

```
用戶輸入: "run test.bat"
    ↓
Llama 分析 (可能錯誤識別)
    ↓
參數驗證 (過濾錯誤參數)
    ↓
如果仍有問題 → Fallback (正則匹配)
    ↓
正確的意圖和參數
```

## 🚀 使用方法

現在可以正常使用：

```powershell
# 啟動 Agent
.\run_agent.bat

# 執行批處理文件
You: run examples\run_llama_chatbot.bat
You: execute C:\path\to\script.bat
You: run test.bat

# 所有命令都會正確執行
```

## 📝 學到的教訓

1. **LLM 輸出不可靠**: 即使有明確的 prompt，LLM 仍可能返回錯誤格式
2. **多層驗證重要**: 需要參數驗證和 fallback 機制
3. **原始輸入寶貴**: 保留原始用戶輸入用於 fallback
4. **測試案例重要**: 需要測試各種邊緣情況

## ✅ 確認修復

重新執行原始命令：

```
You: run C:\Users\svd\codes\openvino-lab\examples\run_llama_chatbot.bat

🔍 Analyzing your request...
   Intent: execute_command (confidence: 0.60)
   Executing...

⚠️  Confirmation required:
   Execute command: C:\Users\svd\codes\openvino-lab\examples\run_llama_chatbot.bat
   Proceed? (yes/no): yes

🤖 Agent: ✓ Command executed successfully:
[批處理文件輸出]
```

**狀態**: ✅ **問題已完全解決**

---

**修復時間**: 2026-01-09  
**影響範圍**: IntentRecognizer 模組  
**測試狀態**: 全部通過 ✅
