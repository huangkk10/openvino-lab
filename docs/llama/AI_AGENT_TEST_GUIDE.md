# AI Agent 快速測試指南

## 🧪 手動測試步驟

啟動 Agent 後，您可以嘗試以下測試：

### 測試 1: 簡單命令執行
```
You: run dir
```
預期結果: ✓ 顯示當前目錄的文件列表

### 測試 2: 文件讀取
```
You: read README.md
```
預期結果: ✓ 顯示 README.md 的內容

### 測試 3: 目錄列表
```
You: list examples folder
```
預期結果: ✓ 顯示 examples 目錄中的文件

### 測試 4: Python 計算
```
You: calculate 2 + 2
```
預期結果: ✓ 返回計算結果 4

### 測試 5: 一般對話
```
You: hello
```
預期結果: ✓ Agent 回應介紹自己的功能

### 測試 6: 文件寫入（含確認）
```
You: create a file test.txt with hello world
```
預期結果: 
- Agent 要求確認
- 輸入 yes 後創建文件
- ✓ 顯示寫入成功

### 測試 7: 安全測試（命令阻擋）
```
You: format C:
```
預期結果: ❌ 命令被阻擋（包含禁止操作 format）

### 測試 8: 安全測試（路徑阻擋）
```
You: read C:\Windows\System32\config\sam
```
預期結果: ❌ 路徑被阻擋（超出項目根目錄）

### 測試 9: Python 代碼執行
```
You: run python code: import sys; print(sys.version)
```
預期結果: 
- Agent 要求確認
- ✓ 顯示 Python 版本

### 測試 10: 退出
```
You: quit
```
預期結果: 
- 顯示 "Goodbye!" 消息
- 會話結束並記錄到日誌

## 📋 測試檢查清單

完成每個測試後打勾：

- [ ] ✅ 測試 1: 簡單命令執行
- [ ] ✅ 測試 2: 文件讀取
- [ ] ✅ 測試 3: 目錄列表
- [ ] ✅ 測試 4: Python 計算
- [ ] ✅ 測試 5: 一般對話
- [ ] ✅ 測試 6: 文件寫入（含確認）
- [ ] ✅ 測試 7: 安全測試（命令阻擋）
- [ ] ✅ 測試 8: 安全測試（路徑阻擋）
- [ ] ✅ 測試 9: Python 代碼執行
- [ ] ✅ 測試 10: 退出

## 📊 測試後檢查

### 1. 檢查日誌
```powershell
cat config\logs\agent_log.txt
```
應該包含所有測試操作的記錄。

### 2. 驗證創建的文件
```powershell
cat config\temp\test.txt
```
應該包含 "hello world"。

### 3. 檢查安全日誌
在 `agent_log.txt` 中搜索 "SAFETY CHECK"，應該看到：
- ✓ SAFE: 合法的路徑和命令
- ✗ UNSAFE: 被阻擋的危險操作

## 🔍 故障排除

### Agent 無法啟動
1. 確認在虛擬環境中：`.\venv\Scripts\Activate.ps1`
2. 檢查模型路徑：`ls models\open_llama_7b_v2-int4-ov`
3. 驗證配置文件：`cat config\agent_config.yaml`

### 意圖識別不準確
- 使用更明確的動詞："run", "read", "list", "create"
- 檢查 Llama 的 raw_response（在日誌中）
- 信心度低於 0.3 會被拒絕

### 命令執行失敗
- 檢查是否有確認提示（輸入 "yes"）
- 查看日誌中的錯誤信息
- 確認命令在命令行中可以運行

## 🎯 成功標準

全部測試通過表示：
- ✅ Llama 模型正常工作
- ✅ 意圖識別功能正常
- ✅ 所有執行器正常工作
- ✅ 安全機制正確運作
- ✅ 用戶確認流程正常
- ✅ 日誌系統正常記錄

恭喜！您的 AI Agent 已經可以投入使用了！🎉
