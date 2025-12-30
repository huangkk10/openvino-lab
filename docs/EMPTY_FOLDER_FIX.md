# 模型資料夾為空問題修復

## 🐛 問題描述

執行 `prepare_models.ps1` 後，模型資料夾被創建但沒有檔案（只有 `.cache/` 空目錄）

## 🔍 根本原因

**原因 1：檔案過濾器錯誤**
```powershell
# ❌ 舊版本：使用錯誤的檔案模式
allow_patterns=['*.safetensors', '*.onnx', '*.pb', ...]
```

ulkaa 的 OpenVINO 模型使用 `.xml` 和 `.bin` 格式，但腳本只下載 `.safetensors` 和 `.onnx` 檔案，導致**沒有檔案被下載**。

**原因 2：資料夾存在檢查不夠嚴格**
```powershell
# ❌ 舊版本：只檢查目錄是否存在
if (Test-Path $ModelPath) {
    return $true  # 直接跳過下載
}
```

即使資料夾為空，腳本也認為模型已存在而跳過下載。

---

## ✅ 解決方案

### 已修復的問題

**修復 1：移除檔案過濾器**
```powershell
# ✅ 新版本：下載所有檔案
snapshot_download(
    repo_id=model_name,
    local_dir=save_dir,
    repo_type='model',
    resume_download=True,
    local_dir_use_symlinks=False
    # 不使用 allow_patterns，下載全部
)
```

**修復 2：檢查實際檔案存在**
```powershell
# ✅ 新版本：檢查必需檔案
$RequiredFiles = @('openvino_model.xml', 'openvino_model.bin', 'config.json')
$AllFilesExist = $true

if (Test-Path $ModelPath) {
    foreach ($file in $RequiredFiles) {
        if (-not (Test-Path (Join-Path $ModelPath $file))) {
            $AllFilesExist = $false
            break
        }
    }
    
    if ($AllFilesExist) {
        return $true  # 完整模型，跳過
    } else {
        # 資料夾存在但不完整，重新下載
    }
}
```

**修復 3：更準確的驗證**
```powershell
# ✅ 新版本：檢查 OpenVINO 特定檔案
$RequiredFiles = @(
    'openvino_model.xml',  # OpenVINO 模型結構
    'openvino_model.bin',  # OpenVINO 模型權重
    'config.json'          # 配置
)
```

---

## 🚀 如何修復您的情況

### 步驟 1：刪除空的模型資料夾

```powershell
# 進入項目目錄
cd c:\Users\svd\codes\openvino-lab

# 刪除空的模型資料夾
Remove-Item -Path ".\models\TinyLlama-1.1B-Chat-int4" -Recurse -Force

# 確認已刪除
Get-ChildItem .\models\
```

### 步驟 2：重新下載模型

```powershell
# 激活虛擬環境
.\venv\Scripts\Activate.ps1

# 運行更新後的腳本
.\scripts\prepare_models.ps1

# 選擇模型 (推薦選項 1)
# 1) TinyLlama-1.1B-Chat-int4 - 600MB (Quantization: int4)
```

### 步驟 3：驗證下載成功

```powershell
# 查看模型資料夾內容
Get-ChildItem ".\models\TinyLlama-1.1B-Chat-int4" | Select-Object Name, Length | Format-Table -AutoSize
```

**預期輸出：**
```
Name                       Length
----                       ------
config.json                   XXX
generation_config.json        XXX
openvino_model.bin     XXXXXXXXXX  ← 最大的檔案 (~600MB)
openvino_model.xml            XXX
tokenizer_config.json         XXX
tokenizer.json                XXX
special_tokens_map.json       XXX
```

---

## 📊 下載進度監控

### 方法 1：PowerShell 即時輸出

下載過程中會顯示：
```
Starting download: ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-asym-int4
Save location: C:\Users\svd\codes\openvino-lab\models\TinyLlama-1.1B-Chat-int4
Downloading files...
Model download completed
```

### 方法 2：檢查資料夾大小

