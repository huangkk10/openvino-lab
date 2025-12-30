# 模型下載錯誤修復報告

## ❌ 遇到的問題

```
401 Client Error: Unauthorized
Repository Not Found for url: https://huggingface.co/api/models/openvino-community/TinyLlama-1.1B-int4
```

## 🔍 根本原因

1. **模型倉庫不存在** - `openvino-community/TinyLlama-1.1B-int4` 倉庫不可用
2. **可能的原因**：
   - 模型已被移除
   - 模型已更名
   - 倉庫設為私有
   - 組織名稱變更

## ✅ 解決方案

### 更新為可用的模型

腳本已更新為使用以下 **驗證可用** 的模型：

| 模型 | HuggingFace ID | 大小 | 量化 |
|------|---------------|------|------|
| **TinyLlama-1.1B-Chat-int4** | `ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-asym-int4` | 600MB | int4 |
| **TinyLlama-1.1B-Chat-int8** | `ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-asym-int8` | 800MB | int8 |
| **TinyLlama-1.1B-Chat-fp16** | `ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-fp16` | 1.2GB | fp16 |

### 已更新的文件

1. ✅ `scripts/prepare_models.ps1` - 更新模型列表
2. ✅ `config/.env` - 更新默認模型路徑

---

## 🚀 現在使用修復後的腳本

### 重新運行下載腳本

```powershell
# 確保在虛擬環境中
.\venv\Scripts\Activate.ps1

# 運行更新後的腳本
.\scripts\prepare_models.ps1
```

### 新的菜單選項

```
Available pre-converted models:

  1) TinyLlama-1.1B-Chat-int4 - 600MB (Quantization: int4)
  2) TinyLlama-1.1B-Chat-int8 - 800MB (Quantization: int8)
  3) TinyLlama-1.1B-Chat-fp16 - 1.2GB (Quantization: fp16)

Please select a model to download (1-3, or type 'skip' to skip):
```

### 推薦選擇

- **選項 1 (int4)** - 最小大小，快速下載，適合測試
- **選項 2 (int8)** - 平衡大小和質量
- **選項 3 (fp16)** - 最佳質量，較大文件

---

## 📋 模型詳情

### TinyLlama-1.1B-Chat 系列

這些模型都是 **TinyLlama-1.1B-Chat-v1.0** 的 OpenVINO 優化版本：

| 量化類型 | 精度 | 大小 | 推理速度 | 質量 |
|---------|------|------|---------|------|
| **int4** | 4-bit | ~600MB | 最快 | 良好 |
| **int8** | 8-bit | ~800MB | 快 | 更好 |
| **fp16** | 16-bit | ~1.2GB | 中等 | 最佳 |

### 模型來源

- **作者**: ulkaa
- **基礎模型**: TinyLlama-1.1B-Chat-v1.0
- **優化**: OpenVINO 格式
- **授權**: Apache 2.0
- **HuggingFace**: https://huggingface.co/ulkaa

---

## 🔍 驗證模型可用性

### 方法 1：搜索可用模型

```powershell
python -c "from huggingface_hub import list_models; models = list(list_models(search='tinyllama openvino', limit=5)); [print(m.modelId) for m in models]"
```

### 方法 2：檢查特定模型

```powershell
python -c "from huggingface_hub import model_info; info = model_info('ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-asym-int4'); print(f'Model: {info.modelId}'); print(f'Downloads: {info.downloads}'); print(f'Likes: {info.likes}')"
```

---

## 🐛 其他可能的錯誤

### 如果仍然遇到 401 錯誤

**可能需要 HuggingFace Token：**

1. **註冊 HuggingFace 賬號**
   - 訪問：https://huggingface.co/join

2. **生成訪問 Token**
   - 訪問：https://huggingface.co/settings/tokens
   - 點擊 "New token"
   - 選擇 "Read" 權限

3. **設置 Token**
   ```powershell
   # 方法 1：設置環境變數
   $env:HF_TOKEN="hf_your_token_here"
   
   # 方法 2：登錄 CLI
   huggingface-cli login
   ```

4. **在 .env 文件中設置**
   ```bash
   # 編輯 config/.env
   HF_TOKEN=hf_your_token_here
   ```

### 網絡連接問題

```powershell
# 測試連接
Test-Connection huggingface.co

# 使用代理（如果需要）
$env:HTTP_PROXY="http://proxy.example.com:8080"
$env:HTTPS_PROXY="http://proxy.example.com:8080"
```

### 下載速度慢

```powershell
# 使用 HuggingFace 鏡像（中國用戶）
$env:HF_ENDPOINT="https://hf-mirror.com"

# 或編輯 config/.env
HF_ENDPOINT=https://hf-mirror.com
```

---

## 📊 測試結果

### 驗證可用模型

```bash
✅ ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-asym-int4
✅ ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-asym-int8
✅ ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-sym-int4
✅ ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-sym-int8
✅ ulkaa/TinyLlama-1.1B-Chat-v1.0-OpenVINO-fp16
```

### 不可用模型（已移除）

```bash
❌ openvino-community/TinyLlama-1.1B-int4 (不存在)
❌ openvino-community/Qwen2-1.5B-int4 (不存在)
❌ openvino-community/phi-2-int4 (不存在)
```

---

## 🎯 下一步

### 1. 運行更新後的腳本

```powershell
.\venv\Scripts\Activate.ps1
.\scripts\prepare_models.ps1
```

### 2. 選擇模型下載

```
Please select a model to download (1-3): 1
```

### 3. 開始推理

```powershell
python scripts/run_inference.py
```

---

## 📚 參考資源

- [HuggingFace TinyLlama Models](https://huggingface.co/models?search=tinyllama%20openvino)
- [OpenVINO Model Zoo](https://github.com/openvinotoolkit/open_model_zoo)
- [HuggingFace Authentication](https://huggingface.co/docs/huggingface_hub/authentication)

---

**修復完成日期：** 2025年12月30日  
**狀態：** ✅ 已驗證並更新

