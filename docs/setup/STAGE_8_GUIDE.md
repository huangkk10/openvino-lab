# Stage 8：大型模型下載指南（可選進階）

> **狀態：** ⏳ 可選進階功能  
> **前置要求：** 已完成 Stage 1-7  
> **預計時間：** 30-60 分鐘（取決於網絡速度）  
> **磁盤需求：** 3.5GB - 10GB（視模型而定）

---

## 📋 概述

Stage 8 是**可選的進階功能**，用於下載大型語言模型（如 OpenLLaMA 7B）。

### 💡 為什麼是可選的？

- ✅ **Stage 7 已完成基礎推理**：使用 TinyLlama 1.1B 模型已能進行推理
- ✅ **大型模型需要更多資源**：磁盤空間、下載時間、運行記憶體
- ✅ **OpenVINO 模型暫不可用**：需等待官方庫修復

### 🎯 何時需要 Stage 8？

| 情況 | 是否需要 Stage 8 |
|------|-----------------|
| 只想快速體驗推理 | ❌ 不需要（已在 Stage 7 完成） |
| 想測試更大、更強的模型 | ✅ 需要 |
| 磁盤空間有限（< 5GB） | ❌ 不建議 |
| 網絡速度慢或流量限制 | ❌ 不建議 |
| 想為未來 OpenVINO 優化做準備 | ✅ 可以提前下載 |
| 需要更好的對話質量 | ✅ 大型模型效果更好 |

---

## 🚀 快速開始

### 方法 1：命令行下載（推薦 - 最快）

```powershell
# 1. 確保虛擬環境已激活
.\venv\Scripts\Activate.ps1

# 2. 下載 OpenLLaMA 7B（推薦）
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"
```

### 方法 2：互動式菜單（推薦 - 最簡單）

```powershell
# 1. 確保虛擬環境已激活
.\venv\Scripts\Activate.ps1

# 2. 運行互動式菜單
.\scripts\download_model_interactive.ps1

# 3. 選擇 "1" - OpenLLaMA 7B (OpenVINO int4)
```

### 方法 3：完整參數（進階用戶）

```powershell
python scripts/download_hf_model.py \
    --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \
    --model-name "open_llama_7b_v2-int4" \
    --output-dir "./models"
```

---

## 📊 可用模型列表

### 大型模型（7B 參數）

| 模型 | Repository ID | 大小 | 量化 | 推薦度 |
|------|---------------|------|------|--------|
| **OpenLLaMA 7B** ⭐ | `OpenVINO/open_llama_7b_v2-int4-ov` | 3.5GB | int4 | ⭐⭐⭐⭐⭐ |
| Qwen 7B | `OpenVINO/Qwen1.5-7B-Chat-int4-ov` | 3.8GB | int4 | ⭐⭐⭐⭐ |

### 中型模型（1-3B 參數）

| 模型 | Repository ID | 大小 | 格式 | 推薦度 |
|------|---------------|------|------|--------|
| TinyLlama 1.1B (OV) | `ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-asym-int4` | 600MB | OpenVINO int4 | ⭐⭐⭐ |
| TinyLlama 1.1B (PyTorch) | `TinyLlama/TinyLlama-1.1B-Chat-v1.0` | 2.2GB | PyTorch | ⭐⭐⭐⭐ |

---

## 📝 詳細步驟：下載 OpenLLaMA 7B

### Step 1：環境準備

```powershell
# 檢查虛擬環境
$env:VIRTUAL_ENV
# 應該輸出：C:\Users\svd\codes\openvino-lab\venv

# 如果未激活，執行：
.\venv\Scripts\Activate.ps1
```

### Step 2：檢查磁盤空間

```powershell
# 檢查可用空間（至少需要 5GB）
Get-Volume | Select-Object DriveLetter, @{Name="FreeSpaceGB";Expression={[math]::Round($_.SizeRemaining/1GB, 2)}}
```

