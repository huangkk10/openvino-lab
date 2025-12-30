# Windows 環境設置指南

這個資料夾包含 Windows 平台的完整設置說明。

## 📋 核心檔案

| 檔案 | 用途 | 描述 |
|------|------|------|
| **[SETUP_PROGRESS.md](SETUP_PROGRESS.md)** | 📊 全流程追蹤 | 7 個階段的完整規劃、詳細步驟、驗證方法 |
| **[SETUP_WINDOWS.md](SETUP_WINDOWS.md)** | ⚙️ 詳細說明 | Windows 設置的具體操作步驟 |

## 📊 當前進度

```
[x] 第 1️⃣ 階段：前置準備              ✅ 完成
[x] 第 2️⃣ 階段：系統依賴              ✅ 完成
[ ] 第 3️⃣ 階段：虛擬環境              <-- 下一步
[ ] 第 4️⃣ 階段：套件安裝
[ ] 第 5️⃣ 階段：環境驗證
[ ] 第 6️⃣ 階段：配置設置
[ ] 第 7️⃣ 階段：模型準備
```

**詳細進度追蹤與完整指南：** 📖 見 [SETUP_PROGRESS.md](SETUP_PROGRESS.md)

---

## 🚀 快速開始指南

### 👉 選擇您的階段

下面列出 7 個設置階段。根據您目前的進度，點擊對應的階段查看說明。

---

## 第 1️⃣ 階段：前置準備

**目標：** 檢查系統是否符合最低要求

**檢查項目：**
```powershell
# 檢查 Python 版本（需要 3.10+）
python --version

# 檢查磁盤空間
Get-Volume | Select-Object DriveLetter, SizeRemaining
```

**預期結果：** Python 3.10.x 或更高 ✓