在另一個 PowerShell 視窗：
```powershell
# 持續監控資料夾大小
while ($true) {
    $size = (Get-ChildItem ".\models\TinyLlama-1.1B-Chat-int4" -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "Current size: $([math]::Round($size, 2)) MB" -NoNewline
    Write-Host "`r" -NoNewline
    Start-Sleep -Seconds 2
}
```

按 `Ctrl+C` 停止監控

---

## 🔍 故障排除

### ❌ 問題：下載仍然失敗

**症狀：** 看到錯誤訊息或下載中斷

**解決方案：**

```powershell
# 1. 檢查網絡連接
Test-Connection huggingface.co

# 2. 使用中國鏡像（如果 HuggingFace 被阻擋）
$env:HF_ENDPOINT="https://hf-mirror.com"
.\scripts\prepare_models.ps1

# 3. 手動測試下載
python -c "from huggingface_hub import snapshot_download; snapshot_download('ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-asym-int4', local_dir='./test_download')"
```

### ❌ 問題：下載速度太慢

**症狀：** 下載速度 < 100 KB/s

**解決方案：**

1. **使用中國鏡像：**
   ```powershell
   $env:HF_ENDPOINT="https://hf-mirror.com"
   ```

2. **使用代理（如果有）：**
   ```powershell
   $env:HTTP_PROXY="http://your-proxy:port"
   $env:HTTPS_PROXY="http://your-proxy:port"
   ```

3. **稍後再試：** HuggingFace 伺服器在高峰時段可能較慢

### ❌ 問題：驗證失敗但檔案存在

**症狀：** 看到 "Missing required files" 但檔案確實存在

**解決方案：**

```powershell
# 手動檢查檔案
Get-ChildItem ".\models\TinyLlama-1.1B-Chat-int4" -Recurse

# 如果看到 openvino_model.xml 和 openvino_model.bin，可以直接測試推理
python scripts/run_inference.py
```

---

## 📝 技術細節

### OpenVINO 模型格式

ulkaa 的模型已經是 **OpenVINO IR 格式**：

| 檔案 | 用途 | 大小 |
|------|------|------|
| `openvino_model.xml` | 模型結構定義 | ~KB |
| `openvino_model.bin` | 模型權重 | ~600MB (int4) |
| `config.json` | 模型配置 | ~KB |
| `tokenizer.json` | 分詞器 | ~KB |
| `generation_config.json` | 生成參數 | ~KB |

**不需要轉換**：這些模型可以直接用於 OpenVINO GenAI 推理。

### 為什麼之前的過濾器不工作

HuggingFace 上有多種模型格式：

| 格式 | 檔案類型 | 用於 |
|------|---------|------|
| PyTorch | `.safetensors`, `.bin` | 原始 PyTorch 模型 |
| ONNX | `.onnx` | ONNX Runtime |
| **OpenVINO IR** | `.xml`, `.bin` | **OpenVINO** ✅ |
| TensorFlow | `.pb` | TensorFlow |

舊腳本只下載 PyTorch/ONNX 檔案，但 ulkaa 的模型是 OpenVINO 格式。

---

## ✅ 修復驗證檢查表

- [ ] 刪除了空的模型資料夾
- [ ] 運行了更新後的 `prepare_models.ps1`
- [ ] 看到 "Starting download" 訊息
- [ ] 看到 "Model download completed" 訊息
- [ ] 資料夾包含 `openvino_model.xml` 和 `openvino_model.bin`
- [ ] 驗證顯示 "Model verification successful"
- [ ] 資料夾大小約 600MB (int4) / 800MB (int8) / 1.2GB (fp16)

---

## 🔗 相關文件

- 📖 [Stage 7 設置指南](setup/STAGE_7_GUIDE.md)
- 📖 [模型下載修復指南](MODEL_DOWNLOAD_FIX.md)
- 📖 [PowerShell 腳本修復報告](POWERSHELL_FIX_REPORT.md)

---

**總結：** 腳本已修復，現在會正確下載 OpenVINO 模型的所有檔案。請刪除空資料夾後重新運行腳本。