**預期輸出：**
```
DriveLetter FreeSpaceGB
----------- -----------
C                  50.25
```

### Step 3：執行下載

```powershell
# 下載 OpenLLaMA 7B
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"
```

**下載過程：**
```
╔══════════════════════════════════════════════════════════════════╗
║                    下載模型：open_llama_7b_v2-int4-ov            ║
╚══════════════════════════════════════════════════════════════════╝

==================================================
  模型信息
==================================================
ℹ️   Repository ID: OpenVINO/open_llama_7b_v2-int4-ov
ℹ️   保存位置: ./models/open_llama_7b_v2-int4-ov
📦  正在取得模型信息...
ℹ️   估計大小: 3.52 GB

==================================================
  開始下載
==================================================
ℹ️   下載可能需要數分鐘，取決於網絡速度和模型大小

Fetching 15 files: 100%|████████████████████| 15/15 [05:32<00:00, 22.17s/it]

==================================================
  下載完成
==================================================
✅  模型已保存到：./models/open_llama_7b_v2-int4-ov

ℹ️   文件數: 15
ℹ️   總大小: 3.52 GB

ℹ️   主要文件：
  ✓ openvino_model.xml (234.56 KB)
  ✓ openvino_model.bin (3.45 GB)
  ✓ config.json (1.23 KB)
  ✓ tokenizer.json (456.78 KB)
  ✓ tokenizer_config.json (0.89 KB)
  ✓ generation_config.json (0.12 KB)

==================================================
  驗證模型
==================================================
✅  ✓ openvino_model.xml 存在
✅  ✓ openvino_model.bin 存在
✅  ✓ config.json 存在

✅  ✓ tokenizer.json 存在
✅  ✓ tokenizer_config.json 存在
✅  ✓ generation_config.json 存在

✅  模型驗證成功！

ℹ️   已建立模型清單：.manifest.json
```

### Step 4：驗證下載結果

```powershell
# 查看模型目錄
ls ./models/open_llama_7b_v2-int4-ov

# 檢查主要文件
ls ./models/open_llama_7b_v2-int4-ov | Where-Object { $_.Name -match "(xml|bin|json)" }
```

**預期輸出：**
```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        12/30/2025  10:30 AM     3456789012 openvino_model.bin
-a----        12/30/2025  10:30 AM         234567 openvino_model.xml
-a----        12/30/2025  10:30 AM           1234 config.json
-a----        12/30/2025  10:30 AM         456789 tokenizer.json
...
```

---

## 📂 下載後的文件結構

```
models/
└── open_llama_7b_v2-int4-ov/
    ├── openvino_model.xml        # 模型圖定義（234 KB）
    ├── openvino_model.bin        # 模型權重（3.45 GB）⭐ 主要文件
    ├── config.json               # 模型配置
    ├── tokenizer.json            # 分詞器（456 KB）
    ├── tokenizer_config.json     # 分詞器配置
    ├── generation_config.json    # 生成參數配置
    ├── merges.txt                # 分詞器合併規則
    ├── special_tokens_map.json   # 特殊標記
    ├── vocab.json                # 詞彙表
    ├── added_tokens.json         # 添加的標記
    ├── .manifest.json            # 下載記錄（自動生成）
    └── README.md                 # 模型說明（來自 HuggingFace）
```

### 模型清單文件 (`.manifest.json`)

```json
{
  "model_name": "open_llama_7b_v2-int4-ov",
  "repo_id": "OpenVINO/open_llama_7b_v2-int4-ov",
  "downloaded_at": "2025-12-30T10:30:45.123456",
  "downloaded_from": "HuggingFace Hub",
  "local_path": "C:\\Users\\svd\\codes\\openvino-lab\\models\\open_llama_7b_v2-int4-ov"
}
```

---

## ⏱️ 下載時間預估

