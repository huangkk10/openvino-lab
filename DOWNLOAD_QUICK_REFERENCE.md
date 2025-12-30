# 🚀 快速下載參考卡

## 最常見的 3 種用法

### 1️⃣ 最簡單 - 直接下載 open_llama_7b_v2-int4

```powershell
# 激活環境
.\venv\Scripts\Activate.ps1

# 一行命令下載（推薦）
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"
```

**結果：** 模型自動保存到 `./models/open_llama_7b_v2-int4-ov/`

---

### 2️⃣ 菜單選擇 - 從預設列表選擇

```powershell
# 激活環境
.\venv\Scripts\Activate.ps1

# 執行互動式菜單
.\scripts\download_model_interactive.ps1
```

**菜單選項：**
```
1) OpenLLaMA 7B (OpenVINO int4)       ← 選擇這個
2) TinyLlama 1.1B (OpenVINO int4)
3) TinyLlama 1.1B (PyTorch)
4) Qwen 7B (OpenVINO)
5) 自訂模型（手動輸入）
```

---

### 3️⃣ 完整用法 - 指定全部參數

```powershell
python scripts/download_hf_model.py \
    --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \
    --model-name "open_llama_7b_v2-int4" \
    --output-dir "./models"
```

---

## 📋 所有可用命令

| 需求 | 命令 |
|------|------|
| **下載 OpenLLaMA 7B** | `python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"` |
| **下載 TinyLlama PyTorch** | `python scripts/download_hf_model.py --repo-id "TinyLlama/TinyLlama-1.1B-Chat-v1.0"` |
| **下載任意模型** | `python scripts/download_hf_model.py --repo-id "{YOUR_REPO_ID}"` |
| **指定保存位置** | `python scripts/download_hf_model.py --repo-id "..." --output-path "D:/Models"` |
| **跳過驗證** | `python scripts/download_hf_model.py --repo-id "..." --no-verify` |
| **使用菜單** | `.\scripts\download_model_interactive.ps1` |

---

## ⏱️ 預期下載時間

| 模型 | 大小 | 時間（10Mbps） |
|------|------|-----------------|
| TinyLlama PyTorch | 2.2GB | ~30 分鐘 |
| OpenLLaMA 7B | 3.5GB | ~50 分鐘 |
| Qwen 7B | 3.8GB | ~55 分鐘 |

---

## 📂 下載完成後

```powershell
# 查看已下載的模型
ls ./models

# 列出模型文件
ls ./models/open_llama_7b_v2-int4-ov
```

---

## ❌ 出問題時

```powershell
# 檢查網絡
Test-NetConnection huggingface.co -Port 443

# 檢查磁盤空間
Get-Volume

# 檢查虛擬環境
$env:VIRTUAL_ENV

# 升級工具
pip install --upgrade huggingface_hub
```

---

## 📖 詳細文檔

- [`docs/DOWNLOAD_HF_MODEL_GUIDE.md`](docs/DOWNLOAD_HF_MODEL_GUIDE.md) - 完整使用指南
- [`docs/setup/STAGE_7_GUIDE_NEW.md`](docs/setup/STAGE_7_GUIDE_NEW.md) - 推理設置
- [`QUICKSTART.md`](QUICKSTART.md) - 快速開始

---

## 🎯 下一步

下載完成後，使用推理腳本：

```powershell
python scripts/run_inference_simple.py --prompt "Your question"
```

**注意：** 下載的 OpenVINO 模型可與 PyTorch 推理腳本並用，待官方修復後可使用 OpenVINO 推理。

---

**版本：** 1.0 | **日期：** 2025-12-30
