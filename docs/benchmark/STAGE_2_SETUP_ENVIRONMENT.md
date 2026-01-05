# 階段 2：設置獨立環境

**目標：** 解壓官方套件並設置完整的 DLL 依賴環境  
**時間：** 10-15 分鐘  
**難度：** ⭐⭐ 中等  
**狀態：** ✅ 已驗證

---

## 📋 本階段目標

1. 解壓官方 C++ Runtime 套件
2. 建立完整的目錄結構
3. 複製所有必要的 DLL 文件（19 個）
4. 驗證環境完整性

---

## 🎯 為什麼需要獨立環境？

### 設計理念

✅ **隔離性** - 不影響 Python 虛擬環境  
✅ **可移植性** - 整個目錄可以打包移動  
✅ **可維護性** - 所有依賴集中管理  
✅ **可重複性** - 環境可以輕鬆重建

### 目錄結構設計

```
openvino_cpp_runtime\
├── bin\                   ← 所有運行時 DLL（最重要！）
├── lib\                   ← 開發用庫文件（可選）
├── downloads\             ← 原始下載檔案（備份）
└── openvino_genai_windows_2025.4.1.0_x86_64\  ← 解壓內容
```

---

## 🚀 操作步驟

### 步驟 2.1：解壓官方套件

```powershell
# 進入 C++ Runtime 目錄
cd C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime

# 解壓檔案
Write-Host "正在解壓 OpenVINO GenAI C++ Runtime..." -ForegroundColor Cyan
Expand-Archive -Path "downloads\openvino_genai_windows_2025.4.1.0_x86_64.zip" -DestinationPath "." -Force

Write-Host "✅ 解壓完成！" -ForegroundColor Green
```

**預期輸出：**
```
正在解壓 OpenVINO GenAI C++ Runtime...
✅ 解壓完成！
```

**驗證解壓結果：**
```powershell
# 檢查解壓目錄
dir
```

**預期結果：**
```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----         1/2/2026   2:20 PM                openvino_genai_windows_2025.4.1.0_x86_64
d-----         1/2/2026   2:15 PM                downloads
```

---

### 步驟 2.2：探索套件結構

```powershell
# 查看套件內部結構
cd openvino_genai_windows_2025.4.1.0_x86_64
tree /F
```

**關鍵目錄：**
```
openvino_genai_windows_2025.4.1.0_x86_64\
├── runtime\
│   ├── bin\
│   │   └── intel64\
│   │       └── Release\        ← **重要！所有 DLL 在這裡**
│   └── lib\
├── samples\
└── docs\
```

---

### 步驟 2.3：創建 bin 目錄

```powershell
# 返回上層目錄
cd ..

# 創建 bin 和 lib 目錄
New-Item -Path "bin" -ItemType Directory -Force
New-Item -Path "lib" -ItemType Directory -Force

Write-Host "✅ 目錄結構已創建" -ForegroundColor Green
```

---

### 步驟 2.4：複製所有必要的 DLL 文件

這是**最關鍵**的步驟！需要複製 19 個 DLL 文件。

```powershell
# 定義源路徑和目標路徑
$sourcePath = "openvino_genai_windows_2025.4.1.0_x86_64\runtime\bin\intel64\Release"
$destPath = "bin"

Write-Host "正在複製 DLL 文件..." -ForegroundColor Cyan

# 複製所有 DLL 文件
Copy-Item -Path "$sourcePath\*.dll" -Destination $destPath -Force -Verbose

# 複製所有 .lib 文件到 lib 目錄（可選，用於開發）
Copy-Item -Path "openvino_genai_windows_2025.4.1.0_x86_64\runtime\lib\intel64\Release\*.lib" -Destination "lib" -Force

Write-Host "✅ 所有檔案已複製完成！" -ForegroundColor Green
```

**預期輸出：**
```
正在複製 DLL 文件...
VERBOSE: Performing the operation "Copy File" on target "Item: ...\openvino_genai.dll Destination: ...\bin\openvino_genai.dll".
VERBOSE: Performing the operation "Copy File" on target "Item: ...\openvino.dll Destination: ...\bin\openvino.dll".
...（共 19 個 DLL 文件）
✅ 所有檔案已複製完成！
```

---

### 步驟 2.5：驗證所有必要的 DLL

#### 必需的 19 個 DLL 文件清單

```powershell
# 檢查所有 DLL 文件
cd bin
dir *.dll | Format-Table Name, Length -AutoSize
```

**預期輸出：**

