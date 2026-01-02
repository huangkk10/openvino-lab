# 階段 1：下載官方 C++ Runtime

**目標：** 下載 OpenVINO GenAI 2025.4.1.0 官方 Windows C++ Runtime 套件  
**時間：** 5-10 分鐘  
**難度：** ⭐ 簡單  
**狀態：** ✅ 已驗證

---

## 📋 本階段目標

1. 訪問官方 OpenVINO GenAI 儲存庫
2. 下載 Windows x86_64 套件
3. 驗證檔案完整性
4. 準備安裝目錄

---

## 🔍 為什麼需要官方 C++ Runtime？

### 問題背景

預編譯的 `benchmark_genai.exe` 是使用特定版本的 OpenVINO GenAI C++ 庫編譯的。如果使用 pip 安裝的 Python 套件中的 DLL，會出現：

- ❌ **版本不匹配錯誤**
- ❌ **缺少前端 DLL** (ir, onnx, pytorch 等)
- ❌ **入口點找不到**

### 解決方案

✅ 使用**官方 C++ Runtime 套件**，確保：
- 版本完全匹配
- 所有依賴完整
- 測試穩定可靠

---

## 📦 需要下載的檔案

### 檔案資訊

```
檔案名稱: openvino_genai_windows_2025.4.1.0_x86_64.zip
檔案大小: 168.52 MB
版本: 2025.4.1.0
平台: Windows x86_64
```

### 下載來源

**官方儲存庫：**
```
https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/2025.4.1/windows/
```

---

## 🚀 操作步驟

### 步驟 1.1：創建下載目錄

在 PowerShell 中執行：

```powershell
# 進入項目根目錄
cd C:\Users\svd\codes\openvino-lab

# 創建目錄結構
New-Item -Path "nvme_dsm_test\openvino_cpp_runtime\downloads" -ItemType Directory -Force
```

**預期結果：**
```
    Directory: C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----         1/2/2026   2:00 PM                downloads
```

---

### 步驟 1.2：下載官方套件

#### 方法 1：使用瀏覽器（推薦給新手）

1. **打開瀏覽器**，訪問：
   ```
   https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/2025.4.1/windows/
   ```

2. **找到檔案**：
   ```
   openvino_genai_windows_2025.4.1.0_x86_64.zip
   ```

3. **下載並保存**到：
   ```
   C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\downloads\
   ```

#### 方法 2：使用 PowerShell（推薦給進階用戶）

```powershell
# 設置變數
$downloadUrl = "https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/2025.4.1/windows/openvino_genai_windows_2025.4.1.0_x86_64.zip"
$destinationPath = "C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\downloads\openvino_genai_windows_2025.4.1.0_x86_64.zip"

# 下載檔案（顯示進度）
Write-Host "正在下載 OpenVINO GenAI C++ Runtime..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $downloadUrl -OutFile $destinationPath -UseBasicParsing

# 確認下載成功
if (Test-Path $destinationPath) {
    $fileSize = (Get-Item $destinationPath).Length / 1MB
    Write-Host "✅ 下載完成！檔案大小: $($fileSize.ToString('F2')) MB" -ForegroundColor Green
} else {
    Write-Host "❌ 下載失敗，請檢查網路連接" -ForegroundColor Red
}
```

**預期輸出：**
```
正在下載 OpenVINO GenAI C++ Runtime...
✅ 下載完成！檔案大小: 168.52 MB
```

---

### 步驟 1.3：驗證檔案完整性

#### 檢查檔案大小

```powershell
# 進入下載目錄
cd C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\downloads

# 檢查檔案資訊
Get-Item openvino_genai_windows_2025.4.1.0_x86_64.zip | Format-List Name, Length, LastWriteTime
```

**預期輸出：**
```
Name          : openvino_genai_windows_2025.4.1.0_x86_64.zip
Length        : 176685056  (約 168.52 MB)
LastWriteTime : 1/2/2026 2:15:00 PM
```

#### 計算 SHA256 校驗和（可選但推薦）

```powershell
# 計算檔案 SHA256
$hash = Get-FileHash -Path "openvino_genai_windows_2025.4.1.0_x86_64.zip" -Algorithm SHA256

# 顯示結果
Write-Host "檔案 SHA256: $($hash.Hash)" -ForegroundColor Cyan
```

**預期輸出：**
```
檔案 SHA256: [64位十六進制字符串]
```

---

### 步驟 1.4：確認目錄結構

檢查目錄結構是否正確：

```powershell
cd C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime

# 顯示目錄結構
tree /F
```

