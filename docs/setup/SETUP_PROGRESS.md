# OpenVINO GenAI Windows 環境設置進度追蹤

此文檔追蹤您的 OpenVINO GenAI Windows 環境設置進度。

## 📊 設置階段概覽

```
┌─────────────────────────────────────────────────────────┐
│                  OpenVINO 環境設置流程                   │
└─────────────────────────────────────────────────────────┘

[1️⃣ 前置準備]
   └─ [ ] 檢查 Python 版本 (3.10+)
   └─ [ ] 檢查 Windows 版本
   └─ [ ] 檢查磁盤空間 (>500MB)

         ↓

[2️⃣ 系統依賴]
   └─ [ ] 下載 Visual C++ Redistributable
   └─ [ ] 安裝 Visual C++ Redistributable
   └─ [ ] 重新啟動系統/終端

         ↓

[3️⃣ 虛擬環境]
   └─ [ ] 創建 Python venv
   └─ [ ] 啟動虛擬環境
   └─ [ ] 升級 pip

         ↓

[4️⃣ 套件安裝]
   └─ [ ] 安裝 openvino-genai
   └─ [ ] 安裝 optimum[openvino]
   └─ [ ] 安裝其他依賴套件
   └─ [ ] 驗證安裝完成

         ↓

[5️⃣ 環境驗證]
   └─ [ ] 運行測試腳本
   └─ [ ] 檢查 OpenVINO 版本
   └─ [ ] 檢查可用設備 (CPU/GPU/NPU)
   └─ [ ] 確認環境就緒

         ↓

[6️⃣ 配置設置]
   └─ [ ] 複製 .env.example 為 .env
   └─ [ ] 配置模型路徑
   └─ [ ] 配置推理參數
   └─ [ ] 設置日誌級別

         ↓

[7️⃣ 模型準備]
   └─ [ ] 選擇目標模型
   └─ [ ] 下載模型
   └─ [ ] 轉換模型（如需要）
   └─ [ ] 驗證模型位置

         ↓

[✅ 就緒]
   └─ 環境完全設置，可開始推理任務
```

---

## 📋 詳細階段說明

### 第 1️⃣ 階段：前置準備

**說明：** 檢查系統要求，確保滿足最低配置。

**檢查清單：**

```powershell
# 檢查 Python 版本（需要 3.10 以上）
python --version

# 檢查可用磁盤空間
Get-Volume | Select-Object DriveLetter, SizeRemaining, Size

# 檢查 Windows 版本
[System.Environment]::OSVersion.VersionString
```

**預期結果：**
- ✅ Python 版本：3.10.x 或更高
- ✅ 磁盤可用空間：>500 MB
- ✅ Windows：10 或 11

**進度：** `[ ] 未完成` → `[x] 已完成`

---

### 第 2️⃣ 階段：系統依賴

**說明：** 安裝必要的系統級別依賴。這是最重要的一步！

**步驟：**

1. 下載 Visual C++ Redistributable
   ```
   網址: https://aka.ms/vs/17/release/vc_redist.x64.exe
   檔案: vc_redist.x64.exe (~100 MB)
   ```

2. 執行安裝程式

3. **重新啟動 PowerShell 或終端機**（重要！）

**驗證：**
```powershell
# 檢查是否安裝成功
Get-ChildItem "C:\Program Files\Microsoft Visual Studio\2022" -ErrorAction SilentlyContinue
```

**常見問題：**
- ❌ 缺少此依賴會導致 `DLL load failed` 錯誤
- ✅ 安裝後必須重新啟動終端

**進度：** `[ ] 未完成` → `[x] 已完成`

---

### 第 3️⃣ 階段：虛擬環境

**說明：** 創建隔離的 Python 環境，避免與其他項目衝突。

**步驟：**

```powershell
# 1. 導航到項目目錄
cd C:\Users\svd\codes\openvino-lab

# 2. 創建虛擬環境
python -m venv venv

# 3. 啟動虛擬環境
.\venv\Scripts\Activate.ps1

# 4. 升級 pip
python -m pip install --upgrade pip
```

**驗證：**
```powershell
# 終端應顯示 (venv) 前綴
# 例: (venv) PS C:\Users\svd\codes\openvino-lab>

# 檢查 pip 版本
pip --version
```

**進度：** `[ ] 未完成` → `[x] 已完成`

---

### 第 4️⃣ 階段：套件安裝

**說明：** 安裝 OpenVINO GenAI 和相關依賴。

**步驟：**

```powershell
# 確保虛擬環境已啟動（應看到 (venv) 前綴）

# 方法 1：使用 requirements.txt
pip install -r requirements.txt

# 方法 2：手動安裝（如果沒有 requirements.txt）
pip install openvino-genai optimum[openvino] transformers torch numpy
```

**監視安裝：**
- 觀察進度條
- 等待所有套件完成安裝
- 預計時間：2-5 分鐘（取決於網絡速度）

