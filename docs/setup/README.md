# Windows 環境設置指南

這個資料夾包含 Windows 平台的完整設置說明。

## 📋 核心檔案

| 檔案 | 用途 | 描述 |
|------|------|------|
| **[SETUP_PROGRESS.md](SETUP_PROGRESS.md)** | 📊 全流程追蹤 | 9 個階段的完整規劃、詳細步驟、驗證方法 |
| **[SETUP_WINDOWS.md](SETUP_WINDOWS.md)** | ⚙️ 詳細說明 | Windows 設置的具體操作步驟 |
| **[STAGE_7_GUIDE_NEW.md](STAGE_7_GUIDE_NEW.md)** | 🎯 推理設置 | 推理環境設置和使用指南（**推薦**） |
| **[STAGE_8_GUIDE.md](STAGE_8_GUIDE.md)** | ⬇️ 模型下載 | 大型模型下載指南（**可選進階**） |
| **[STAGE_9_GUIDE.md](STAGE_9_GUIDE.md)** | 🔬 性能測試 | Benchmark 基準測試指南（**進階**） |
| **[GITIGNORE_GUIDE.md](GITIGNORE_GUIDE.md)** | 🔐 Git 配置 | .gitignore 說明和版本控制最佳實踐 |

## 📊 當前進度

```
[x] 第 1️⃣ 階段：前置準備              ✅ 完成
[x] 第 2️⃣ 階段：系統依賴              ✅ 完成
[x] 第 3️⃣ 階段：虛擬環境              ✅ 完成
[x] 第 4️⃣ 階段：套件安裝              ✅ 完成
[x] 第 5️⃣ 階段：環境驗證              ✅ 完成
[x] 第 6️⃣ 階段：配置設置              ✅ 完成
[x] 第 7️⃣ 階段：推理設置              ✅ 完成 🎉
[ ] 第 8️⃣ 階段：大型模型下載          ⏳ 可選進階
[ ] 第 9️⃣ 階段：性能基準測試          🔬 進階性能
```

**基礎設置已完成！** 第 7 階段推理環境已就緒。  
**第 8 階段**：可選的大型模型下載（如 OpenLLaMA 7B）  
**第 9 階段**：進階性能測試（需要 C++ 編譯環境）

詳細進度與完整指南：📖 [STAGE_7_GUIDE_NEW.md](STAGE_7_GUIDE_NEW.md)  
大型模型下載指南：📖 [STAGE_8_GUIDE.md](STAGE_8_GUIDE.md)  
性能基準測試指南：📖 [STAGE_9_GUIDE.md](STAGE_9_GUIDE.md)

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

## 第 7️⃣ 階段：推理設置

**目標：** 設置並運行 AI 模型推理

**快速開始：**
```powershell
# 激活虛擬環境
.\venv\Scripts\Activate.ps1

# 單次推理
python scripts/run_inference_simple.py --prompt "What is Python?"

# 交互式模式
python scripts/run_inference_simple.py

# 演示模式
python scripts/run_inference_simple.py demo
```

**使用的模型：**
- **推薦**（開箱即用）：TinyLlama-1.1B-Chat-v1.0 (PyTorch)
- **可選**（未來支持）：TinyLlama-1.1B-Chat-intX (OpenVINO 優化)

**特點：**
- ✅ 首次自動下載模型（~2.2GB）
- ✅ 後續使用快取（無需重新下載）
- ✅ 支持 CPU/GPU 推理
- ✅ 交互式或單次推理模式

**更多詳情：** 📖 [STAGE_7_GUIDE_NEW.md](STAGE_7_GUIDE_NEW.md)

---

## 第 8️⃣ 階段：大型模型下載（可選進階）

**目標：** 下載大型模型（如 OpenLLaMA 7B）用於進階實驗

**適用情況：**
- ✅ 想要實驗更大、更強的模型
- ✅ 有足夠的磁盤空間（3.5GB+）
- ✅ 網絡速度較快或有耐心等待

**快速執行（推薦）：**
```powershell
# 激活虛擬環境
.\venv\Scripts\Activate.ps1

# 方法 1：命令行直接下載 OpenLLaMA 7B
python scripts/download_hf_model.py --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"

# 方法 2：使用互動式菜單
.\scripts\download_model_interactive.ps1
```