| 檔案名稱 | 大小 | 類型 | 說明 |
|----------|------|------|------|
| **openvino_genai.dll** | 4.67 MB | 核心 | GenAI 主程式庫 ⭐ |
| **openvino.dll** | 14.45 MB | 核心 | OpenVINO 運行時 ⭐ |
| **openvino_tokenizers.dll** | 2.4 MB | 核心 | Tokenizer 支援 ⭐ |
| **openvino_ir_frontend.dll** | ~1 MB | 前端 | IR 模型支援 |
| **openvino_onnx_frontend.dll** | ~2 MB | 前端 | ONNX 模型支援 |
| **openvino_paddle_frontend.dll** | ~1 MB | 前端 | PaddlePaddle 支援 |
| **openvino_pytorch_frontend.dll** | ~1 MB | 前端 | PyTorch 模型支援 |
| **openvino_tensorflow_frontend.dll** | ~2 MB | 前端 | TensorFlow 支援 |
| **openvino_tensorflow_lite_frontend.dll** | ~1 MB | 前端 | TFLite 支援 |
| **openvino_intel_cpu_plugin.dll** | ~3 MB | 插件 | CPU 設備支援 ⭐ |
| **openvino_intel_gpu_plugin.dll** | ~8 MB | 插件 | GPU 設備支援 |
| **openvino_intel_npu_plugin.dll** | ~2 MB | 插件 | NPU 設備支援 |
| **icudt70.dll** | 28.12 MB | 依賴 | ICU 數據庫 |
| **icuuc70.dll** | 2.16 MB | 依賴 | ICU Unicode |
| **tbb12.dll** | ~500 KB | 依賴 | Threading Building Blocks |
| **tbbbind_2_5.dll** | ~100 KB | 依賴 | TBB 綁定庫 |
| **tbbmalloc.dll** | ~300 KB | 依賴 | TBB 記憶體分配器 |
| **pugixml.dll** | ~200 KB | 依賴 | XML 解析器 |
| **plugins.xml** | 1 KB | 配置 | 插件配置文件 |

---

### 步驟 2.6：使用自動化腳本驗證（推薦）

創建 `verify_dlls.ps1` 驗證腳本：

```powershell
# 返回 openvino_cpp_runtime 目錄
cd C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime

# 創建驗證腳本
@'
# DLL 驗證腳本
$requiredDlls = @(
    "openvino_genai.dll",
    "openvino.dll",
    "openvino_tokenizers.dll",
    "openvino_ir_frontend.dll",
    "openvino_onnx_frontend.dll",
    "openvino_paddle_frontend.dll",
    "openvino_pytorch_frontend.dll",
    "openvino_tensorflow_frontend.dll",
    "openvino_tensorflow_lite_frontend.dll",
    "openvino_intel_cpu_plugin.dll",
    "openvino_intel_gpu_plugin.dll",
    "openvino_intel_npu_plugin.dll",
    "icudt70.dll",
    "icuuc70.dll",
    "tbb12.dll",
    "tbbbind_2_5.dll",
    "tbbmalloc.dll",
    "pugixml.dll"
)

Write-Host "`n=== DLL 依賴檢查 ===" -ForegroundColor Cyan
$binPath = "bin"
$missingDlls = @()

foreach ($dll in $requiredDlls) {
    $dllPath = Join-Path $binPath $dll
    if (Test-Path $dllPath) {
        $fileInfo = Get-Item $dllPath
        $sizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
        Write-Host "✅ $dll ($sizeKB KB)" -ForegroundColor Green
    } else {
        Write-Host "❌ $dll (缺少)" -ForegroundColor Red
        $missingDlls += $dll
    }
}

# 檢查 plugins.xml
$pluginsXml = Join-Path $binPath "plugins.xml"
if (Test-Path $pluginsXml) {
    Write-Host "✅ plugins.xml" -ForegroundColor Green
} else {
    Write-Host "❌ plugins.xml (缺少)" -ForegroundColor Red
    $missingDlls += "plugins.xml"
}

# 總結
Write-Host "`n=== 檢查總結 ===" -ForegroundColor Cyan
$totalRequired = $requiredDlls.Count + 1  # +1 for plugins.xml
$foundCount = $totalRequired - $missingDlls.Count

Write-Host "總計: $foundCount / $totalRequired 個檔案" -ForegroundColor Yellow

if ($missingDlls.Count -eq 0) {
    Write-Host "✅ 所有依賴檔案完整！" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ 缺少 $($missingDlls.Count) 個檔案:" -ForegroundColor Red
    foreach ($dll in $missingDlls) {
        Write-Host "   - $dll"
    }
    exit 1
}
'@ | Out-File -FilePath "verify_dlls.ps1" -Encoding UTF8

