# prepare_models.ps1 使用說明

## 📋 概覽

**用途**：下載 OpenVINO 優化版本的 TinyLlama 模型（可選）

**狀態**：✅ 已更新，現已標記為可選

---

## 🎯 何時使用此腳本？

### ✅ 應該使用（推薦）

```powershell
# 對於推理，使用此腳本無需運行
python scripts/run_inference_simple.py --prompt "Your question"
```

### ❓ 何時運行 prepare_models.ps1？

**場景 1：實驗 OpenVINO 優化效果**
```powershell
.\scripts\prepare_models.ps1
# 選擇選項 1-3 下載 OpenVINO 版本
# 大小只有 600MB-1.2GB（比 PyTorch 版本小）
```

**場景 2：為未來 OpenVINO GenAI 兼容性做準備**
- OpenVINO GenAI 的兼容性問題待修復
- 提前下載優化版本，未來修復後可直接使用

**場景 3：對比推理性能**
- 使用不同量化版本測試
- int4：最小（600MB），速度快
- int8：平衡（800MB）
- fp16：最佳質量（1.2GB），但略慢

---

## 🚀 如何使用

### 基本命令

```powershell
# 激活虛擬環境
.\venv\Scripts\Activate.ps1

# 運行腳本
.\scripts\prepare_models.ps1
```

### 選擇菜單

```
可用的預轉換模型：

  1) TinyLlama-1.1B-Chat-int4 - 600MB (Quantization: int4)
  2) TinyLlama-1.1B-Chat-int8 - 800MB (Quantization: int8)
  3) TinyLlama-1.1B-Chat-fp16 - 1.2GB (Quantization: fp16)

請選擇要下載的模型 (1-3，或輸入 'skip' 跳過):
```

### 下載完成後

```
╔════════════════════════════════════╗
║ OpenVINO 優化模型下載完成！        ║
╚════════════════════════════════════╝

推薦命令（推薦使用）：
  python scripts/run_inference_simple.py --prompt 'Your question'

或交互式模式：
  python scripts/run_inference_simple.py

說明：
  • run_inference_simple.py 使用標準 PyTorch 模型（開箱即用）
  • 上述 OpenVINO 優化模型可選（用於未來兼容性）
```

---

## 📊 模型比較

| 項目 | PyTorch 版本 | OpenVINO int4 | OpenVINO int8 | OpenVINO fp16 |
|------|-------------|--------------|--------------|---------------|
| **大小** | 2.2GB | 600MB | 800MB | 1.2GB |
| **推理速度** | 中 | 快 | 中 | 中-慢 |
| **質量** | 好 | 一般 | 好 | 最好 |
| **用途** | ✅ 推薦 | 快速測試 | 平衡 | 最佳質量 |
| **推理工具** | Transformers | OpenVINO | OpenVINO | OpenVINO |

---

## 📁 下載位置

下載完成後，模型保存在：

```
./models/TinyLlama-1.1B-Chat-int4/
./models/TinyLlama-1.1B-Chat-int8/
./models/TinyLlama-1.1B-Chat-fp16/
```

**檔案結構示例**：
```
models/TinyLlama-1.1B-Chat-int4/
├── openvino_model.xml       ← 模型結構
├── openvino_model.bin       ← 模型權重 (596MB)
├── config.json
├── tokenizer.json
├── tokenizer.model
├── tokenizer_config.json
├── generation_config.json
├── special_tokens_map.json
└── .gitattributes
```

---

## 🔄 工作流程對比

### 推薦工作流（當前）

```
✅ 簡單且開箱即用
python scripts/run_inference_simple.py
↓
自動下載 PyTorch 模型 (2.2GB) → ~/. cache/huggingface/
↓
立即開始推理 ✅
```

### 可選工作流（未來）

```
（可選）下載 OpenVINO 優化模型
.\scripts\prepare_models.ps1
↓
選擇量化版本 (int4/int8/fp16)
↓
保存到 ./models/ 目錄
↓
（未來修復後）使用 OpenVINO GenAI 推理
```

---

## ⚠️ 重要說明

### 為什麼不直接用 OpenVINO 模型？

❌ **當前狀態**：
```
OpenVINO GenAI 無法加載 OpenVINO IR 格式模型
錯誤：Value for partial shape evaluation can't be lower than zero
```

✅ **解決方案**：
```
使用標準 Transformers 庫 + PyTorch 模型
run_inference_simple.py 完全正常運行
```

### 何時會改變？

- 等待 OpenVINO GenAI 修復兼容性問題
- 預計在 OpenVINO 的後續版本修復
- 屆時可直接使用 ./models/ 目錄中的模型

---

## 📌 總結

| 操作 | 說明 |
|------|------|
| **推理** | `python scripts/run_inference_simple.py` ✅ 推薦 |
| **下載 OpenVINO** | `.\scripts\prepare_models.ps1` ⚠️ 可選 |
| **模型位置** | `~/.cache/huggingface/` (推薦) 或 `./models/` (可選) |
| **推薦量化** | int4 (最小) 或 int8 (平衡) |

---

**快速開始命令**：
```powershell
python scripts/run_inference_simple.py --prompt "What is Python?"
```

**就這樣！** 無需運行 prepare_models.ps1 即可開始使用。