**預期結構：**
```
C:\USERS\SVD\CODES\OPENVINO-LAB\NVME_DSM_TEST\OPENVINO_CPP_RUNTIME
└───downloads
        openvino_genai_windows_2025.4.1.0_x86_64.zip
```

---

## ✅ 完成檢查

在進入下一階段前，確認以下項目：

- [ ] 目錄 `nvme_dsm_test\openvino_cpp_runtime\downloads\` 已創建
- [ ] 檔案 `openvino_genai_windows_2025.4.1.0_x86_64.zip` 已下載
- [ ] 檔案大小約為 168.52 MB (176,685,056 bytes)
- [ ] （可選）SHA256 校驗和已驗證

---

## 📊 階段總結

### 完成項目

✅ **目錄創建**
- 創建 `nvme_dsm_test\openvino_cpp_runtime\downloads\`

✅ **檔案下載**
- 下載 `openvino_genai_windows_2025.4.1.0_x86_64.zip` (168.52 MB)

✅ **檔案驗證**
- 檢查檔案大小和完整性

### 下一階段預告

在 [階段 2：設置獨立環境](STAGE_2_SETUP_ENVIRONMENT.md) 中，我們將：
1. 解壓下載的套件
2. 創建目錄結構
3. 複製所有必要的 DLL 文件

---

## ⚠️ 故障排除

### 問題 1：下載速度很慢

**原因：** 網路連接或儲存庫訪問速度限制

**解決方案：**
1. 使用瀏覽器下載（通常更穩定）
2. 使用下載管理器（如 Internet Download Manager）
3. 嘗試不同時間段下載

### 問題 2：下載中斷

**原因：** 網路不穩定

**解決方案：**
```powershell
# 使用 PowerShell 的斷點續傳功能
$url = "https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/2025.4.1/windows/openvino_genai_windows_2025.4.1.0_x86_64.zip"
$output = ".\openvino_genai_windows_2025.4.1.0_x86_64.zip"

# 使用 BITS 進行下載（支持斷點續傳）
Start-BitsTransfer -Source $url -Destination $output -Description "下載 OpenVINO GenAI"
```

### 問題 3：檔案損壞

**症狀：** 下載完成但檔案大小不正確

**解決方案：**
1. 刪除損壞的檔案
2. 清除瀏覽器快取
3. 重新下載

```powershell
# 刪除損壞的檔案
Remove-Item "openvino_genai_windows_2025.4.1.0_x86_64.zip" -Force
```

### 問題 4：無法訪問官方儲存庫

**原因：** 網路限制或 DNS 問題

**解決方案：**
1. 檢查防火牆設置
2. 嘗試使用 VPN
3. 檢查 DNS 設置

```powershell
# 測試連接
Test-NetConnection -ComputerName storage.openvinotoolkit.org -Port 443
```

---

## 📚 參考資源

### 官方資源

- [OpenVINO GenAI 版本列表](https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/)
- [OpenVINO 官方文檔](https://docs.openvino.ai/)
- [GitHub Repository](https://github.com/openvinotoolkit/openvino.genai)

### 項目內部文檔

- [返回主指南](README.md)
- [階段 2：設置獨立環境](STAGE_2_SETUP_ENVIRONMENT.md)

---

## 💡 提示與技巧

### 提示 1：批次下載

如果需要下載多個版本：

```powershell
$versions = @("2025.4.1.0", "2025.4.0.0")
foreach ($version in $versions) {
    $url = "https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/$version/windows/openvino_genai_windows_${version}_x86_64.zip"
    $output = ".\openvino_genai_windows_${version}_x86_64.zip"
    Write-Host "下載版本 $version ..."
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
}
```

### 提示 2：自動化腳本

創建 `download_runtime.ps1` 腳本：

```powershell
param(
    [string]$Version = "2025.4.1.0",
    [string]$OutputDir = ".\downloads"
)

$url = "https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/$Version/windows/openvino_genai_windows_${Version}_x86_64.zip"
$output = Join-Path $OutputDir "openvino_genai_windows_${Version}_x86_64.zip"

New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing

Write-Host "✅ 下載完成: $output" -ForegroundColor Green
```

---

## 🎯 關鍵要點

1. **官方套件最可靠** - 確保版本匹配和完整性
2. **驗證檔案大小** - 避免使用損壞的檔案
3. **保留原始檔案** - 後續可能需要重新解壓
4. **目錄結構清晰** - 便於後續管理和維護

---

**準備好了嗎？讓我們進入 [階段 2：設置獨立環境](STAGE_2_SETUP_ENVIRONMENT.md)！**

---

**創建日期：** 2026-01-02  
**最後更新：** 2026-01-02  
**維護者：** OpenVINO Lab 項目  
**狀態：** ✅ 已驗證可用
