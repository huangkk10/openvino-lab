# MSVC Runtime 安裝指南

**目的：** 安裝 Microsoft Visual C++ 2015-2022 Redistributable  
**需求：** benchmark_genai.exe 執行所必需  
**時間：** 1-2 分鐘  
**難度：** ⭐ 簡單

---

## 🎯 為什麼需要 MSVC Runtime？

`benchmark_genai.exe` 是用 Visual Studio 編譯的 C++ 程序，需要以下系統庫：

- `vcruntime140.dll` - C Runtime Library
- `vcruntime140_1.dll` - C Runtime Library (Extended)
- `msvcp140.dll` - C++ Standard Library

這些是 Windows 上幾乎所有 C++ 程序都需要的基礎庫。

### 錯誤症狀

如果缺少 MSVC Runtime，會出現：
- **錯誤代碼：** `-1073741515` (0xC0000135)
- **錯誤訊息：** "STATUS_DLL_NOT_FOUND"
- **症狀：** benchmark_genai.exe 無法啟動

---

## ✅ 安裝方法

### 方法 1：使用一鍵安裝腳本（最推薦）

**包含在 OpenVINO Runtime 安裝中：**

```powershell
# 這會自動檢查和安裝 MSVC Runtime
.\scripts\install_openvino_runtime.ps1
```

**腳本會自動：**
- 檢測是否已安裝 MSVC Runtime
- 如果缺失，自動下載並安裝
- 靜默安裝，無需手動操作
- 驗證安裝成功

---

### 方法 2：使用獨立安裝腳本

**僅安裝 MSVC Runtime：**

```powershell
# 基本安裝
.\scripts\install_msvc_runtime.ps1

# 靜默安裝（不提示）
.\scripts\install_msvc_runtime.ps1 -Silent

# 強制重新安裝
.\scripts\install_msvc_runtime.ps1 -Force
```

**腳本功能：**
- ✅ 完整的安裝前檢查
- ✅ 自動下載最新版本
- ✅ 靜默安裝（/quiet /norestart）
- ✅ 安裝後驗證
- ✅ 詳細的狀態報告

---

### 方法 3：手動安裝

**如果自動腳本失敗：**

1. **下載安裝程序：**
   ```
   https://aka.ms/vs/17/release/vc_redist.x64.exe
   ```

2. **執行安裝：**
   - 雙擊下載的 `vc_redist.x64.exe`
   - 點擊「安裝」或「Install」
   - 等待安裝完成（1-2 分鐘）

3. **重新啟動 PowerShell**

---

## 🔍 檢查安裝狀態

### 使用 PowerShell 檢查

```powershell
# 方法 1：搜尋 DLL
Get-ChildItem "C:\Windows\System32" -Filter vcruntime140*.dll | Select-Object Name, Length

# 方法 2：使用 where 命令
where.exe vcruntime140.dll

# 方法 3：檢查已安裝的程序
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Where-Object { $_.DisplayName -like "*Visual C++*" } | 
    Select-Object DisplayName, DisplayVersion
```

### 預期結果

**已安裝：**
```
Name                 Length
----                 ------
vcruntime140.dll     124544
vcruntime140_1.dll   43824
```

**未安裝：**
```
INFO: Could not find files for the given pattern(s).
```

---

## 📊 版本資訊

### 當前推薦版本

- **名稱：** Microsoft Visual C++ 2015-2022 Redistributable (x64)
- **版本：** 14.40 或更高
- **大小：** ~14 MB
- **下載來源：** https://aka.ms/vs/17/release/vc_redist.x64.exe

### 兼容性

此 Runtime 支援：
- ✅ Visual C++ 2015
- ✅ Visual C++ 2017
- ✅ Visual C++ 2019
- ✅ Visual C++ 2022

安裝一個版本即可滿足所有需求。

---

## ⚠️ 常見問題

### Q1：安裝後仍然找不到 DLL？

**解決方案：**
1. 關閉並重新開啟 PowerShell
2. 如果還是不行，重新啟動電腦
3. 檢查是否安裝了 x86 版本（需要 x64 版本）

### Q2：安裝程序返回錯誤代碼

**常見錯誤代碼：**
- `0` - 成功
- `1638` - 已經安裝（這是正常的）
- `3010` - 成功，需要重新啟動
- `5100` - 系統不符合最低需求

### Q3：需要重新啟動嗎？

**通常不需要，但建議：**
- 安裝完成後重新開啟 PowerShell
- 如果出現 3010 錯誤代碼，建議重啟
- 如果仍有問題，嘗試完全重啟系統

### Q4：可以離線安裝嗎？

**可以：**
1. 在有網路的電腦上下載 `vc_redist.x64.exe`
2. 複製到目標電腦
3. 手動執行安裝

或使用離線安裝參數：
```powershell
.\vc_redist.x64.exe /install /quiet /norestart
```

### Q5：影響其他軟體嗎？

**不會：**
- MSVC Runtime 是系統共享庫
- 很多程序都依賴它
- 安裝只會新增或更新，不會破壞現有程序

---

## 🔧 進階選項

### 靜默安裝（腳本中）

```powershell
# 完全靜默，無任何提示
$vcRedistUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vcRedistPath = "$env:TEMP\vc_redist.x64.exe"

Invoke-WebRequest -Uri $vcRedistUrl -OutFile $vcRedistPath -UseBasicParsing
Start-Process -FilePath $vcRedistPath -ArgumentList "/install", "/quiet", "/norestart" -Wait
Remove-Item $vcRedistPath
```

### 檢查所有 Visual C++ 版本

```powershell
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, 
                 HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName -like "*Visual C++*" } |
    Select-Object DisplayName, DisplayVersion, InstallDate |
    Sort-Object DisplayName
```

### 卸載（如需重新安裝）

```powershell
# 查找卸載程序
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName -like "*Visual C++ 2015-2022*" } |
    Select-Object DisplayName, UninstallString

# 或使用 Windows 設定
# 設定 > 應用程式 > 搜尋 "Visual C++" > 卸載
```

---

## 📚 相關資源

### 官方文檔

- [最新支援的 Visual C++ 下載](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)
- [Visual C++ Redistributable 下載頁面](https://aka.ms/vs/17/release/vc_redist.x64.exe)

### 項目文檔

- [Stage 1：下載官方 C++ Runtime](STAGE_1_DOWNLOAD_RUNTIME.md)
- [故障排除：DLL 缺失問題](../nvme_dsm_test/FIX_DLL_MISSING.md)

---

## 🎯 快速參考

### 檢查是否已安裝

```powershell
where.exe vcruntime140.dll
```

### 一鍵安裝（包含 OpenVINO）

```powershell
.\scripts\install_openvino_runtime.ps1
```

### 獨立安裝 MSVC Runtime

```powershell
.\scripts\install_msvc_runtime.ps1
```

### 手動下載

```
https://aka.ms/vs/17/release/vc_redist.x64.exe
```

---

## ✅ 驗證安裝成功

安裝完成後，執行：

```powershell
# 檢查 DLL
Get-ChildItem "C:\Windows\System32" -Filter vcruntime140.dll

# 測試 benchmark
cd nvme_dsm_test
.\run_benchmark_with_official_runtime.ps1
```

**成功標準：**
- ✅ 找到 vcruntime140.dll
- ✅ benchmark_genai.exe 可以啟動
- ✅ 退出代碼：0（成功）

---

**創建日期：** 2026-01-06  
**最後更新：** 2026-01-06  
**維護者：** OpenVINO Lab 項目  
**狀態：** ✅ 已驗證可用
