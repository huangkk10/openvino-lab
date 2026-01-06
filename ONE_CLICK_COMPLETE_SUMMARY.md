# 📊 一鍵執行 Benchmark 方案 - 完整總結

**日期：** 2026-01-06  
**狀態：** ✅ 完成並已驗證

---

## 🎯 方案概述

已建立 **3 種一鍵執行方案**，可根據需求選擇：

| # | 方式 | 檔案 | 啟動方式 | 難度 | 推薦 |
|---|------|------|---------|------|------|
| **A** | 批次檔案 | `run_benchmark.bat` | 雙擊即開 | 最簡 | ⭐⭐⭐ 新手 |
| **B** | PowerShell (完整) | `setup_and_run_benchmark.ps1` | PowerShell 執行 | 中等 | ⭐⭐⭐ 進階 |
| **C** | PowerShell (簡化) | `run_benchmark.ps1` | PowerShell 執行 | 簡 | ⭐⭐ 快速 |

---

## 📁 新建立的文件

### 腳本文件

| 檔名 | 大小 | 說明 | 使用場景 |
|------|------|------|---------|
| `run_benchmark.bat` | 2.4 KB | Windows CMD 批次檔案，可直接雙擊 | 最快、最簡單 |
| `setup_and_run_benchmark.ps1` | 8.3 KB | 完整功能 PowerShell 腳本 | 需要自訂參數、永久設定環境變數 |
| `run_benchmark.ps1` | 1.7 KB | 簡化 PowerShell 腳本 | 快速執行，無多餘功能 |

### 文檔文件

| 檔名 | 說明 |
|------|------|
| `README_BENCHMARK.md` | 快速開始（3 行指令） |
| `ONE_CLICK_QUICK_START.md` | 完整使用指南（含參數、故障排除、進階用法） |
| `BENCHMARK_PATH_FIX_REPORT.md` | 完整的診斷與修復報告 |

### 更新的文件

| 檔名 | 變更 |
|------|------|
| `STAGE_7_CONFIGURE_DSM_HINTS.md` | 新增「問題 6：benchmark_genai.exe 執行後無輸出」 |

---

## ✨ 主要功能

### 功能 1：自動環境變數設定

- **永久設定**：`setup_and_run_benchmark.ps1` 會自動檢測管理員權限
  - 有管理員權限 → 自動設定永久 PATH（Windows 環境變數）
  - 無管理員權限 → 自動設定臨時 PATH（當前會話）

- **臨時設定**：`.bat` 與 `.ps1` 會自動為當前執行設定 PATH

### 功能 2：自動環境檢查

所有腳本都會自動檢查：
- ✅ Benchmark 執行檔是否存在
- ✅ 模型路徑是否存在
- ✅ OpenVINO runtime 是否存在
- ✅ OpenVINO DLL 是否可載入

### 功能 3：參數自訂

`setup_and_run_benchmark.ps1` 支援自訂：
- 執行設備（GPU / CPU）
- 迭代次數
- 最大 token 數
- 自訂提示詞
- 快取目錄

### 功能 4：詳細反饋

所有腳本都提供：
- ✅ 執行步驟提示
- ✅ 成功/失敗狀態
- ✅ 詳細的錯誤訊息
- ✅ 執行時間統計

---

## 🚀 快速開始（選一種）

### 方式 A：最簡單（推薦新手）
```
1. 打開檔案總管
2. 進入 C:\Users\svd\codes\openvino-lab
3. 雙擊 run_benchmark.bat
4. 等待執行完成
```

### 方式 B：PowerShell 完整版（推薦進階用戶）
```powershell
cd C:\Users\svd\codes\openvino-lab
.\setup_and_run_benchmark.ps1                    # 預設參數
.\setup_and_run_benchmark.ps1 -NumIter 3         # 3 次迭代
```

### 方式 C：PowerShell 簡化版
```powershell
cd C:\Users\svd\codes\openvino-lab
.\run_benchmark.ps1
```

---

## 🔧 環境變數設定（可選）

如果要**永久設定**（一次性，之後無需額外操作）：

```powershell
# 以管理員身份執行一次
[Environment]::SetEnvironmentVariable(
    'PATH',
    'C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin;' + [Environment]::GetEnvironmentVariable('PATH', 'User'),
    'User'
)
```

完成後：
- ✅ 新開 PowerShell 自動有效
- ✅ 無需再執行上述命令
- ✅ 任何應用程式都能存取 OpenVINO DLL

---

## 📊 執行流程與檢查點

