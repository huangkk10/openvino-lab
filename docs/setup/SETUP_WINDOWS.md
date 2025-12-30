# Windows 環境設置步驟

## ⚠️ 重要：安裝 Visual C++ Redistributable

OpenVINO 和 PyTorch 需要 Microsoft Visual C++ Redistributable 才能正常運行。

### 安裝步驟：

1. 下載 Visual C++ Redistributable：
   - [下載連結 (x64)](https://aka.ms/vs/17/release/vc_redist.x64.exe)

2. 執行下載的安裝程式

3. 安裝完成後，**重新啟動 PowerShell 或終端機**

4. 重新啟動虛擬環境：
   ```powershell
   .\venv\Scripts\Activate.ps1
   ```

5. 再次運行測試：
   ```powershell
   python test_openvino.py
   ```

## 完整設置流程

### 第一次設置

```powershell
# 1. 確保已安裝 Visual C++ Redistributable（見上方）

# 2. 創建虛擬環境（如果還沒有）
python -m venv venv

# 3. 啟動虛擬環境
.\venv\Scripts\Activate.ps1

# 4. 安裝套件
pip install openvino-genai optimum[openvino]

# 5. 測試安裝
python test_openvino.py
```

### 每次使用時

```powershell
# 1. 啟動虛擬環境
.\venv\Scripts\Activate.ps1

# 2. 開始工作
# ... 您的代碼 ...

# 3. 完成後退出
deactivate
```

## 故障排除

### 錯誤：DLL load failed

**症狀：** `DLL load failed while importing _pyopenvino: The specified module could not be found.`

**解決方案：**
1. 安裝 Visual C++ Redistributable（見上方連結）
2. 重新啟動終端機
3. 重新啟動虛擬環境

### 錯誤：模組找不到

**症狀：** `ModuleNotFoundError: No module named 'xxx'`

**解決方案：**
```powershell
# 確保虛擬環境已啟動（應該看到 (venv) 前綴）
.\venv\Scripts\Activate.ps1

# 重新安裝套件
pip install openvino-genai optimum[openvino]
```

### PowerShell 執行策略錯誤

**症狀：** 無法執行 `.ps1` 腳本

**解決方案：**
```powershell
# 以管理員身份運行 PowerShell，然後執行：
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 驗證安裝成功

運行測試腳本後，您應該看到類似以下的輸出：

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

## 下一步

安裝成功後，請查看 `README.md` 了解如何：
- 下載和轉換模型
- 運行推理
- 使用不同的設備（CPU/GPU/NPU）
