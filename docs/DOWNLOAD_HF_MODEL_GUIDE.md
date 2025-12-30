# HuggingFace 通用模型下載指南

> **最新方案 (C)：** 使用 Python 腳本 `scripts/download_hf_model.py` 下載任何 HuggingFace 模型

## 📋 概述

此文件說明如何使用新的通用下載工具下載來自 HuggingFace Hub 的任何模型。

### ✨ 特點

- ✅ **完全參數化** - 支援任何 HuggingFace 模型
- ✅ **互動式菜單** - 預設常用模型，也支援自訂
- ✅ **自動進度跟蹤** - 支援斷點續傳
- ✅ **驗證機制** - 自動驗證模型完整性
- ✅ **模型清單** - 建立 .manifest.json 記錄
- ✅ **友好的錯誤提示** - 詳細的故障排除建議

---

## 🚀 快速開始

### 方式 1：命令行（推薦 - 適合快速下載）

```powershell
# 激活虛擬環境
.\venv\Scripts\Activate.ps1

# 下載指定模型
python scripts/download_hf_model.py \
    --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \
    --model-name "open_llama_7b_v2-int4"
```

### 方式 2：互動式菜單（適合菜單選擇）

```powershell
# 激活虛擬環境
.\venv\Scripts\Activate.ps1

# 執行互動式菜單
.\scripts\download_model_interactive.ps1
```

### 方式 3：PowerShell 腳本（完全自動化）

```powershell
# 直接下載，無需互動
.\scripts\download_model_interactive.ps1 `
    -RepoId "OpenVINO/open_llama_7b_v2-int4-ov" `
    -ModelName "open_llama_7b_v2-int4"
```

---

## 📝 使用範例

### 範例 1：下載 OpenLLaMA 7B（OpenVINO 優化）

```powershell
python scripts/download_hf_model.py \
    --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \
    --model-name "open_llama_7b_v2-int4"
```

**預期結果：**
- 下載大小：~3.5GB
- 保存位置：`./models/open_llama_7b_v2-int4/`
- 包含檔案：openvino_model.xml, openvino_model.bin, config.json, tokenizer.json 等

### 範例 2：下載到自訂位置

```powershell
python scripts/download_hf_model.py \
    --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \
    --output-path "D:/MyModels/open_llama"
```

### 範例 3：下載 TinyLlama PyTorch 版本

```powershell
python scripts/download_hf_model.py \
    --repo-id "TinyLlama/TinyLlama-1.1B-Chat-v1.0" \
    --model-name "tinyllama-pytorch" \
    --output-dir "./models"
```

### 範例 4：下載並跳過驗證

```powershell
python scripts/download_hf_model.py \
    --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \
    --no-verify  # 跳過驗證步驟
```

### 範例 5：使用互動式菜單

```powershell
.\scripts\download_model_interactive.ps1

# 然後選擇編號：
# 1) OpenLLaMA 7B (OpenVINO int4)
# 2) TinyLlama 1.1B (OpenVINO int4)
# 3) TinyLlama 1.1B (PyTorch)
# 4) Qwen 7B (OpenVINO)
# 5) 自訂模型（手動輸入）
```

---

## 📚 命令參考

### Python 腳本 - `download_hf_model.py`

```bash
python scripts/download_hf_model.py [OPTIONS]
```

**必要參數：**
```
--repo-id TEXT              HuggingFace Repository ID
                           例如：OpenVINO/open_llama_7b_v2-int4-ov
```

**可選參數：**
```
--model-name TEXT          本地模型名稱（預設：repo-id 的最後部分）
--output-dir PATH          輸出目錄（預設：./models）
--output-path PATH         完整輸出路徑（覆蓋 --output-dir）
--no-verify               跳過下載後的驗證步驟
--no-manifest             不建立 .manifest.json 文件
-h, --help                顯示幫助信息
```

**範例：**
```bash
# 基本用法
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"

# 完整用法
python scripts/download_hf_model.py \
    --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \
    --model-name "open_llama_7b_v2-int4" \
    --output-dir "./models"

# 自訂路徑
python scripts/download_hf_model.py \
    --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \
    --output-path "E:/LargeModels/open_llama"

# 跳過驗證
python scripts/download_hf_model.py \
    --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \
    --no-verify
```