| 網絡速度 | OpenLLaMA 7B (3.5GB) | Qwen 7B (3.8GB) | TinyLlama PyTorch (2.2GB) |
|---------|---------------------|-----------------|---------------------------|
| 5 Mbps  | ~90 分鐘            | ~100 分鐘        | ~60 分鐘                   |
| 10 Mbps | ~50 分鐘            | ~55 分鐘         | ~30 分鐘                   |
| 20 Mbps | ~25 分鐘            | ~27 分鐘         | ~15 分鐘                   |
| 50 Mbps | ~10 分鐘            | ~11 分鐘         | ~6 分鐘                    |
| 100 Mbps| ~5 分鐘             | ~5.5 分鐘        | ~3 分鐘                    |

---

## 🎯 下載後如何使用？

### 目前狀態

- ❌ **OpenVINO GenAI 推理**：暫不可用（等待官方庫修復）
- ✅ **PyTorch 推理**：可用（使用 `run_inference_simple.py`）
- ⏳ **未來支持**：OpenVINO 優化推理（修復後）

### 現階段推薦方式

```powershell
# 繼續使用 PyTorch 推理（已驗證可用）
python scripts/run_inference_simple.py --prompt "What is AI?"
```

### 未來可用方式（待官方修復）

```powershell
# 使用 OpenVINO 優化模型進行推理（未來）
python scripts/run_inference_openvino.py \
    --model-path "./models/open_llama_7b_v2-int4-ov" \
    --prompt "What is AI?"
```

---

## 🔧 故障排除

### ❌ 問題：下載速度太慢

**解決方案 1：使用 HuggingFace 鏡像**
```powershell
$env:HF_ENDPOINT="https://hf-mirror.com"
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"
```

**解決方案 2：使用代理（如果有）**
```powershell
$env:HTTP_PROXY="http://your-proxy:port"
$env:HTTPS_PROXY="http://your-proxy:port"
```

### ❌ 問題：下載中途中斷

**解決方案：再次執行相同命令（自動續傳）**
```powershell
# 會從中斷點繼續，不會重新開始
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"
```

### ❌ 問題：磁盤空間不足

```
OSError: [Errno 28] No space left on device
```

**解決方案 1：清理磁盤空間**
```powershell
# 檢查哪個驅動器有空間
Get-Volume

# 清理不需要的文件
```

**解決方案 2：下載到其他驅動器**
```powershell
python scripts/download_hf_model.py \
    --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \
    --output-path "E:/Models/open_llama"
```

### ❌ 問題：驗證失敗

```
❌ 缺少必要文件：openvino_model.bin
```

**解決方案：重新下載**
```powershell
# 刪除不完整的目錄
Remove-Item "./models/open_llama_7b_v2-int4-ov" -Recurse -Force

# 重新下載
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"
```

### ❌ 問題：huggingface_hub 錯誤

```
ImportError: No module named 'huggingface_hub'
```

**解決方案：安裝依賴**
```powershell
pip install huggingface_hub
```

---

## 📊 模型比較

### OpenLLaMA 7B vs TinyLlama 1.1B

| 特性 | OpenLLaMA 7B | TinyLlama 1.1B |
|------|-------------|----------------|
| **參數數量** | 7B (70 億) | 1.1B (11 億) |
| **模型大小** | 3.5GB (int4) | 2.2GB (fp16) / 600MB (int4) |
| **對話質量** | ⭐⭐⭐⭐⭐ 優秀 | ⭐⭐⭐ 良好 |
| **推理速度 (CPU)** | 慢（5-15 詞/秒） | 快（20-50 詞/秒） |
| **推理速度 (GPU)** | 中（30-80 詞/秒） | 快（100-300 詞/秒） |
| **記憶體需求** | 高（8GB+ RAM） | 低（4GB RAM） |
| **下載時間** | 長（50 分鐘 @10Mbps） | 短（30 分鐘 @10Mbps） |
| **適用場景** | 複雜對話、專業任務 | 快速測試、簡單對話 |