**模型信息：**
- **名稱**：OpenLLaMA 7B (int4 量化)
- **大小**：約 3.5GB
- **Repository**：OpenVINO/open_llama_7b_v2-int4-ov
- **保存位置**：`./models/open_llama_7b_v2-int4-ov/`
- **預期下載時間**：10Mbps 網速約 50 分鐘

**其他可選模型：**
```powershell
# TinyLlama PyTorch 版本（2.2GB）
python scripts/download_hf_model.py --repo-id "TinyLlama/TinyLlama-1.1B-Chat-v1.0"

# Qwen 7B (3.8GB)
python scripts/download_hf_model.py --repo-id "OpenVINO/Qwen1.5-7B-Chat-int4-ov"
```

**驗證下載：**
```powershell
# 查看已下載的模型
ls ./models

# 檢查模型文件
ls ./models/open_llama_7b_v2-int4-ov
```

**注意事項：**
- ⚠️ 下載的 OpenVINO 模型目前需要等待官方庫修復才能使用
- ✅ 可以繼續使用 `run_inference_simple.py`（基於 PyTorch）
- 💡 下載是為未來兼容性做準備，非必要步驟

**更多詳情：** 📖 [STAGE_8_GUIDE.md](STAGE_8_GUIDE.md) | [完整下載指南](../DOWNLOAD_HF_MODEL_GUIDE.md)

---

## 第 9️⃣ 階段：性能基準測試（進階）

**目標：** 使用官方 C++ benchmark 工具測試模型推理性能

**適用情況：**
- ✅ 想了解模型推理性能指標（吞吐量、延遲）
- ✅ 需要比較不同配置的性能差異
- ✅ 有 C++ 編譯環境（CMake + Visual Studio）
- ✅ 已完成 Stage 8（下載大型模型）

**快速執行：**
```powershell
# 方法 1：使用 Python 包裝腳本（推薦）
python scripts/run_benchmark.py `
    --model "./models/open_llama_7b_v2-int4-ov" `
    --device GPU `
    --auto-setup

# 方法 2：使用 PowerShell 互動式腳本
.\scripts\run_benchmark.ps1
```

**手動執行（進階用戶）：**
```powershell
# 1. 克隆 OpenVINO GenAI 倉庫
git clone https://github.com/openvinotoolkit/openvino.genai.git ./src/openvino.genai

# 2. 編譯 benchmark
cd ./src/openvino.genai/samples/cpp/text_generation
mkdir build; cd build
cmake .. -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release

# 3. 執行 benchmark
.\Release\benchmark_genai.exe `
    -m "..\..\..\..\..\..\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    -nw 0 `
    -mt 20 `
    -n 1
```

**性能指標：**
- **吞吐量（Throughput）**：每秒生成令牌數（越高越好）
- **首字延遲（TTFT）**：第一個字出現時間（越低越好）
- **平均延遲**：每個令牌平均生成時間（越低越好）

**預期結果範例：**
```
=== Benchmark Results ===
Generation time: 2.456 seconds
Total tokens generated: 20
Throughput: 8.14 tokens/second
Time to first token (TTFT): 245 ms
Average token latency: 123 ms
```

**性能參考：**

| 設備 | 吞吐量 | 首字延遲 | 評價 |
|------|--------|---------|------|
| CPU | 10-30 tok/s | 400-800ms | ⭐⭐⭐ |
| GPU | 50-100 tok/s | 100-200ms | ⭐⭐⭐⭐⭐ |

**注意事項：**
- ⚠️ 需要 CMake 和 Visual Studio（含 C++ 工具）
- ⚠️ 首次編譯需要 5-10 分鐘
- ✅ Python 包裝腳本可自動處理編譯流程

**更多詳情：** 📖 [STAGE_9_GUIDE.md](STAGE_9_GUIDE.md) | [OpenVINO GenAI Benchmark 源碼](https://github.com/openvinotoolkit/openvino.genai/blob/master/samples/cpp/text_generation/benchmark_genai.cpp)

---

## 🔗 相關資源

- 📖 [完整設置流程](SETUP_PROGRESS.md) - 所有 9 個階段的詳細說明
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