**驗證：**
```powershell
# 列出已安裝的套件
pip list | grep -E "(openvino|optimum|torch|transformers)"
```

**進度：** `[ ] 未完成` → `[x] 已完成`

---

### 第 5️⃣ 階段：環境驗證

**說明：** 測試環境是否正確配置。

**運行測試腳本：**

```powershell
# 確保虛擬環境已啟動
.\venv\Scripts\Activate.ps1

# 運行測試
python scripts/test_openvino.py
```

**預期輸出：**
```
============================================================
OpenVINO GenAI 環境測試
============================================================

=== 測試套件導入 ===

✓ OpenVINO GenAI 導入成功
✓ OpenVINO 導入成功
✓ OpenVINO Tokenizers 導入成功
✓ Optimum Intel 導入成功

=== 版本資訊 ===

OpenVINO 版本: 2025.4.1
OpenVINO GenAI 版本: 2025.4.1.0

=== 可用的推理設備 ===

可用設備:
  - CPU
  - GPU (如果有 Intel 顯卡)

============================================================
✅ OpenVINO GenAI 環境測試完成！
============================================================
```

**故障排除：**
- ❌ 如果看到 `DLL load failed`，回到第 2️⃣ 階段重新安裝 Visual C++ Redistributable
- ❌ 如果看到 `ModuleNotFoundError`，確認虛擬環境已啟動

**進度：** `[ ] 未完成` → `[x] 已完成`

---

### 第 6️⃣ 階段：配置設置

**說明：** 配置項目參數和環境變數。

**步驟：**

```powershell
# 1. 複製環境變數模板
Copy-Item config\.env.example config\.env

# 2. 編輯 .env 檔案（使用您喜歡的編輯器）
# 常用配置項：
#   OPENVINO_DEVICE=CPU           # 推理設備
#   MODEL_PATH=./models           # 模型存儲路徑
#   CACHE_DIR=./models/cache      # 模型緩存路徑
```

**配置項說明：**

| 配置項 | 說明 | 預設值 |
|-------|------|-------|
| `OPENVINO_DEVICE` | 推理設備 (CPU/GPU/NPU) | CPU |
| `MODEL_PATH` | 模型存儲路徑 | ./models |
| `QUANTIZATION_TYPE` | 量化類型 (FP32/FP16/INT8) | FP32 |
| `MAX_SEQUENCE_LENGTH` | 最大序列長度 | 2048 |

**進度：** `[ ] 未完成` → `[x] 已完成`

---

### 第 7️⃣ 階段：模型準備

**說明：** 下載或轉換要使用的 AI 模型。

**常見模型選項：**

```powershell
# 使用 Optimum CLI 下載 ONNX 模型
optimum-cli export onnx \
  --model gpt2 \
  --task text-generation \
  ./models/gpt2-onnx/

# 使用 Optimum CLI 轉換為 OpenVINO 格式
optimum-cli export openvino \
  --model gpt2 \
  --task text-generation \
  ./models/gpt2-openvino/
```

**詳細指南：** 見 [`docs/MODELS.md`](../MODELS.md)

**進度：** `[ ] 未完成` → `[x] 已完成`

---

## ✅ 完成檢查表

**您的當前進度：**

```markdown
- [x] 第 1️⃣ 階段：前置準備 ✅
- [x] 第 2️⃣ 階段：系統依賴 ✅
- [x] 第 3️⃣ 階段：虛擬環境 ✅
- [x] 第 4️⃣ 階段：套件安裝 ✅
- [x] 第 5️⃣ 階段：環境驗證 ✅
- [x] 第 6️⃣ 階段：配置設置 ✅
- [ ] 第 7️⃣ 階段：模型準備 <-- 您在這裡
```

將對應的階段改為 `[x]` 當您完成時。

---

## 🚨 快速故障排除

| 錯誤 | 原因 | 解決方案 |
|------|------|---------|
| `DLL load failed` | 缺少 Visual C++ Redistributable | 完成第 2️⃣ 階段 |
| `ModuleNotFoundError` | 虛擬環境未啟動或套件未安裝 | 完成第 3️⃣ 和 4️⃣ 階段 |
| `PowerShell cannot execute script` | 執行策略限制 | 執行 `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| 速度很慢 | 網絡問題或磁盤性能 | 檢查網絡，或使用更快的存儲 |

詳細故障排除見：[`TROUBLESHOOTING.md`](../TROUBLESHOOTING.md)

---

## 📞 需要幫助？

1. 檢查 [`TROUBLESHOOTING.md`](../TROUBLESHOOTING.md)
2. 查看 [`SETUP_WINDOWS.md`](SETUP_WINDOWS.md) 的詳細步驟
3. 檢查 OpenVINO 官方文檔：https://github.com/openvinotoolkit/openvino.genai

---

**最後更新：** 2025年12月30日
