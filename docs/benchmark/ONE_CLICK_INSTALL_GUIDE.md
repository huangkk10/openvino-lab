# OpenVINO Runtime 一鍵安裝指南

## 📋 概述

`install_openvino_runtime.ps1` 是一個全自動化安裝腳本，可以在任何 Windows 電腦上快速部署 OpenVINO GenAI C++ Runtime。

## ✨ 主要功能

- ✅ **全自動化**：一個命令完成所有設置
- ✅ **智能檢測**：自動跳過已完成的步驟
- ✅ **完整驗證**：SHA256 校驗和確保文件完整性
- ✅ **詳細報告**：生成完整的安裝報告
- ✅ **錯誤處理**：清晰的錯誤信息和故障排除提示

## 🚀 快速開始

### 基本用法

```powershell
# 進入項目根目錄
cd C:\your\project\path\openvino-lab

# 執行安裝
.\scripts\install_openvino_runtime.ps1
```

### 使用現有下載文件

如果您已經下載過 OpenVINO GenAI Runtime：

```powershell
.\scripts\install_openvino_runtime.ps1 -SkipDownload
```

### 重新安裝

```powershell
.\scripts\install_openvino_runtime.ps1 -ForceReinstall
```

## 📝 命令參數

| 參數 | 說明 | 預設值 |
|------|------|--------|
| `-Version` | OpenVINO GenAI 版本 | 2025.4.1.0 |
| `-InstallRoot` | 安裝目錄 | `.\openvino_cpp_runtime` |
| `-SkipDownload` | 跳過下載步驟 | False |
| `-SkipHashCheck` | 跳過 SHA256 驗證 | False |
| `-ForceReinstall` | 強制重新安裝 | False |

## 📊 安裝流程

腳本會按順序執行以下步驟：

### 1. 準備目錄結構
- 創建 `openvino_cpp_runtime` 主目錄
- 創建 `downloads`, `bin`, `lib` 子目錄

### 2. 下載官方套件
- 從 OpenVINO 官方儲存庫下載
- 文件大小：約 168.5 MB
- 同時下載 SHA256 校驗和文件

### 3. 驗證文件完整性
- 計算下載文件的 SHA256
- 與官方值比對
- 確保文件未損壞

### 4. 解壓套件
- 解壓到 `openvino_genai_windows_2025.4.1.0_x86_64` 目錄
- 自動檢測已解壓的文件

### 5. 部署運行時文件
- 複製所有 DLL 文件到 `bin` 目錄
- 複製開發用 lib 文件到 `lib` 目錄
- 包含配置文件（XML, JSON）

### 6. 驗證安裝
- 檢查 4 個核心 DLL
- 檢查 13 個建議 DLL
- 顯示每個文件的大小

### 7. 生成報告
- 創建 `INSTALLATION_REPORT.md`
- 包含完整的安裝信息和文件清單

## ✅ 成功標準

安裝成功後，您應該看到：

```
========================================
  Installation Complete!
========================================

[SUCCESS] OpenVINO GenAI Runtime installed successfully!

Install Directory: C:\...\openvino_cpp_runtime
Binary Directory: C:\...\openvino_cpp_runtime\bin
Installation Report: C:\...\openvino_cpp_runtime\INSTALLATION_REPORT.md
```

### 核心 DLL（必須全部存在）

- `openvino_genai.dll` (4.67 MB)
- `openvino.dll` (14.45 MB)
- `openvino_tokenizers.dll` (2.40 MB)
- `openvino_intel_cpu_plugin.dll` (39.72 MB)

### 建議 DLL（應該存在）

- 6 個前端 DLL（IR, ONNX, Paddle, PyTorch, TensorFlow, TFLite）
- 3 個設備插件（CPU, GPU, NPU）
- 4 個依賴庫（ICU, TBB）

## 📁 安裝後的目錄結構

```
openvino_cpp_runtime\
├── bin\                              ← 運行時 DLL 文件（23+ 個）
│   ├── openvino_genai.dll
│   ├── openvino.dll
│   ├── openvino_tokenizers.dll
│   └── ... (其他 DLL)
├── lib\                              ← 開發用函式庫（9 個 .lib）
├── downloads\                        ← 下載的壓縮檔
│   ├── openvino_genai_windows_2025.4.1.0_x86_64.zip
│   └── openvino_genai_windows_2025.4.1.0_x86_64.zip.sha256
├── openvino_genai_windows_2025.4.1.0_x86_64\  ← 解壓內容
│   └── runtime\
└── INSTALLATION_REPORT.md            ← 安裝報告
```