### PowerShell 腳本 - `download_model_interactive.ps1`

```powershell
.\scripts\download_model_interactive.ps1 [OPTIONS]
```

**可選參數：**
```
-RepoId TEXT              HuggingFace Repository ID
-ModelName TEXT           本地模型名稱
-OutputDir PATH           輸出目錄（預設：./models）
```

**範例：**
```powershell
# 互動式菜單
.\scripts\download_model_interactive.ps1

# 直接下載
.\scripts\download_model_interactive.ps1 `
    -RepoId "OpenVINO/open_llama_7b_v2-int4-ov" `
    -ModelName "open_llama_7b_v2-int4" `
    -OutputDir "./models"
```

---

## 🎯 預設模型列表

以下模型已在 `download_model_interactive.ps1` 中預設配置：

### 大型模型

| # | 模型 | Repository ID | 大小 | 量化 |
|---|------|---------------|------|------|
| 1 | OpenLLaMA 7B | OpenVINO/open_llama_7b_v2-int4-ov | 3.5GB | int4 |
| 4 | Qwen 7B | OpenVINO/Qwen1.5-7B-Chat-int4-ov | 3.8GB | int4 |

### 小型模型

| # | 模型 | Repository ID | 大小 | 格式 |
|---|------|---------------|------|------|
| 2 | TinyLlama 1.1B | ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-asym-int4 | 600MB | OpenVINO |
| 3 | TinyLlama 1.1B | TinyLlama/TinyLlama-1.1B-Chat-v1.0 | 2.2GB | PyTorch |

### 自訂模型

| # | 說明 |
|---|------|
| 5 | 輸入任何 HuggingFace Repository ID |

---

## 📂 下載後的文件結構

```
models/
├── open_llama_7b_v2-int4/
│   ├── openvino_model.xml        # 模型圖定義
│   ├── openvino_model.bin        # 模型權重（主要文件）
│   ├── config.json               # 模型配置
│   ├── tokenizer.json            # 分詞器
│   ├── tokenizer_config.json     # 分詞器配置
│   ├── generation_config.json    # 生成參數
│   ├── ...                        # 其他支援文件
│   └── .manifest.json            # 下載記錄（新增）
│
├── tinyllama-pytorch/
│   ├── pytorch_model.bin
│   ├── config.json
│   ├── tokenizer.json
│   └── .manifest.json
│
└── [其他模型...]
```

### 模型清單 (`.manifest.json`)

每個模型目錄都會自動建立 `.manifest.json` 文件：

```json
{
  "model_name": "open_llama_7b_v2-int4",
  "repo_id": "OpenVINO/open_llama_7b_v2-int4-ov",
  "downloaded_at": "2025-12-30T10:30:45.123456",
  "downloaded_from": "HuggingFace Hub",
  "local_path": "C:\\Users\\svd\\codes\\openvino-lab\\models\\open_llama_7b_v2-int4"
}
```

---

## ⚙️ 進階配置

### 設定 HuggingFace 鏡像加速下載

如果下載速度慢，可以使用鏡像源：

```powershell
# 臨時設定（僅本次運行）
$env:HF_ENDPOINT="https://hf-mirror.com"
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"

# 或使用其他鏡像
$env:HF_ENDPOINT="https://huggingface.co"  # 官方（預設）
```

### 設定 HuggingFace Token（私有模型）

如果要下載私有模型，需要驗證：

```powershell
# 設定環境變量
$env:HF_TOKEN="your_token_here"
python scripts/download_hf_model.py --repo-id "your-org/private-model"

# 或使用 huggingface-cli
huggingface-cli login
```

### 批量下載多個模型

```powershell
# 建立 download_batch.ps1
$models = @(
    @{repo="OpenVINO/open_llama_7b_v2-int4-ov"; name="open_llama"},
    @{repo="TinyLlama/TinyLlama-1.1B-Chat-v1.0"; name="tinyllama"}
)