**更多詳情：** 📖 [SETUP_PROGRESS.md - 第 1️⃣ 階段](SETUP_PROGRESS.md#第-1️⃣-階段前置準備)

---

## 第 2️⃣ 階段：系統依賴 ✅ 已完成

**目標：** 安裝必要的系統級別依賴（Visual C++ Redistributable）

**快速執行：**
```powershell
# 下載 Visual C++ Redistributable
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" `
  -OutFile "$env:TEMP\vc_redist.x64.exe"

# 執行安裝程式
& "$env:TEMP\vc_redist.x64.exe" /install /quiet /norestart

# 重新啟動虛擬環境
.\venv\Scripts\Activate.ps1
```

**驗證安裝：**
```powershell
# 運行測試檢查
python scripts/test_openvino.py
```

**預期結果：** 看到 ✓ 標記表示成功

**更多詳情：** 📖 [SETUP_PROGRESS.md - 第 2️⃣ 階段](SETUP_PROGRESS.md#第-2️⃣-階段系統依賴)

---

## 第 3️⃣ 階段：虛擬環境

**目標：** 創建 Python 虛擬環境，隔離項目依賴

**快速執行：**
```powershell
# 創建虛擬環境
python -m venv venv

# 啟動虛擬環境（每次使用前需要執行）
.\venv\Scripts\Activate.ps1

# 升級 pip
python -m pip install --upgrade pip
```

**驗證：** 終端應顯示 `(venv)` 前綴

**更多詳情：** 📖 [SETUP_PROGRESS.md - 第 3️⃣ 階段](SETUP_PROGRESS.md#第-3️⃣-階段虛擬環境)

---

## 第 4️⃣ 階段：套件安裝

**目標：** 安裝 OpenVINO GenAI 和相關依賴

**快速執行：**
```powershell
# 確保虛擬環境已啟動（看到 (venv) 前綴）

# 方法 1：使用 requirements.txt
pip install -r requirements.txt

# 方法 2：自動化腳本
.\scripts\setup.ps1

# 方法 3：手動安裝
pip install openvino-genai optimum[openvino] transformers torch
```

**驗證安裝：**
```powershell
pip list | grep openvino
```

**更多詳情：** 📖 [SETUP_PROGRESS.md - 第 4️⃣ 階段](SETUP_PROGRESS.md#第-4️⃣-階段套件安裝)

---

## 第 5️⃣ 階段：環境驗證

**目標：** 驗證所有組件正常運行

**快速執行：**
```powershell
# 運行測試腳本
python scripts/test_openvino.py
```

**預期結果：**
```
✓ OpenVINO GenAI 導入成功
✓ OpenVINO 導入成功
✓ OpenVINO Tokenizers 導入成功
✓ Optimum Intel 導入成功

OpenVINO 版本: 2025.4.1
可用設備: CPU, GPU (如果有), NPU (如果有)
```

**更多詳情：** 📖 [SETUP_PROGRESS.md - 第 5️⃣ 階段](SETUP_PROGRESS.md#第-5️⃣-階段環境驗證)

---

## 第 6️⃣ 階段：配置設置

**目標：** 配置項目參數和環境變數

**快速執行：**
```powershell
# 複製環境變數模板
Copy-Item config\.env.example config\.env

# 編輯配置文件（使用編輯器打開）
notepad config\.env
```

**常用配置項：**
```
OPENVINO_DEVICE=CPU           # 推理設備 (CPU/GPU/NPU)
MODEL_PATH=./models           # 模型存儲路徑
QUANTIZATION_TYPE=FP32        # 量化類型
MAX_SEQUENCE_LENGTH=2048      # 最大序列長度
```

**更多詳情：** 📖 [SETUP_PROGRESS.md - 第 6️⃣ 階段](SETUP_PROGRESS.md#第-6️⃣-階段配置設置)

---

## 第 7️⃣ 階段：模型準備

**目標：** 下載或轉換要使用的 AI 模型

**快速執行：**
```powershell
# 使用 Optimum CLI 下載 ONNX 模型
optimum-cli export onnx \
  --model gpt2 \
  --task text-generation \
  ./models/gpt2-onnx/

# 轉換為 OpenVINO 格式
optimum-cli export openvino \
  --model gpt2 \
  --task text-generation \
  ./models/gpt2-openvino/
```

**更多詳情：** 📖 [SETUP_PROGRESS.md - 第 7️⃣ 階段](SETUP_PROGRESS.md#第-7️⃣-階段模型準備)

或查看完整模型指南：📖 [docs/MODELS.md](../MODELS.md)

---

## 🔗 相關資源

- 📖 [完整設置流程](SETUP_PROGRESS.md) - 所有 7 個階段的詳細說明
- ⚙️ [Windows 設置步驟](SETUP_WINDOWS.md) - 具體的操作說明
- 📊 [回到 docs 主目錄](../README.md) - 使用指南和文檔索引
- 🏠 [項目主目錄](../../README.md) - 項目概述
- 🆘 [故障排除](../TROUBLESHOOTING.md) - 常見問題解決

---

## ⚠️ 常見問題

### ❌ 缺少 Visual C++ Redistributable

**症狀：** `DLL load failed` 錯誤

**解決方案：** 完成 [第 2️⃣ 階段：系統依賴](#第-2️⃣-階段系統依賴-已完成) 的安裝

### ❌ PowerShell 執行策略錯誤

**症狀：** 無法執行 `.ps1` 腳本

**解決方案：**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### ❌ ModuleNotFoundError

**症狀：** 導入模組失敗

**解決方案：** 
1. 確認虛擬環境已啟動（應看到 `(venv)` 前綴）
2. 重新安裝套件（第 4️⃣ 階段）

### ❓ 更多問題？

查看完整的 [故障排除指南](../TROUBLESHOOTING.md)

---

## 📝 使用建議

1. **第一次設置：** 從第 1️⃣ 階段開始，依序完成所有 7 個階段
2. **每次使用：** 只需在第 3️⃣ 階段啟動虛擬環境
3. **遇到問題：** 查看對應階段的詳細說明和故障排除部分
4. **完成設置：** 所有階段完成後，可開始使用 OpenVINO GenAI 進行推理

---

**下一步：** 按照您目前的進度，點擊上方對應的階段標題查看詳細步驟。
