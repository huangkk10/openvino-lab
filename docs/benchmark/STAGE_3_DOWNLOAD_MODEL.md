# 階段 3：下載 AI 模型

**目標：** 自動下載並驗證 OpenLLaMA 7B v2 INT4 模型  
**時間：** 10-30 分鐘（取決於網路速度）  
**難度：** ⭐⭐ 中等  
**狀態：** ✅ 已驗證

---

## 📋 本階段目標

1. 安裝 Python 依賴套件（huggingface-hub）
2. 從 Hugging Face 下載 OpenLLaMA 7B v2 INT4 模型
3. 驗證模型文件完整性
4. 確保模型可用於 benchmark 測試

---

## 🎯 為什麼需要單獨的模型下載階段？

### 設計理念

✅ **獨立性** - 模型下載獨立於環境配置，可單獨執行  
✅ **可追蹤性** - 明確的下載進度和驗證步驟  
✅ **容錯性** - 下載失敗可以重試，不影響其他階段  
✅ **一鍵化** - 提供自動化腳本，簡化操作流程

### 模型資訊

| 項目 | 說明 |
|------|------|
| **模型名稱** | OpenLLaMA 7B v2 INT4 |
| **模型來源** | Hugging Face Hub |
| **Repository** | openlm-research/open_llama_7b_v2_openvino_int4 |
| **模型大小** | ~4 GB |
| **量化格式** | INT4 (OpenVINO) |
| **適用設備** | CPU / GPU / NPU |

---

## 🚀 方式一：一鍵自動下載（推薦）

### 快速開始

```powershell
# 執行自動下載腳本
.\scripts\download_model.ps1
```

**預期輸出：**
```
========================================
  OpenVINO Model Download Tool
========================================

[STEP 1/5] Checking requirements...
  [OK] Found Python: Python 3.11.5
  [OK] pip is available

[STEP 2/5] Checking disk space...
  Available space on C: 50.25 GB
  [OK] Sufficient disk space

[STEP 3/5] Installing required packages...
  Installing huggingface-hub...
  [OK] huggingface-hub installed
  Installing optimum-intel...
  [OK] optimum-intel installed

[STEP 4/5] Downloading model...
  Model: open_llama_7b_v2-int4-ov
  Source: Hugging Face Hub
  Target: C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov

  Downloading open_llama_7b_v2-int4-ov...
  This may take several minutes (~4 GB)...

  [OK] Download complete

[STEP 5/5] Verifying model files...
  [OK] openvino_model.xml (234.5 KB)
  [OK] openvino_model.bin (3654234.2 KB)
  [OK] openvino_tokenizer.xml (45.3 KB)
  [OK] openvino_tokenizer.bin (456.7 KB)

========================================
  Model Download Complete!
========================================

  Model: open_llama_7b_v2-int4-ov
  Location: C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov
  Total Size: 3.87 GB

  The model is ready for benchmark testing.
```

### 進階選項

```powershell
# 強制重新下載（覆蓋現有模型）
.\scripts\download_model.ps1 -Force

# 自訂模型名稱和目標目錄
.\scripts\download_model.ps1 -ModelName "custom_model" -TargetDir "my_models"

# 查看幫助訊息
Get-Help .\scripts\download_model.ps1 -Full
```

---

## 🛠️ 方式二：手動下載步驟

如果自動腳本失敗，或想要手動控制下載過程，可以按照以下步驟操作。

### 步驟 3.1：安裝 Python 依賴

```powershell
# 確認 Python 已安裝
python --version

# 安裝 huggingface-hub
pip install huggingface-hub optimum-intel
```

**預期輸出：**
```
Python 3.11.5
Collecting huggingface-hub
  Downloading huggingface_hub-0.20.0-py3-none-any.whl (330 kB)
Successfully installed huggingface-hub-0.20.0
```

---

### 步驟 3.2：手動下載模型

#### 方法 A：使用 Python Script

創建 `download_manual.py`：

```python
from huggingface_hub import snapshot_download
from pathlib import Path

# 設定目標路徑
model_dir = Path("models/open_llama_7b_v2-int4-ov")
model_dir.parent.mkdir(parents=True, exist_ok=True)

print("開始下載模型...")
print("Repository: openlm-research/open_llama_7b_v2_openvino_int4")
print(f"Target: {model_dir.absolute()}")
print()

# 下載模型
try:
    snapshot_download(
        repo_id="openlm-research/open_llama_7b_v2_openvino_int4",
        local_dir=str(model_dir),
        local_dir_use_symlinks=False
    )
    print("\n✅ 模型下載完成！")
except Exception as e:
    print(f"\n❌ 下載失敗: {e}")
```

執行：
```powershell
python download_manual.py
```

#### 方法 B：使用 Hugging Face CLI

```powershell
# 安裝 Hugging Face CLI
pip install huggingface_hub[cli]

# 下載模型
huggingface-cli download openlm-research/open_llama_7b_v2_openvino_int4 --local-dir models/open_llama_7b_v2-int4-ov
```

---