## 🔧 故障排除

### 問題 1：下載失敗

**錯誤信息：**
```
[ERROR] Download failed: ...
```

**解決方案：**
1. 檢查網路連接
2. 確認防火牆設置
3. 手動下載文件並使用 `-SkipDownload`

### 問題 2：SHA256 不匹配

**錯誤信息：**
```
[ERROR] SHA256 checksum mismatch!
```

**解決方案：**
1. 刪除下載的文件
2. 重新執行腳本
3. 或使用 `-SkipHashCheck`（不推薦）

### 問題 3：缺少核心 DLL

**錯誤信息：**
```
[ERROR] Missing core DLLs: ...
```

**解決方案：**
1. 使用 `-ForceReinstall` 重新安裝
2. 檢查解壓是否完整
3. 確認下載文件未損壞

### 問題 4：權限不足

**錯誤信息：**
```
Access denied
```

**解決方案：**
1. 以管理員身份執行 PowerShell
2. 檢查目標目錄的寫入權限

## 💡 最佳實踐

### 首次安裝

```powershell
# 完整安裝（包含所有驗證）
.\scripts\install_openvino_runtime.ps1
```

### 在另一台電腦上安裝

**方案 1：完全自動化**
```powershell
# 複製整個專案到新電腦
# 直接執行
cd openvino-lab
.\scripts\install_openvino_runtime.ps1
```

**方案 2：使用已下載的文件**
```powershell
# 複製專案和 openvino_cpp_runtime\downloads 目錄到新電腦
# 跳過下載步驟
.\scripts\install_openvino_runtime.ps1 -SkipDownload
```

### 離線安裝

```powershell
# 在有網路的電腦上下載
.\scripts\install_openvino_runtime.ps1  # 會在 downloads 目錄產生 zip 文件

# 將整個專案目錄複製到離線電腦
# 在離線電腦上執行
.\scripts\install_openvino_runtime.ps1 -SkipDownload
```

## 📈 性能提示

### 加速安裝

- 使用 `-SkipHashCheck` 可節省 5-10 秒（但不推薦）
- 使用 `-SkipDownload` 當文件已存在時

### 磁碟空間需求

- 下載文件：168.5 MB
- 解壓後：約 500 MB
- bin 目錄：約 150 MB
- **總計：約 800 MB**

## 🔗 相關資源

### 官方文檔

- [OpenVINO GenAI 官方頁面](https://github.com/openvinotoolkit/openvino.genai)
- [OpenVINO 文檔](https://docs.openvino.ai/)
- [版本發布頁面](https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/)

### 項目文檔

- [完整指南](docs/benchmark/README.md)
- [階段 1：下載 Runtime](docs/benchmark/STAGE_1_DOWNLOAD_RUNTIME.md)
- [階段 2：設置環境](docs/benchmark/STAGE_2_SETUP_ENVIRONMENT.md)
- [階段 3：配置腳本](docs/benchmark/STAGE_3_CREATE_SCRIPT.md)
- [階段 4：執行測試](docs/benchmark/STAGE_4_RUN_BENCHMARK.md)

## 📝 版本歷史

### v1.0.0 (2026-01-05)
- ✅ 初始版本
- ✅ 支持 OpenVINO GenAI 2025.4.1.0
- ✅ 完整的自動化安裝流程
- ✅ SHA256 驗證
- ✅ 詳細的安裝報告

---

## ❓ 常見問題

### Q1: 腳本支持哪些 Windows 版本？
**A:** Windows 10/11 (64-bit)

### Q2: 需要管理員權限嗎？
**A:** 通常不需要，除非安裝到受保護的目錄

### Q3: 可以自定義安裝位置嗎？
**A:** 可以，使用 `-InstallRoot` 參數

```powershell
.\scripts\install_openvino_runtime.ps1 -InstallRoot "D:\MyOpenVINO"
```

### Q4: 安裝後如何測試？
**A:** 執行：

```powershell
cd C:\Users\svd\codes\openvino-lab\nvme_dsm_test
.\run_benchmark_with_official_runtime.ps1
```

### Q5: 可以安裝多個版本嗎？
**A:** 可以，為每個版本指定不同的安裝目錄

### Q6: 腳本會修改系統環境變數嗎？
**A:** 不會。所有配置都在本地目錄中

---

**作者：** OpenVINO Lab Project  
**更新日期：** 2026-01-05  
**版本：** 1.0.0