# 執行驗證
.\verify_dlls.ps1
```

**預期輸出（全部通過）：**
```
=== DLL 依賴檢查 ===
✅ openvino_genai.dll (4780.5 KB)
✅ openvino.dll (14785.25 KB)
✅ openvino_tokenizers.dll (2457.6 KB)
✅ openvino_ir_frontend.dll (1024.0 KB)
...（所有 DLL）
✅ plugins.xml

=== 檢查總結 ===
總計: 19 / 19 個檔案
✅ 所有依賴檔案完整！
```

---

### 步驟 2.7：最終目錄結構檢查

```powershell
# 檢查完整目錄結構
cd C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime
tree /F
```

**預期最終結構：**
```
C:\USERS\SVD\CODES\OPENVINO-LAB\NVME_DSM_TEST\OPENVINO_CPP_RUNTIME
├───bin
│       icudt70.dll
│       icuuc70.dll
│       openvino.dll
│       openvino_genai.dll
│       openvino_intel_cpu_plugin.dll
│       openvino_intel_gpu_plugin.dll
│       openvino_intel_npu_plugin.dll
│       openvino_ir_frontend.dll
│       openvino_onnx_frontend.dll
│       openvino_paddle_frontend.dll
│       openvino_pytorch_frontend.dll
│       openvino_tensorflow_frontend.dll
│       openvino_tensorflow_lite_frontend.dll
│       openvino_tokenizers.dll
│       plugins.xml
│       pugixml.dll
│       tbb12.dll
│       tbbbind_2_5.dll
│       tbbmalloc.dll
├───downloads
│       openvino_genai_windows_2025.4.1.0_x86_64.zip
├───lib
│       (開發用 .lib 文件，可選)
└───openvino_genai_windows_2025.4.1.0_x86_64
    └───runtime
        ├───bin
        │   └───intel64
        │       └───Release
        └───lib
```

---

## ✅ 完成檢查

在進入下一階段前，確認以下項目：

- [ ] 官方套件已成功解壓
- [ ] `bin\` 目錄已創建
- [ ] 所有 19 個 DLL 文件已複製到 `bin\`
- [ ] `plugins.xml` 文件已存在於 `bin\`
- [ ] 驗證腳本執行通過（19/19 檔案）
- [ ] 目錄結構清晰完整

---

## 📊 階段總結

### 完成項目

✅ **環境搭建**
- 解壓官方 C++ Runtime 套件
- 創建 bin 和 lib 目錄結構

✅ **DLL 部署**
- 複製 19 個必要 DLL 文件
- 驗證所有依賴完整性

✅ **環境驗證**
- 創建自動化驗證腳本
- 確認所有檔案就位

### 關鍵成果

📦 **獨立運行時環境**
- 不依賴 Python venv
- 所有依賴自包含
- 可移植和重複使用

### 下一階段預告

在 [階段 4：配置執行腳本](STAGE_4_CREATE_SCRIPT.md) 中，我們將：
1. 創建自動化執行腳本
2. 配置 PATH 環境變數
3. 測試 benchmark_genai.exe 執行

---

## ⚠️ 故障排除

### 問題 1：解壓失敗

**症狀：** "Archive is corrupted" 或 "File is damaged"

**解決方案：**
1. 檢查下載檔案完整性
2. 重新下載官方套件
3. 使用其他解壓工具（如 7-Zip）

```powershell
# 檢查 ZIP 文件完整性
Test-Path "downloads\openvino_genai_windows_2025.4.1.0_x86_64.zip"

# 檢查檔案大小
(Get-Item "downloads\openvino_genai_windows_2025.4.1.0_x86_64.zip").Length / 1MB
```

### 問題 2：找不到 DLL 源路徑

**症狀：** `Copy-Item: Cannot find path`

**原因：** 路徑不正確或解壓未完成

**解決方案：**
```powershell
# 手動檢查路徑
$sourcePath = "openvino_genai_windows_2025.4.1.0_x86_64\runtime\bin\intel64\Release"
if (Test-Path $sourcePath) {
    Write-Host "✅ 路徑存在" -ForegroundColor Green
    dir $sourcePath\*.dll
} else {
    Write-Host "❌ 路徑不存在，請檢查解壓結果" -ForegroundColor Red
}
```

### 問題 3：DLL 數量不足

**症狀：** 驗證腳本顯示 "15 / 19 個檔案"

**原因：** 部分 DLL 複製失敗

**解決方案：**
```powershell
# 重新複製所有 DLL
$sourcePath = "openvino_genai_windows_2025.4.1.0_x86_64\runtime\bin\intel64\Release"
$destPath = "bin"