foreach ($model in $models) {
    Write-Host "下載 $($model.name)..." -ForegroundColor Cyan
    python scripts/download_hf_model.py `
        --repo-id $model.repo `
        --model-name $model.name
}
```

---

## 🔧 故障排除

### ❌ 錯誤：huggingface_hub 未安裝

```
❌ 錯誤：huggingface_hub 未安裝
💡 請執行：pip install huggingface_hub
```

**解決方案：**
```powershell
pip install huggingface_hub
```

### ❌ 錯誤：Repository Not Found

```
Repository Not Found
```

**可能原因和解決方案：**
1. Repository ID 拼寫錯誤 → 檢查 repo-id 是否正確
2. 模型不存在 → 訪問 https://huggingface.co 搜尋模型
3. 模型為私有 → 需要驗證（見上方 Token 設定）

### ❌ 錯誤：401 Unauthorized

```
401 Client Error: Unauthorized
```

**解決方案：**
1. 如果是公開模型，檢查網絡連接
2. 如果是私有模型，需要設定 HuggingFace Token
3. 嘗試升級 huggingface_hub：`pip install --upgrade huggingface_hub`

### ❌ 下載中斷

如果下載因網絡原因中斷，再次執行相同命令會自動**繼續下載**（不會重新開始）：

```powershell
# 第一次下載（中途中斷）
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"

# 稍後繼續（自動續傳）
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"
```

### ❌ 磁盤空間不足

```
OSError: [Errno 28] No space left on device
```

**解決方案：**
1. 檢查磁盤剩餘空間：`Get-Volume`
2. 選擇更小的模型或清理磁盤
3. 下載到另一個驅動器：`--output-path "E:/Models/..."`

### ❌ 驗證失敗

```
❌ 缺少必要文件：openvino_model.bin
```

**解決方案：**
1. 再次執行下載命令（會自動重試）
2. 使用 `--no-verify` 跳過驗證
3. 手動刪除不完整的模型目錄，重新下載

---

## 📖 相關文檔

- [`QUICKSTART.md`](../../QUICKSTART.md) - 推理快速開始
- [`docs/setup/STAGE_7_GUIDE_NEW.md`](../setup/STAGE_7_GUIDE_NEW.md) - 推理設置完整指南
- [`docs/PREPARE_MODELS_GUIDE.md`](./PREPARE_MODELS_GUIDE.md) - OpenVINO 模型準備指南
- [`scripts/download_model_interactive.ps1`](../scripts/download_model_interactive.ps1) - 互動式菜單腳本

---

## 💡 最佳實踐

### 下載前的檢查清單

- [ ] 確認網絡連接正常
- [ ] 檢查磁盤剩餘空間是否足夠
- [ ] 確認虛擬環境已激活 (`env:VIRTUAL_ENV` 或看到 `(venv)` 前綴)
- [ ] 驗證 Repository ID 無誤（可在 HuggingFace 網站查證）

### 下載後的檢查清單

- [ ] 模型完整性驗證成功（自動進行，可用 `--no-verify` 跳過）
- [ ] `.manifest.json` 文件已建立（記錄下載信息）
- [ ] 包含必要的文件：
  - OpenVINO 模型：`openvino_model.xml` + `openvino_model.bin`
  - PyTorch 模型：`pytorch_model.bin` 或 `model.safetensors`
  - 配置文件：`config.json` + `tokenizer.json`

### 模型使用

- 🎯 **OpenVINO 優化模型**（`.xml` + `.bin`）
  - 需要：OpenVINO GenAI 庫（目前不兼容，等待修復）
  - 優點：小巧快速
  - 狀態：下載成功，推理方案待完善

- 🎯 **PyTorch 模型**（`.bin` 或 `.safetensors`）
  - 需要：Transformers + PyTorch
  - 使用方式：`python scripts/run_inference_simple.py`
  - 狀態：完全可用 ✅

---

## 🎓 學習資源

- [HuggingFace Hub 官方文檔](https://huggingface.co/docs/hub/index)
- [huggingface_hub 庫 API 參考](https://huggingface.co/docs/huggingface_hub/package_reference/file_download)
- [OpenVINO 模型列表](https://huggingface.co/OpenVINO)
- [Transformers 模型](https://huggingface.co/models)

---

**最後更新：** 2025-12-30  
**版本：** 1.0（方案 C - Python 通用下載工具）
