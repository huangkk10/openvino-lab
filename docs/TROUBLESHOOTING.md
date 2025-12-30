# OpenVINO GenAI 故障排除指南

本文檔提供常見問題的解決方案。

## ❌ 常見錯誤和解決方案

### 1. DLL Load Failed

**錯誤信息：**
```
DLL load failed while importing _pyopenvino: The specified module could not be found.
Microsoft Visual C++ Redistributable is not installed...
```

**原因：** 缺少 Microsoft Visual C++ Redistributable

**解決方案：**
1. 下載並安裝 Visual C++ Redistributable：
   https://aka.ms/vs/17/release/vc_redist.x64.exe
2. 安裝完成後重新啟動 PowerShell
3. 重新啟動虛擬環境：
   ```powershell
   .\venv\Scripts\Activate.ps1
   ```

---

### 2. ModuleNotFoundError

**錯誤信息：**
```
ModuleNotFoundError: No module named 'openvino'
```

**原因：** 套件未安裝或虛擬環境未啟動

**解決方案：**
1. 確認虛擬環境已啟動（看到 `(venv)` 前綴）：
   ```powershell
   .\venv\Scripts\Activate.ps1
   ```
2. 重新安裝套件：
   ```powershell
   pip install openvino-genai optimum[openvino]
   ```
3. 驗證安裝：
   ```powershell
   python -c "import openvino_genai; print('Success!')"
   ```

---

### 3. PowerShell 執行策略錯誤

**錯誤信息：**
```
.ps1 cannot be loaded because running scripts is disabled on this system
```

**原因：** PowerShell 執行策略限制

**解決方案：**
```powershell
# 以管理員身份運行 PowerShell，然後執行：
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 驗證
Get-ExecutionPolicy
# 應該輸出：RemoteSigned
```

---

### 4. 模型載入失敗

**錯誤信息：**
```
RuntimeError: Model not found at specified path
```

**原因：** 模型路徑不正確或模型未轉換

**解決方案：**
1. 驗證模型目錄存在：
   ```powershell
   Test-Path "./models/model_name"
   ```
2. 重新轉換模型：
   ```powershell
   optimum-cli export openvino --model "model-id" --output-dir ./models/model_name --trust-remote-code
   ```
3. 使用絕對路徑：
   ```python
   import os
   model_path = os.path.abspath("./models/model_name")
   pipe = ov_genai.LLMPipeline(model_path, "CPU")
   ```

---

### 5. 記憶體不足

**錯誤信息：**
```
RuntimeError: Cannot allocate memory
MemoryError: Unable to allocate ... bytes
```

**原因：** 模型太大或系統記憶體不足

**解決方案：**
1. 使用更小的模型：
   ```powershell
   # 使用 TinyLlama 而非大模型
   optimum-cli export openvino --model TinyLlama/TinyLlama-1.1B-Chat-v1.0 ...
   ```
2. 使用 INT4 量化（更激進的壓縮）：
   ```powershell
   optimum-cli export openvino --weight-format int4 ...
   ```
3. 減小批處理大小：
   ```python
   # 一次處理一個輸入而非批量
   for prompt in prompts:
       result = pipe.generate(prompt, max_new_tokens=50)
   ```
4. 關閉其他應用以釋放記憶體

---

### 6. GPU 未被識別

**錯誤信息：**
```
No GPU devices found
GPU device not available
```

**原因：** GPU 驅動未安裝或 OpenVINO 未配置

**解決方案：**
1. 檢查可用設備：
   ```python
   import openvino as ov
   core = ov.Core()
   print(core.available_devices)
   # 應該包含 GPU
   ```
2. 安裝/更新 GPU 驅動：
   - Intel iGPU：IGPU 驅動
   - NVIDIA：CUDA + cuDNN
   - AMD：ROCm

3. 使用 CPU 替代：
   ```python
   pipe = ov_genai.LLMPipeline("model_path", "CPU")
   ```

---

### 7. 模型轉換失敗

**錯誤信息：**
```
ValueError: Trust remote code is required
RuntimeError: Model not found
```

**原因：** 模型需要特殊配置或 Hugging Face 驗證

**解決方案：**
1. 添加 `--trust-remote-code`：
   ```powershell
   optimum-cli export openvino --model "model-id" --trust-remote-code ...
   ```
2. 設置 Hugging Face token：
   ```powershell
   huggingface-cli login
   # 或
   $env:HF_TOKEN = "your_token"
   ```