# 強制覆蓋複製
Get-ChildItem "$sourcePath\*.dll" | ForEach-Object {
    Copy-Item $_.FullName -Destination $destPath -Force -Verbose
}
```

### 問題 4：權限錯誤

**症狀：** "Access denied" 或 "Permission error"

**解決方案：**
```powershell
# 以管理員身份運行 PowerShell
# 或檢查目錄權限
icacls "bin"
```

### 問題 5：plugins.xml 缺失

**症狀：** 驗證腳本顯示 "❌ plugins.xml (缺少)"

**解決方案：**
```powershell
# 手動複製 plugins.xml
$pluginsXml = "openvino_genai_windows_2025.4.1.0_x86_64\runtime\bin\intel64\Release\plugins.xml"
Copy-Item $pluginsXml -Destination "bin\" -Force

# 驗證
Test-Path "bin\plugins.xml"
```

---

## 📚 參考資源

### DLL 功能說明

#### 核心庫（Core）
- **openvino_genai.dll** - GenAI API 主程式庫
- **openvino.dll** - OpenVINO 核心運行時
- **openvino_tokenizers.dll** - 文本分詞器

#### 前端庫（Frontends）
- **openvino_ir_frontend.dll** - OpenVINO IR 格式
- **openvino_onnx_frontend.dll** - ONNX 模型格式
- **openvino_paddle_frontend.dll** - PaddlePaddle 格式
- **openvino_pytorch_frontend.dll** - PyTorch 模型格式
- **openvino_tensorflow_frontend.dll** - TensorFlow 格式
- **openvino_tensorflow_lite_frontend.dll** - TensorFlow Lite

#### 設備插件（Plugins）
- **openvino_intel_cpu_plugin.dll** - Intel CPU 加速
- **openvino_intel_gpu_plugin.dll** - Intel GPU 加速
- **openvino_intel_npu_plugin.dll** - Intel NPU 加速

#### 依賴庫（Dependencies）
- **icudt70.dll / icuuc70.dll** - Unicode 支援
- **tbb12.dll / tbbbind_2_5.dll / tbbmalloc.dll** - 多線程支援
- **pugixml.dll** - XML 解析

### 官方文檔

- [OpenVINO Runtime 文檔](https://docs.openvino.ai/latest/openvino_docs_Runtime_User_Guide.html)
- [DLL 依賴說明](https://docs.openvino.ai/latest/openvino_docs_deployment_guide_introduction.html)

---

## 💡 提示與技巧

### 提示 1：批次複製腳本

創建 `copy_dlls.ps1` 用於快速部署：

```powershell
param(
    [string]$SourceBase = "openvino_genai_windows_2025.4.1.0_x86_64\runtime\bin\intel64\Release",
    [string]$DestPath = "bin"
)

# 確保目標目錄存在
New-Item -Path $DestPath -ItemType Directory -Force | Out-Null

# 複製所有 DLL 和 XML 文件
$files = Get-ChildItem -Path $SourceBase -Include *.dll, *.xml -Recurse
$copiedCount = 0

foreach ($file in $files) {
    Copy-Item $file.FullName -Destination $DestPath -Force
    $copiedCount++
}

Write-Host "✅ 已複製 $copiedCount 個檔案到 $DestPath" -ForegroundColor Green
```

### 提示 2：清理並重建環境

```powershell
# 清理腳本
Remove-Item "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "lib" -Recurse -Force -ErrorAction SilentlyContinue

# 重建環境
New-Item -Path "bin" -ItemType Directory -Force
New-Item -Path "lib" -ItemType Directory -Force

# 重新複製 DLL
.\copy_dlls.ps1
.\verify_dlls.ps1
```

### 提示 3：備份環境

```powershell
# 創建環境備份
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupPath = "backup_$timestamp"

Copy-Item "bin" -Destination $backupPath -Recurse -Force
Write-Host "✅ 環境已備份到: $backupPath" -ForegroundColor Green
```

---

## 🎯 關鍵要點

1. **所有 19 個 DLL 都必須存在** - 缺一不可
2. **plugins.xml 是設備插件配置** - 必須包含
3. **DLL 來自 Release 目錄** - 不是 Debug 版本
4. **環境是獨立的** - 不影響 Python venv
5. **使用驗證腳本** - 確保環境完整性

---

**準備好了嗎？讓我們進入 [階段 3：下載 AI 模型](STAGE_3_DOWNLOAD_MODEL.md)！**

---

**創建日期：** 2026-01-02  
**最後更新：** 2026-01-02  
**維護者：** OpenVINO Lab 項目  
**狀態：** ✅ 已驗證可用