### 推薦選擇

```
如果您...                          推薦模型
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
需要最佳對話質量                    OpenLLaMA 7B ⭐
需要快速響應                       TinyLlama 1.1B
記憶體有限（< 8GB）                TinyLlama 1.1B
磁盤空間有限（< 5GB）              TinyLlama 1.1B (int4)
網絡速度慢                         TinyLlama 1.1B (int4)
只想快速測試                       TinyLlama 1.1B (PyTorch)
想體驗最新技術                     OpenLLaMA 7B ⭐
```

---

## 📖 相關文檔

- [`../../DOWNLOAD_QUICK_REFERENCE.md`](../../DOWNLOAD_QUICK_REFERENCE.md) - 快速參考卡
- [`../DOWNLOAD_HF_MODEL_GUIDE.md`](../DOWNLOAD_HF_MODEL_GUIDE.md) - 完整下載指南
- [`STAGE_7_GUIDE_NEW.md`](STAGE_7_GUIDE_NEW.md) - 推理設置指南
- [`README.md`](README.md) - 設置總覽

---

## 💡 最佳實踐

### 下載前

- ✅ 確保至少有 5GB 可用磁盤空間
- ✅ 確認網絡連接穩定
- ✅ 考慮使用 HuggingFace 鏡像加速
- ✅ 選擇網絡流量較空閒的時段

### 下載中

- ✅ 不要關閉終端窗口
- ✅ 如果中斷，直接重新執行（會續傳）
- ✅ 注意磁盤空間是否足夠

### 下載後

- ✅ 驗證文件完整性（自動進行）
- ✅ 檢查 `.manifest.json` 記錄
- ✅ 可以壓縮備份（可選）

---

## 🎓 進階功能

### 批量下載多個模型

```powershell
# 建立批量下載腳本
$models = @(
    "OpenVINO/open_llama_7b_v2-int4-ov",
    "OpenVINO/Qwen1.5-7B-Chat-int4-ov"
)

foreach ($repo in $models) {
    Write-Host "下載模型：$repo" -ForegroundColor Cyan
    python scripts/download_hf_model.py --repo-id $repo
    Write-Host ""
}
```

### 下載到外部硬盤

```powershell
# 下載到 D: 驅動器
python scripts/download_hf_model.py \
    --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \
    --output-path "D:/AI_Models/open_llama"

# 建立符號連結（Windows）
New-Item -ItemType SymbolicLink -Path "./models/open_llama" -Target "D:/AI_Models/open_llama"
```

### 使用私有模型（需要 Token）

```powershell
# 設定 HuggingFace Token
$env:HF_TOKEN="hf_your_token_here"

# 下載私有模型
python scripts/download_hf_model.py --repo-id "your-org/private-model"
```

---

## ✅ 檢查清單

完成 Stage 8 後，確認以下項目：

- [ ] 模型已下載到 `./models/open_llama_7b_v2-int4-ov/`
- [ ] 包含 `openvino_model.xml` 和 `openvino_model.bin`
- [ ] 包含 `config.json` 和 `tokenizer.json`
- [ ] `.manifest.json` 文件已建立
- [ ] 驗證通過（看到綠色 ✅ 標記）
- [ ] 磁盤空間足夠（還剩 2GB+）

---

## 📝 總結

**Stage 8 完成後：**

✅ 您已下載大型語言模型（OpenLLaMA 7B）  
✅ 模型文件已驗證完整  
✅ 已為未來的 OpenVINO 優化推理做好準備  

**下一步：**

- 🎯 繼續使用 `run_inference_simple.py` 進行推理
- ⏳ 等待 OpenVINO GenAI 官方修復後使用優化推理
- 🚀 嘗試其他大型模型（Qwen 7B 等）

---

**Stage 8 狀態：** ✅ 可選進階功能（已完成下載流程規劃）  
**最後更新：** 2025-12-30  
**版本：** 1.0
