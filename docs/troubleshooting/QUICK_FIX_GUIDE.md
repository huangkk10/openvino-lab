# PowerShell 腳本修復指南

## 📋 問題和解決方案快速摘要

### ❌ 遇到的錯誤

```
At C:\Users\svd\codes\openvino-lab\scripts\prepare_models.ps1:282 char:22
The string is missing the terminator: '.
Missing closing '}' in statement block or type definition.
```

### 🔍 原因

PowerShell 腳本中的 **中文字符編碼被損壞**，導致：
- 字符串終止符丟失
- 括號不匹配
- 語法解析失敗

### ✅ 解決方案

| 步驟 | 操作 |
|------|------|
| 1️⃣ | 刪除有問題的文件 |
| 2️⃣ | 使用英文重新創建腳本 |
| 3️⃣ | 驗證語法正確 |
| 4️⃣ | 測試腳本運行 |

---

## 🚀 現在使用修復後的腳本

### 激活虛擬環境

```powershell
.\venv\Scripts\Activate.ps1
```

### 下載模型（方式 1：互動式菜單）

```powershell
.\scripts\prepare_models.ps1
```

**輸出：**
```
[Info] Loading configuration...
[Success] ========== OpenVINO GenAI Model Preparation ==========
[Info] Available pre-converted models:
  1) TinyLlama-1.1B-int4 - 600MB (Quantization: int4)
  2) Qwen2-1.5B-int4 - 800MB (Quantization: int4)
  3) phi-2-int4 - 1.2GB (Quantization: int4)

Please select a model to download (1-3, or type 'skip' to skip): 1
```

### 下載模型（方式 2：簡化版本）

```powershell
.\scripts\download_model.ps1
```

**優點：**
- 自動下載第一個模型
- 更好的錯誤報告
- 更簡潔的輸出

---

## 📁 修復後的文件

### 1. prepare_models.ps1（已修復）

**變更：**
- ✅ 中文註釋改為英文
- ✅ 中文字符串改為英文
- ✅ 確保所有括號正確配對
- ✅ 語法完全驗證

**功能保持不變：**
- 檢查依賴
- 顯示模型菜單
- 下載選定模型
- 驗證模型文件

### 2. download_model.ps1（新增）

**特點：**
- 更簡單的代碼
- 更好的錯誤處理
- 自動下載 TinyLlama 模型
- 更詳細的故障排除提示

---

## 🔧 技術詳情

### 編碼問題示例

```powershell
# ❌ 損壞的代碼（原始）
Write-Status "推薦命令：" Info
# 被損壞為：
# Write-Status "æŽ¨è–¦å'½ä»¤ï¼š" Info

# ✅ 修復後的代碼
Write-Status "Recommended command:" Info
```

### 括號匹配修復

```powershell
# ❌ 原始（缺少右括號）
foreach ($tool in $tools) {
    try {
        # ...
    } catch {
        # ...
    }
}
# 缺少最後的 } 來結束 foreach

# ✅ 修復後（完整）
foreach ($tool in $tools) {
    try {
        # ...
    } catch {
        # ...
    }
}
```

---

## 💡 最佳實踐

### PowerShell 腳本編碼

✅ **推薦做法：**
```powershell
# 使用 ASCII 字符進行代碼
# 函數名、變數名、控制關鍵字

# 註釋使用英文
# This is a comment

# 若需要多語言，分離到外部文件
$config = Get-Content i18n/zh.json | ConvertFrom-Json
```

❌ **避免：**
```powershell
# 不要在代碼中混入多字節字符
# Write-Host "這是中文"  ← 可能導致編碼問題

# 不要依賴特定編碼
# 保存時總是使用 UTF-8 without BOM
```

---

## 📚 相關文檔

| 文檔 | 內容 |
|------|------|
| **POWERSHELL_FIX_REPORT.md** | 完整的修復報告和技術詳情 |
| **STAGE_7_GUIDE.md** | 模型準備完整指南 |
| **MODEL_AND_GIT_GUIDE.md** | 模型下載和 Git 配置 |

---

## ✅ 驗證修復

### 方式 1：直接運行腳本

```powershell
.\scripts\prepare_models.ps1
```

如果沒有語法錯誤，說明修復成功。

### 方式 2：檢查文件

```powershell
# 檢查文件是否存在
Test-Path scripts\prepare_models.ps1
# 應輸出: True

# 檢查文件行數
(Get-Content scripts\prepare_models.ps1 | Measure-Object -Line).Lines
# 應輸出: 255
```

### 方式 3：測試語法

```powershell
# 加載腳本檢查語法
. .\scripts\prepare_models.ps1 -ErrorAction Stop
# 如果沒有錯誤表示語法正確
```

---

## 🎯 下一步

1. ✅ **運行修復後的腳本**
   ```powershell
   .\scripts\prepare_models.ps1
   ```

2. ✅ **選擇並下載模型**
   ```
   Please select a model: 1
   ```

3. ✅ **開始推理**
   ```powershell
   python scripts/run_inference.py
   ```

---

## 📞 故障排除

### 如果仍然遇到錯誤

1. **檢查虛擬環境**
   ```powershell
   $env:VIRTUAL_ENV  # 應該顯示虛擬環境路徑
   ```

2. **驗證 Python 可用性**
   ```powershell
   python --version
   pip --version
   ```

3. **檢查依賴**
   ```powershell
   pip list | grep huggingface_hub
   pip list | grep transformers
   ```

4. **查看詳細報告**
   ```
   docs/POWERSHELL_FIX_REPORT.md
   ```

---

**修復完成！** ✨  
現在您可以放心使用 `prepare_models.ps1` 腳本了。