3. 驗證模型存在於 Hugging Face：
   訪問 https://huggingface.co/models

---

### 8. 推理變慢

**症狀：** 推理時間意外長

**可能原因和解決方案：**

1. **首次運行較慢（即時編譯）**
   ```python
   # 第一次推理較慢，後續會快
   pipe = ov_genai.LLMPipeline("model_path", "CPU")
   pipe.generate("warmup", max_new_tokens=5)  # 預熱
   result = pipe.generate("actual prompt", max_new_tokens=100)
   ```

2. **使用 CPU 代替 GPU**
   ```python
   # 切換到 GPU
   pipe = ov_genai.LLMPipeline("model_path", "GPU")
   ```

3. **模型過大**
   ```python
   # 使用更小的模型
   # 使用更激進的量化（INT4）
   ```

4. **系統資源不足**
   ```powershell
   # 減少線程數
   $env:OV_NUM_THREADS = "2"
   ```

5. **生成參數不佳**
   ```python
   # 減少生成長度
   pipe.generate(prompt, max_new_tokens=50)  # 而非 200
   ```

---

### 9. 中文或多語言問題

**症狀：** 中文或其他語言輸出亂碼或不正確

**解決方案：**
1. 使用支援多語言的模型：
   ```powershell
   # 使用支援中文的模型
   optimum-cli export openvino --model "Qwen/Qwen-7B-Chat" ...
   ```

2. 確保編碼正確：
   ```python
   # Python 文件編碼設置
   # -*- coding: utf-8 -*-
   
   prompt = "你好，OpenVINO 是什麼？"
   result = pipe.generate(prompt, max_new_tokens=100)
   print(result)
   ```

3. 使用支援該語言的 tokenizer

---

### 10. 虛擬環境問題

**症狀：** 虛擬環境無法啟動

**解決方案：**
```powershell
# 完全重新創建虛擬環境
Remove-Item -Recurse -Force venv

# 創建新的虛擬環境
python -m venv venv

# 啟動
.\venv\Scripts\Activate.ps1

# 安裝依賴
pip install -r requirements.txt
```

---

## 🔍 調試技巧

### 啟用詳細日誌

```powershell
# 設置日誌級別
$env:OV_LOG_LEVEL = "DEBUG"

# 然後運行您的代碼
python your_script.py
```

### 檢查環境

```python
import openvino as ov
import sys

print(f"Python 版本: {sys.version}")
print(f"OpenVINO 版本: {ov.__version__}")

# 檢查可用設備
core = ov.Core()
print(f"可用設備: {core.available_devices}")

# 檢查 CPU 詳情
print(f"CPU 詳情: {core.get_property('CPU', 'DEVICE_GAPI_DESC')}")
```

### 逐步調試

```python
import openvino_genai as ov_genai

# 1. 驗證模型路徑
model_path = "./models/TinyLlama-1.1B-int4"
import os
assert os.path.exists(model_path), f"模型不存在: {model_path}"
print("✓ 模型路徑正確")

# 2. 載入管道
pipe = ov_genai.LLMPipeline(model_path, "CPU")
print("✓ 模型載入成功")

# 3. 簡單測試
result = pipe.generate("Hi", max_new_tokens=5)
print(f"✓ 推理成功: {result}")

# 4. 完整測試
full_result = pipe.generate("Tell me about AI", max_new_tokens=100)
print(f"✓ 完整推理成功: {full_result}")
```

---

## 📞 獲取更多幫助

1. **查看官方文檔：**
   - https://openvinotoolkit.github.io/openvino.genai/

2. **檢查 GitHub Issues：**
   - https://github.com/openvinotoolkit/openvino.genai/issues

3. **社群論壇：**
   - https://github.com/openvinotoolkit/openvino/discussions

4. **本地測試：**
   ```powershell
   python scripts/test_openvino.py
   ```

---

## ✅ 驗證清單

在報告問題前，請檢查：

- [ ] Visual C++ Redistributable 已安裝
- [ ] 虛擬環境已啟動 (`(venv)` 前綴)
- [ ] 所有套件已安裝 (`pip list | grep openvino`)
- [ ] 模型路徑正確
- [ ] 有足夠的系統記憶體
- [ ] 嘗試使用 CPU 代替 GPU
- [ ] 已運行 `scripts/test_openvino.py` 驗證環境