```
開始
  ↓
[1] 檢查系統環境
    ├─ 檢查 benchmark.exe ✓
    ├─ 檢查模型路徑 ✓
    ├─ 檢查 OpenVINO runtime ✓
  ↓
[2] 設定環境變數
    ├─ 檢查管理員權限
    ├─ 設定永久 PATH (如有權限)
    ├─ 設定會話 PATH (總是)
  ↓
[3] 驗證環境
    ├─ 測試 benchmark --help
    ├─ 確認 OpenVINO DLL 可載入
  ↓
[4] 執行 Benchmark
    ├─ 載入模型
    ├─ 執行推理
    ├─ 輸出性能指標
  ↓
[5] 輸出結果
    ├─ 成功/失敗狀態
    ├─ 執行時間
    ├─ 提示下一步
  ↓
結束
```

---

## 💡 使用建議

### 首次使用
```
推薦：執行 setup_and_run_benchmark.ps1 一次
目的：自動設定永久環境變數
效果：之後無需額外操作
```

### 日常使用
```
推薦：雙擊 run_benchmark.bat
原因：最快、最簡單
備選：使用 PowerShell 版本自訂參數
```

### 故障排除
```
查看：ONE_CLICK_QUICK_START.md 的「故障排除」章節
或：STAGE_7_CONFIGURE_DSM_HINTS.md 的「問題 6」
```

---

## 🧪 已驗證

- ✅ `run_benchmark.bat` - 已直接執行測試
- ✅ `setup_and_run_benchmark.ps1` - 已完整執行測試
- ✅ `run_benchmark.ps1` - 已驗證可用
- ✅ 永久環境變數設定 - 已驗證生效
- ✅ Fresh PowerShell 會話 - 已驗證可直接執行

---

## 📋 檔案清單

### 核心文件
```
C:\Users\svd\codes\openvino-lab\
├── run_benchmark.bat                    [Windows 批次檔案]
├── setup_and_run_benchmark.ps1         [完整 PowerShell]
├── run_benchmark.ps1                   [簡化 PowerShell]
├── quick_benchmark.ps1                 [舊版簡化版]
├── README_BENCHMARK.md                 [快速開始]
├── ONE_CLICK_QUICK_START.md           [詳細指南]
├── BENCHMARK_PATH_FIX_REPORT.md       [診斷報告]
└── nvme_dsm_test/
    ├── benchmark_app/
    │   └── OpenVINO_AI_apps_v01/
    │       └── benchmark_genai.exe
    └── openvino_cpp_runtime/
        └── bin/
            ├── openvino.dll
            └── [其他 OpenVINO DLL...]
```

---

## ✅ 完成清單

- [x] 建立 3 種一鍵執行方案
- [x] 建立完整使用文檔
- [x] 實裝自動環境變數設定
- [x] 實裝自動環境檢查
- [x] 實裝參數自訂功能
- [x] 實裝詳細的使用者反饋
- [x] 測試所有腳本
- [x] 驗證環境變數設定
- [x] 建立故障排除指南
- [x] 建立完整報告文檔

---

## 🎓 進階用法

### 批量執行（N 次迭代）
```powershell
for ($i = 1; $i -le 5; $i++) {
    Write-Host "Run $i/5"
    .\setup_and_run_benchmark.ps1 -NumIter 1 -SkipSetup
    Start-Sleep -Seconds 5
}
```

### 對比 CPU vs GPU
```powershell
.\setup_and_run_benchmark.ps1 -Device GPU
.\setup_and_run_benchmark.ps1 -Device CPU -SkipSetup
```

### 自訂提示詞測試
```powershell
.\setup_and_run_benchmark.ps1 -Prompt "Hello, world!"
.\setup_and_run_benchmark.ps1 -Prompt "What is AI?"
```

---

## 📞 如何尋求幫助

1. **執行失敗？** → 查看螢幕上的錯誤訊息
2. **錯誤代碼？** → 查看 [ONE_CLICK_QUICK_START.md](ONE_CLICK_QUICK_START.md) 的故障排除
3. **詳細資訊？** → 查看 [BENCHMARK_PATH_FIX_REPORT.md](BENCHMARK_PATH_FIX_REPORT.md)
4. **進階功能？** → 編輯腳本的 `param()` 部分自訂參數

---

## 🎉 結論

**現在你可以用 3 種簡單方式執行 benchmark：**

1. ⭐⭐⭐ **最簡單**：`雙擊 run_benchmark.bat`
2. ⭐⭐⭐ **最完整**：`PowerShell 執行 setup_and_run_benchmark.ps1`
3. ⭐⭐ **快速版**：`PowerShell 執行 run_benchmark.ps1`

**所有方案都已驗證可用，選擇任何一種即可！** 🚀

---

**版本：** 1.0  
**最後更新：** 2026-01-06  
**狀態：** ✅ 完成並已驗證
