# 第 2️⃣ 階段：系統依賴安裝指南

本指南涵蓋 OpenVINO GenAI 環境設置的第 2 階段：安裝系統級依賴（Visual C++ Redistributable）。

---

## 📋 目錄

- [概述](#概述)
- [為什麼需要 Visual C++ Redistributable](#為什麼需要-visual-c-redistributable)
- [安裝方法](#安裝方法)
  - [方法 1：自動安裝（推薦）](#方法-1自動安裝推薦)
  - [方法 2：手動安裝](#方法-2手動安裝)
  - [方法 3：使用腳本安裝](#方法-3使用腳本安裝)
- [驗證安裝](#驗證安裝)
- [常見問題](#常見問題)
- [故障排除](#故障排除)

---

## 概述

**目標：** 安裝 Microsoft Visual C++ Redistributable，這是 OpenVINO、PyTorch 和其他 Python 套件的必要系統依賴。

**所需時間：** 2-5 分鐘

**前置條件：**
- ✅ 已完成 [第 1 階段：前置準備](README.md#第-1️⃣-階段前置準備)
- ✅ Windows 10 或 11
- ✅ 管理員權限（用於安裝系統級別軟體）

**安裝內容：**
- Microsoft Visual C++ 2015-2022 Redistributable (x64)
- 版本：14.x 或更高

---

## 為什麼需要 Visual C++ Redistributable

Visual C++ Redistributable 包含許多 Windows 應用程式運行所需的 C/C++ 動態鏈接庫（DLL）。以下是 OpenVINO 環境中需要它的原因：

### 依賴的套件

| 套件 | 需要的 DLL | 用途 |
|------|-----------|------|
| **OpenVINO** | `msvcp140.dll`, `vcruntime140.dll` | 推理引擎核心 |
| **PyTorch** | `c10.dll`, `torch_cpu.dll` | 深度學習框架 |
| **NumPy** | `msvcp140.dll` | 數值計算 |
| **OpenVINO Tokenizers** | `vcruntime140.dll` | 文本處理 |

### 常見錯誤

如果**沒有**安裝 Visual C++ Redistributable，您會看到以下錯誤：

```
DLL load failed while importing _pyopenvino: The specified module could not be found.
```

或

```
OSError: [WinError 126] The specified module could not be found. 
Error loading "...\torch\lib\c10.dll" or one of its dependencies.
```

---

## 安裝方法

### 方法 1：自動安裝（推薦）

使用 PowerShell 一鍵下載並安裝：

```powershell
# 在 PowerShell 中執行（以管理員身份運行）
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" `
  -OutFile "$env:TEMP\vc_redist.x64.exe"

# 靜默安裝（無需用戶互動）
& "$env:TEMP\vc_redist.x64.exe" /install /quiet /norestart

Write-Host "✅ Visual C++ Redistributable 安裝完成！" -ForegroundColor Green
```

**說明：**
- `/install`：執行安裝
- `/quiet`：靜默模式，不顯示 UI
- `/norestart`：安裝後不自動重啟

**預期輸出：**
```
✅ Visual C++ Redistributable 安裝完成！
```

---

### 方法 2：手動安裝

#### 步驟 1：下載安裝程式

訪問 Microsoft 官方下載頁面：
- 🔗 [https://aka.ms/vs/17/release/vc_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe)
- 或搜尋：「Microsoft Visual C++ Redistributable」

#### 步驟 2：運行安裝程式

1. 雙擊下載的 `vc_redist.x64.exe`
2. 接受授權條款
3. 點擊「安裝」按鈕
4. 等待安裝完成（約 1-2 分鐘）
5. 點擊「關閉」

#### 步驟 3：重啟終端

安裝完成後，請重新打開 PowerShell 或命令提示字元。

---

### 方法 3：使用腳本安裝

如果您的項目有設置腳本，可以將安裝命令整合：

**建立 `install_vcredist.ps1`：**

```powershell
# install_vcredist.ps1
Write-Host "正在安裝 Visual C++ Redistributable..." -ForegroundColor Yellow

$vcRedistUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vcRedistPath = "$env:TEMP\vc_redist.x64.exe"

try {
    # 下載
    Write-Host "下載中..." -ForegroundColor Cyan
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $vcRedistUrl -OutFile $vcRedistPath
    
    # 安裝
    Write-Host "安裝中..." -ForegroundColor Cyan
    Start-Process -FilePath $vcRedistPath -ArgumentList "/install", "/quiet", "/norestart" -Wait
    
    Write-Host "✅ 安裝成功！" -ForegroundColor Green
}
catch {
    Write-Host "❌ 安裝失敗: $_" -ForegroundColor Red
    exit 1
}
```

**執行腳本：**

```powershell
.\install_vcredist.ps1
```

---

## 驗證安裝

### 方法 1：運行測試腳本

如果您已設置虛擬環境並安裝 Python 套件：

```powershell
# 啟動虛擬環境
.\venv\Scripts\Activate.ps1

# 運行測試
python scripts/test_openvino.py
```

**預期成功輸出：**
```
✓ OpenVINO GenAI 導入成功
✓ OpenVINO 導入成功
✓ OpenVINO Tokenizers 導入成功
✓ Optimum Intel 導入成功
```

### 方法 2：檢查已安裝的程式

#### 使用 PowerShell：

```powershell
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Where-Object { $_.DisplayName -like "*Visual C++*" } | 
    Select-Object DisplayName, DisplayVersion
```

**預期輸出：**
```
DisplayName                                              DisplayVersion
-----------                                              --------------
Microsoft Visual C++ 2015-2022 Redistributable (x64)     14.38.33135.0
```

#### 使用 Windows 設定：

1. 打開「設定」→「應用程式」→「已安裝的應用程式」
2. 搜尋「Visual C++」
3. 確認有「Microsoft Visual C++ 2015-2022 Redistributable (x64)」

### 方法 3：測試 DLL 載入

建立一個簡單的測試腳本：

**`test_vcredist.py`：**

```python
"""測試 Visual C++ Redistributable 是否正確安裝"""
import sys

def test_dll_loading():
    """測試關鍵 DLL 是否可以載入"""
    tests = {
        "OpenVINO": lambda: __import__("openvino.runtime"),
        "PyTorch": lambda: __import__("torch"),
        "NumPy": lambda: __import__("numpy"),
    }
    
    all_passed = True
    for name, test_func in tests.items():
        try:
            test_func()
            print(f"✓ {name} 載入成功")
        except ImportError as e:
            print(f"✗ {name} 載入失敗: {e}")
            all_passed = False
    
    return all_passed

if __name__ == "__main__":
    print("=" * 50)
    print("Visual C++ Redistributable 測試")
    print("=" * 50)
    
    if test_dll_loading():
        print("\n✅ 所有測試通過！")
        sys.exit(0)
    else:
        print("\n❌ 部分測試失敗")
        print("請確認 Visual C++ Redistributable 已正確安裝")
        sys.exit(1)
```

**執行：**

```powershell
python test_vcredist.py
```

---

## 常見問題

### ❓ 是否需要多個版本的 Visual C++ Redistributable？

**答：** 不需要。Microsoft Visual C++ 2015-2022 Redistributable 向後兼容，涵蓋了 2015、2017、2019 和 2022 版本。

### ❓ 可以在非管理員帳號下安裝嗎？

**答：** 不可以。Visual C++ Redistributable 是系統級軟體，需要管理員權限。

**解決方案：**
- 右鍵點擊 PowerShell → 選擇「以管理員身份執行」
- 或聯繫系統管理員協助安裝

### ❓ 安裝後是否需要重啟電腦？

**答：** 通常不需要。使用 `/norestart` 參數可以避免強制重啟。但建議：
- 重新啟動 PowerShell/終端視窗
- 重新啟動虛擬環境

### ❓ 如何卸載 Visual C++ Redistributable？

**答：** 不建議卸載，因為許多應用程式依賴它。如果必須卸載：

1. 打開「設定」→「應用程式」
2. 搜尋「Visual C++」
3. 選擇版本 → 點擊「卸載」

**警告：** 卸載後可能導致其他應用程式無法運行！

### ❓ 可以同時安裝 x86 和 x64 版本嗎？

**答：** 可以且安全。兩者互不衝突：
- **x64 版本**：用於 64 位應用程式（OpenVINO、PyTorch 等）
- **x86 版本**：用於 32 位應用程式

本指南只需安裝 **x64 版本**。

---

## 故障排除

### ❌ 錯誤：「無法下載安裝程式」

**症狀：**
```
Invoke-WebRequest : 無法連接到遠端伺服器
```

**原因：** 網絡連接問題或防火牆阻擋。

**解決方案：**

1. **檢查網絡連接：**
   ```powershell
   Test-NetConnection -ComputerName aka.ms -Port 443
   ```

2. **使用瀏覽器手動下載：**
   - 訪問：https://aka.ms/vs/17/release/vc_redist.x64.exe
   - 保存到 `C:\Temp\vc_redist.x64.exe`

3. **然後手動安裝：**
   ```powershell
   & "C:\Temp\vc_redist.x64.exe" /install /quiet /norestart
   ```

---

### ❌ 錯誤：「安裝失敗，錯誤代碼 0x80070666」

**症狀：**
```
Error code: 0x80070666
Another version is already installed
```

**原因：** 已安裝相同或更新版本的 Visual C++ Redistributable。

**解決方案：**

✅ **這不是問題！** 如果已有更新版本，無需重新安裝。

**驗證：**
```powershell
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Where-Object { $_.DisplayName -like "*Visual C++*" }
```

如果輸出顯示版本 ≥ 14.30，則可以跳過此步驟。

---

### ❌ 錯誤：「DLL load failed」（安裝後仍出現）

**症狀：**
```
DLL load failed while importing _pyopenvino: The specified module could not be found.
```

**原因：** 可能的原因：
1. 終端未重新啟動
2. 虛擬環境未重新啟動
3. 安裝不完整

**解決方案：**

**步驟 1：完全重啟環境**

```powershell
# 退出虛擬環境
deactivate

# 關閉 PowerShell，重新打開

# 回到專案目錄
cd C:\Users\svd\codes\openvino-lab

# 重新啟動虛擬環境
.\venv\Scripts\Activate.ps1

# 再次測試
python scripts/test_openvino.py
```

**步驟 2：重新安裝 Visual C++ Redistributable**

```powershell
# 下載修復安裝程式
$url = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$path = "$env:TEMP\vc_redist.x64.exe"
Invoke-WebRequest -Uri $url -OutFile $path

# 使用 /repair 參數修復
& $path /repair /quiet /norestart
```

**步驟 3：檢查 DLL 路徑**

```powershell
# 檢查 PATH 環境變數是否包含系統目錄
$env:PATH -split ';' | Where-Object { $_ -like "*System32*" }
```

應該包含：
- `C:\Windows\System32`
- `C:\Windows\SysWOW64`

---

### ❌ 錯誤：「需要管理員權限」

**症狀：**
```
Access denied. Administrator privileges are required.
```

**解決方案：**

1. **關閉當前 PowerShell**

2. **以管理員身份打開 PowerShell：**
   - 按 `Win + X`
   - 選擇「Windows PowerShell (系統管理員)」或「終端機 (系統管理員)」

3. **導航到專案目錄並重新執行：**
   ```powershell
   cd C:\Users\svd\codes\openvino-lab
   # 執行安裝命令...
   ```

---

### ❌ 錯誤：「PowerShell 執行策略限制」

**症狀：**
```
無法載入檔案 ...，因為這個系統上已停用指令碼執行。
```

**解決方案：**

```powershell
# 設置執行策略（僅當前用戶）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 確認變更
Get-ExecutionPolicy
```

應該顯示：`RemoteSigned` 或 `Unrestricted`

---

## 下一步

✅ 完成此階段後，您應該已經：
- ✅ 成功安裝 Visual C++ Redistributable
- ✅ 驗證 DLL 可以正確載入
- ✅ 沒有出現 DLL 相關錯誤

**繼續下一階段：**
- 📖 [第 3 階段：虛擬環境](README.md#第-3️⃣-階段虛擬環境) - 創建 Python 虛擬環境
- 📖 [返回設置指南](README.md) - 查看完整設置流程

---

## 相關資源

- 📖 [完整設置流程](SETUP_PROGRESS.md) - 所有 9 個階段的詳細說明
- ⚙️ [Windows 設置步驟](SETUP_WINDOWS.md) - 具體的操作說明
- 🆘 [故障排除](../TROUBLESHOOTING.md) - 常見問題解決
- 🔗 [Microsoft 官方文檔](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist) - Visual C++ Redistributable 下載頁面

---

**版本資訊：**
- 文檔版本：1.0.0
- 最後更新：2026-01-02
- 適用於：Windows 10/11, OpenVINO 2025.4+