### 步驟 3.3：驗證模型文件

創建 `verify_model.ps1` 驗證腳本：

```powershell
$modelPath = "models\open_llama_7b_v2-int4-ov"

Write-Host "`n=== Model Verification ===" -ForegroundColor Cyan

# 檢查必要文件
$requiredFiles = @(
    "openvino_model.xml",
    "openvino_model.bin",
    "openvino_tokenizer.xml",
    "openvino_tokenizer.bin",
    "config.json",
    "tokenizer_config.json"
)

$allFound = $true
$totalSize = 0

foreach ($file in $requiredFiles) {
    $filePath = Join-Path $modelPath $file
    if (Test-Path $filePath) {
        $fileInfo = Get-Item $filePath
        $sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
        $totalSize += $fileInfo.Length
        Write-Host "✅ $file ($sizeMB MB)" -ForegroundColor Green
    } else {
        Write-Host "❌ $file (Missing)" -ForegroundColor Red
        $allFound = $false
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
$totalSizeGB = [math]::Round($totalSize / 1GB, 2)
Write-Host "Total Size: $totalSizeGB GB" -ForegroundColor Yellow

if ($allFound) {
    Write-Host "✅ All required files present!" -ForegroundColor Green
} else {
    Write-Host "❌ Some files are missing. Please re-download." -ForegroundColor Red
}
```

執行驗證：
```powershell
.\verify_model.ps1
```

**預期輸出（成功）：**
```
=== Model Verification ===
✅ openvino_model.xml (0.23 MB)
✅ openvino_model.bin (3571.45 MB)
✅ openvino_tokenizer.xml (0.04 MB)
✅ openvino_tokenizer.bin (0.45 MB)
✅ config.json (0.00 MB)
✅ tokenizer_config.json (0.00 MB)

=== Summary ===
Total Size: 3.87 GB
✅ All required files present!
```

---

### 步驟 3.4：檢查模型結構

```powershell
# 查看模型目錄結構
cd models\open_llama_7b_v2-int4-ov
tree /F
```

**預期結構：**
```
C:\USERS\SVD\CODES\OPENVINO-LAB\MODELS\OPEN_LLAMA_7B_V2-INT4-OV
├── openvino_model.xml          ← 模型結構定義
├── openvino_model.bin          ← 模型權重（最大檔案）
├── openvino_tokenizer.xml      ← Tokenizer 結構
├── openvino_tokenizer.bin      ← Tokenizer 資料
├── config.json                 ← 模型配置
├── tokenizer_config.json       ← Tokenizer 配置
├── special_tokens_map.json     ← 特殊 Token 映射
└── README.md                   ← 模型說明文件
```

---

## ✅ 完成檢查

在進入下一階段前，確認以下項目：

- [ ] Python 和 pip 已正確安裝
- [ ] huggingface-hub 套件已安裝
- [ ] 模型已成功下載到 `models/open_llama_7b_v2-int4-ov/`
- [ ] 所有必要文件已驗證存在
- [ ] 模型總大小約 3.8-4.0 GB
- [ ] 磁碟空間充足（至少剩餘 10 GB）

---

## 📊 階段總結

### 完成項目

✅ **依賴安裝**
- Python 環境確認
- huggingface-hub 套件安裝

✅ **模型下載**
- OpenLLaMA 7B v2 INT4 模型
- 自動驗證文件完整性

✅ **環境準備**
- 模型可用於 benchmark 測試
- 目錄結構正確建立

### 關鍵成果

🤖 **AI 模型就緒**
- OpenVINO 優化格式
- INT4 量化提升性能
- 支援多種設備（CPU/GPU/NPU）

### 下一階段預告

在 [階段 4：配置執行腳本](STAGE_4_CREATE_SCRIPT.md) 中，我們將：
1. 創建 benchmark 執行腳本
2. 配置環境變數和 PATH
3. 設定模型路徑參數

---

## ⚠️ 故障排除

### 問題 1：Python 未安裝

**症狀：** `'python' is not recognized as an internal or external command`

**解決方案：**
1. 下載並安裝 Python 3.8+：https://www.python.org/downloads/
2. 安裝時勾選 "Add Python to PATH"
3. 重新開啟 PowerShell 並驗證：`python --version`

---

### 問題 2：網路連線失敗

**症狀：** `ConnectionError` 或 `Timeout` 錯誤

**解決方案：**

#### A. 設定代理（如需要）
```powershell
$env:HTTP_PROXY = "http://proxy.example.com:8080"
$env:HTTPS_PROXY = "http://proxy.example.com:8080"
```

#### B. 使用鏡像站點
```python
# 在 download_manual.py 中加入鏡像設定
import os
os.environ['HF_ENDPOINT'] = 'https://hf-mirror.com'
```

#### C. 分段下載
```powershell
# 使用 --resume-download 參數
huggingface-cli download openlm-research/open_llama_7b_v2_openvino_int4 --local-dir models/open_llama_7b_v2-int4-ov --resume-download
```

---

### 問題 3：磁碟空間不足

**症狀：** `No space left on device` 或下載中斷

**檢查空間：**
```powershell
# 檢查可用空間
Get-PSDrive C | Select-Object Used,Free

# 清理不必要的檔案
# 刪除臨時檔案、舊的下載等
```

**解決方案：**
- 確保至少有 10 GB 可用空間
- 考慮使用其他磁碟機：`.\scripts\download_model.ps1 -TargetDir "D:\models"`

---

### 問題 4：下載速度過慢

**症狀：** 下載速度 < 1 MB/s，預計需要數小時

**優化方案：**

#### A. 使用多線程下載
```powershell
# 安裝 aria2
choco install aria2

# 使用 aria2 下載（需手動構建 URL）
aria2c -x 16 -s 16 <model_file_url>
```

#### B. 選擇其他時段
- 避開網路高峰時段
- 建議在深夜或清晨下載

#### C. 使用學術網路
- 部分機構提供 Hugging Face 鏡像加速

---

### 問題 5：模型文件損壞

**症狀：** 驗證時發現檔案大小異常或 MD5 不符

**解決方案：**
```powershell
# 刪除損壞的模型
Remove-Item -Recurse -Force models\open_llama_7b_v2-int4-ov

# 重新下載
.\scripts\download_model.ps1 -Force
```

---

### 問題 6：權限錯誤

**症狀：** `Permission denied` 或 `Access is denied`

**解決方案：**
```powershell
# 以管理員身份執行 PowerShell
# 或檢查目錄權限
icacls models
```

---

## 📚 參考資源

### Hugging Face 文檔

- [Hugging Face Hub 文檔](https://huggingface.co/docs/huggingface_hub)
- [OpenVINO 模型庫](https://huggingface.co/models?library=openvino)

### 模型資訊

- [OpenLLaMA 7B v2 模型頁面](https://huggingface.co/openlm-research/open_llama_7b_v2)
- [OpenVINO INT4 量化說明](https://docs.openvino.ai/latest/openvino_docs_model_optimization_guide.html)

### 替代模型

如果下載 OpenLLaMA 7B 遇到困難，可以考慮以下替代模型：

| 模型名稱 | 大小 | Repository |
|----------|------|------------|
| TinyLlama-1.1B-int4 | ~600 MB | openvino-community/TinyLlama-1.1B-int4 |
| Phi-2-int4 | ~1.5 GB | openvino-community/phi-2-int4 |
| LLaMA-2-7B-int4 | ~4 GB | openvino-community/llama-2-7b-int4 |

修改下載命令：
```powershell
# 下載 TinyLlama（較小，適合測試）
.\scripts\download_model.ps1 -ModelName "TinyLlama-1.1B-int4"
```

---

## 💡 提示與技巧

### 提示 1：離線下載

如果需要在離線環境使用模型：

1. **在有網路的機器上下載**
```powershell
.\scripts\download_model.ps1
```

2. **打包模型目錄**
```powershell
Compress-Archive -Path "models\open_llama_7b_v2-int4-ov" -DestinationPath "open_llama_model.zip"
```

3. **轉移到目標機器並解壓**
```powershell
Expand-Archive -Path "open_llama_model.zip" -DestinationPath "models\"
```

---

### 提示 2：驗證模型可用性

在下載完成後，可以快速測試模型是否可用：

```python
# test_model.py
from optimum.intel.openvino import OVModelForCausalLM
from transformers import AutoTokenizer

model_path = "models/open_llama_7b_v2-int4-ov"

print("Loading model...")
tokenizer = AutoTokenizer.from_pretrained(model_path)
model = OVModelForCausalLM.from_pretrained(model_path)

print("✅ Model loaded successfully!")
print(f"Model type: {type(model)}")
print(f"Tokenizer vocab size: {len(tokenizer)}")
```

執行：
```powershell
python test_model.py
```

---

### 提示 3：監控下載進度

在手動下載時，可以使用進度監控：

```python
from huggingface_hub import snapshot_download
from tqdm import tqdm

def download_with_progress():
    snapshot_download(
        repo_id="openlm-research/open_llama_7b_v2_openvino_int4",
        local_dir="models/open_llama_7b_v2-int4-ov",
        local_dir_use_symlinks=False,
        resume_download=True,
        # tqdm 自動顯示進度條
    )

download_with_progress()
```

---

## 🎯 關鍵要點

1. **模型大小約 4 GB** - 確保足夠的磁碟空間和網路頻寬
2. **使用自動腳本** - 一鍵下載避免手動錯誤
3. **驗證文件完整性** - 下載後務必驗證所有必要文件
4. **支援斷點續傳** - 下載中斷可以繼續，不需重新開始
5. **可離線部署** - 下載後可打包轉移到其他機器

---

**準備好了嗎？讓我們進入 [階段 4：配置執行腳本](STAGE_4_CREATE_SCRIPT.md)！**

---

**創建日期：** 2026-01-05  
**最後更新：** 2026-01-05  
**維護者：** OpenVINO Lab 項目  
**狀態：** ✅ 已驗證可用
