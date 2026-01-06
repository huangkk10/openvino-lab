# 階段 6：配置 DSM Hints 並測試性能

**目標：** 使用 NvmePassthroughApp.exe 配置 DSM Hints，並測試對 AI Inference 性能的影響  
**前置條件：** 已完成階段 5（已安裝 RST POC Driver 20.2.x）  
**難度：** ⭐⭐⭐⭐ 進階  
**預計時間：** 15-20 分鐘

---

## 📋 概述

本階段將使用 Intel NvmePassthroughApp.exe 工具來：
1. **啟用 NVMe DSM Hints**：配置 Storage I/O 提示機制
2. **新增 DSM 分類**：為 AI 模型目錄設定專屬 I/O 提示
3. **執行性能測試**：測試 DSM Hints 對 AI Inference 的影響
4. **對比分析**：比較不同配置下的性能差異

### 什麼是 DSM Hints？

**DSM (Dataset Management)** 是 NVMe 的一個功能，允許作業系統向 SSD 提供關於資料存取模式的提示：
- **Read Hinting**：告訴 SSD 某些資料即將被頻繁讀取
- **Write Hinting**：提示 SSD 優化寫入策略
- **Sequential vs Random**：提示存取是連續或隨機的

透過 DSM Hints，SSD 可以：
- 預先載入資料到 SSD 快取
- 優化內部資料佈局
- 減少延遲，提升吞吐量

---

## ⚠️ 重要說明

### 何時需要執行此階段

✅ **需要執行：**
- 已完成階段 5（安裝 RST POC Driver）
- 使用 Intel 平台 + VMD Controller + POC SSD
- 需要測試 DSM Hints 對大型 AI 模型載入的影響
- 進行 Intel 硬體性能評估

❌ **不需要執行：**
- 未安裝 RST POC Driver（階段 5 跳過）
- 使用標準 Windows NVMe Driver
- 非 Intel 平台或無 VMD Controller
- 一般性能測試已足夠

### 風險警告

⚠️ **此階段涉及低階 Storage 配置**：
- 錯誤的配置可能影響系統穩定性
- 建議在測試環境執行
- 確保已備份重要資料
- 記錄所有配置變更

---

## 🔧 工具準備

### 6.1 檢查 NvmePassthroughApp.exe

NvmePassthroughApp.exe 通常位於 RST POC Driver 套件中：

```powershell
# 搜尋工具位置
Get-ChildItem -Path ".\evaluation_requirements\2_RST_POC_Driver\" -Recurse -Filter "NvmePassthroughApp.exe"
```

**預期路徑：**
```
evaluation_requirements\2_RST_POC_Driver\DSMHint\Tool\NvmePassthroughApp.exe
```

### 6.2 驗證系統需求

```powershell
# 確認 RST POC Driver 已安裝
Get-WmiObject Win32_SCSIController | Where-Object {$_.Name -like "*VMD*"} | Format-List Name, DriverName, Status
```

**預期輸出：**
```
Name       : Intel(R) RST VMD Controller AD0B
DriverName : iaStorVD
Status     : OK
```

### 6.3 識別 NVMe 設備

```powershell
# 列出所有 NVMe 設備
Get-PhysicalDisk | Where-Object {$_.BusType -eq "NVMe"} | Format-Table DeviceId, FriendlyName, Size
```

**記錄設備參數：**
- SCSI ID
- Path
- Target
- LUN

---

## 📝 階段步驟

### 步驟 6.1：使用 RSTCLI 獲取 NVMe 設備 ID

在配置 DSM Hints 之前，我們需要先確認 NVMe 設備的 SCSI 參數。這些參數將用於 NvmePassthroughApp.exe 的命令中。

#### 6.1.1 進入 RSTCLI Tool 目錄

```powershell
# 進入 RSTCLI Tool 目錄
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\4_RSTCLI_tool\RST_PV_20.2.6.1025.3_25H2_24H2_SV2_Win10\CLI\x64

# 確認工具存在
if (Test-Path ".\rstcli64.exe") {
    Write-Host "✅ rstcli64.exe 已找到" -ForegroundColor Green
} else {
    Write-Host "❌ 找不到 rstcli64.exe！" -ForegroundColor Red
    Write-Host "   請確認 RSTCLI 工具已正確解壓縮" -ForegroundColor Yellow
    exit 1
}
```

#### 6.1.2 檢查 RAID 控制器資訊

```powershell
# 執行 RSTCLI 查詢命令（注意：必須加上 .\ 前綴）
.\rstcli64.exe -I
```

**預期輸出範例：**
```
--CONTROLLER INFORMATION--

ID:                     Scsi0
Name:                   Intel(R) RST VMD Controller AD0B \\Scsi0
Type:                   VMD
Supported RAID:         0,1,5,10
...

--END DEVICE INFORMATION--

ID:                     0-4-0-0
Type:                   Disk
Disk Type:              PCIE SSD
Port Interface:         NVMe
Bus Width:              X4
Bus Speed:              GEN5
...
Model:                  Micron_4600_MTFDLBA1T0THJ
...
```

#### 6.1.3 記錄設備 ID 參數

**關鍵資訊：**
從輸出中找到 `ID:` 欄位，格式為 `SCSI-PATH-TARGET-LUN`

**範例解析：**
```
ID: 0-4-0-0
    ↓ ↓ ↓ ↓
    │ │ │ └─ LUN = 0
    │ │ └─── Target = 0
    │ └───── Path = 4
    └─────── SCSI = 0
```

**記錄您的設備 ID：**
```powershell
# 從 rstcli64.exe 輸出中找到您的設備 ID
# 例如：0-4-0-0
#
# 記錄下來，將用於後續 NvmePassthroughApp.exe 命令中的參數：
#   --scsi 0     (第一個數字)
#   --path 4     (第二個數字)
#   --target 0   (第三個數字)
#   --lun 0      (第四個數字)
```

**⚠️ 重要提醒：**
- 不同系統的 ID 可能不同（例如：0-2-0-0、0-4-0-0 等）
- **必須使用您實際系統的 ID 值**
- Path 值最常見的是 2 或 4（取決於 PCIe 配置）
- 後續所有 NvmePassthroughApp.exe 命令都必須使用這些參數

#### 6.1.4 驗證其他關鍵資訊

同時記錄以下資訊以便後續參考：

```powershell
# 從 rstcli64.exe 輸出中確認：
# - Controller Name: Intel(R) RST VMD Controller AD0B
# - Disk Type: PCIE SSD
# - Port Interface: NVMe
# - Bus Speed: GEN5 (或 GEN4)
# - Model: 您的 SSD 型號
```

**範例記錄表格：**

| 項目 | 值 | 說明 |
|------|---|------|
| **設備 ID** | 0-4-0-0 | 從 rstcli64.exe 輸出獲取 |
| SCSI | 0 | 用於 `--scsi` 參數 |
| Path | 4 | 用於 `--path` 參數 |
| Target | 0 | 用於 `--target` 參數 |
| LUN | 0 | 用於 `--lun` 參數 |
| Controller | Intel(R) RST VMD Controller AD0B | 確認控制器型號 |
| SSD Model | Micron_4600_MTFDLBA1T0THJ | 確認 SSD 型號 |
| Bus Speed | GEN5 | 確認 PCIe 世代 |

---

### 步驟 6.2：定位 NvmePassthroughApp.exe

```powershell
# 進入工具目錄
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\2_RST_POC_Driver\DSMHint\Tool
```

**驗證工具存在：**
```powershell
if (Test-Path ".\NvmePassthroughApp.exe") {
    Write-Host "✅ NvmePassthroughApp.exe 已找到" -ForegroundColor Green
    Get-Item ".\NvmePassthroughApp.exe" | Format-List Name, Length, LastWriteTime
} else {
    Write-Host "❌ 工具未找到！" -ForegroundColor Red
}
```

**⚠️ 重要提示：**
- PowerShell 預設不會自動執行當前目錄的程式
- 執行本目錄的程式需要在命令前加上 `.\` 前綴
- 例如：`.\NvmePassthroughApp.exe` 而非 `NvmePassthroughApp.exe`

---

### 步驟 6.3：執行基準測試（Before DSM Configuration）

在配置 DSM Hints 前，先執行基準測試：

```powershell
# 返回專案根目錄
cd C:\Users\svd\codes\openvino-lab

# 執行 GPU 測試（使用 cache_dir）
& ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    -n 1 `
    --mt 20 `
    --cache_dir ".ccache"
```

**記錄關鍵指標：**
- Load Time
- TTFT
- Throughput

**儲存結果：**
```powershell
# 將結果儲存到文件
& ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    -n 1 `
    --mt 20 `
    --cache_dir ".ccache" | Tee-Object -FilePath ".\nvme_dsm_test\benchmark_before_dsm_config.txt"
```

---

### 步驟 6.4：配置 DSM Hints

#### 6.4.1 啟用 NVMe Hinting

此命令啟用 DSM Hints 功能並配置提示參數：

```powershell
# 進入工具目錄（如果還沒進入）
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\2_RST_POC_Driver\DSMHint\Tool

# ⚠️ 重要：使用您在步驟 6.1 中記錄的實際 ID 值！
# 以下範例使用 ID: 0-4-0-0，請根據您的系統調整

# 執行配置命令（注意：命令前必須加上 .\ 前綴）
.\NvmePassthroughApp.exe `
    --scsi 0 `
    --path 4 `
    --target 0 `
    --lun 0 `
    configureDsm `
    --enableNvmeHinting 1 `
    --userModeHinting 1 `
    --pageFileHinting 0 `
    --readHinting 1 `
    --writeHinting 0
```

**⚠️ 常見錯誤：**

❌ **錯誤做法：**
```powershell
NvmePassthroughApp.exe --scsi 0 --path 2 ...
# 會出現: "The term 'NvmePassthroughApp.exe' is not recognized"
```

✅ **正確做法：**
```powershell
.\NvmePassthroughApp.exe --scsi 0 --path 2 ...
# 注意前面的 .\ 前綴
```

**為什麼需要 .\ 前綴？**
- PowerShell 的安全機制：預設不執行當前目錄的程式
- 必須顯式指定執行當前目錄（`.`）的程式
- `.\` = 當前目錄（`.`）+ 執行運算符（`\`）

**參數說明：**

| 參數 | 值 | 說明 |
|------|---|------|
| `--scsi` | 0 | SCSI Controller ID（從步驟 6.1 獲取） |
| `--path` | 4 | SCSI Path（從步驟 6.1 獲取，常見值：2 或 4） |
| `--target` | 0 | Target ID（從步驟 6.1 獲取） |
| `--lun` | 0 | Logical Unit Number（從步驟 6.1 獲取） |
| `--enableNvmeHinting` | 1 | 啟用 NVMe Hinting (1=啟用, 0=停用) |
| `--userModeHinting` | 1 | 啟用使用者模式 Hinting |
| `--pageFileHinting` | 0 | 停用 Page File Hinting |
| `--readHinting` | 1 | **啟用讀取提示**（重要！） |
| `--writeHinting` | 0 | 停用寫入提示 |

**⚠️ 關鍵提醒：**
- `--scsi`, `--path`, `--target`, `--lun` 的值必須與您在步驟 6.1 中記錄的設備 ID 一致
- 如果您的設備 ID 是 `0-2-0-0`，則 `--path` 應該是 `2`
- 如果您的設備 ID 是 `0-4-0-0`，則 `--path` 應該是 `4`
- 使用錯誤的參數會導致 "Device not found" 錯誤

**為什麼這樣配置？**
- **readHinting=1**：AI 模型載入主要是讀取操作
- **writeHinting=0**：Inference 階段寫入極少
- **userModeHinting=1**：應用程式可以使用 DSM Hints API
- **pageFileHinting=0**：不影響系統分頁檔

**預期輸出：**
```
NVMe Passthrough Application
Configuring DSM settings...
✓ DSM Configuration successful
```

#### 6.4.2 新增 DSM 分類（為模型目錄）

此命令為 AI 模型目錄建立專屬的 DSM 分類：

```powershell
# 確認模型路徑
$modelPath = "C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov"

# ⚠️ 重要：使用您在步驟 6.1 中記錄的實際 ID 值！
# 以下範例使用 ID: 0-4-0-0，請根據您的系統調整

# 新增 DSM 分類（注意：命令前必須加上 .\ 前綴）
.\NvmePassthroughApp.exe `
    --scsi 0 `
    --path 4 `
    --target 0 `
    --lun 0 `
    addDsmClassification `
    --kind 2 `
    --path "C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov"
```

**同樣需要 .\ 前綴**
- 所有執行 NvmePassthroughApp.exe 的命令都必須以 `.\` 開頭
- 這是 PowerShell 的安全要求

**參數說明：**

| 參數 | 值 | 說明 |
|------|---|------|
| `addDsmClassification` | - | 新增 DSM 分類規則 |
| `--kind` | 2 | 分類類型（2 = 頻繁讀取的資料） |
| `--path` | 模型路徑 | 要套用 DSM Hints 的目錄 |

**Kind 類型說明：**
- `0` - Default（預設）
- `1` - Write-intensive（寫入密集）
- `2` - Read-intensive（讀取密集）← 適合 AI 模型
- `3` - Sequential（連續存取）

**預期輸出：**
```
NVMe Passthrough Application
Adding DSM Classification...
Path: C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov
Kind: 2 (Read-intensive)
✓ DSM Classification added successfully
```

---

### 步驟 6.5：驗證配置

```powershell
# 檢查 DSM 配置（如果工具支援）
# ⚠️ 使用您在步驟 6.1 中記錄的實際 ID 值
.\NvmePassthroughApp.exe --scsi 0 --path 4 --target 0 --lun 0 queryDsm
```

**手動驗證：**
1. 檢查事件檢視器（Event Viewer）
2. 查看 Intel RST 相關日誌
3. 確認無錯誤訊息

---

### 步驟 6.6：執行測試（After DSM Configuration）

現在重新執行相同的 benchmark 測試：

```powershell
# 返回專案根目錄
cd C:\Users\svd\codes\openvino-lab

# 清除編譯快取（重要！）
if (Test-Path ".ccache") {
    Remove-Item -Recurse -Force ".ccache"
    Write-Host "✅ 已清除編譯快取" -ForegroundColor Green
}

# 執行測試
& ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    -n 1 `
    --mt 20 `
    --cache_dir ".ccache" | Tee-Object -FilePath ".\nvme_dsm_test\benchmark_after_dsm_config.txt"
```

**為什麼要清除快取？**
- 確保模型從 Storage 重新載入
- 測試 DSM Hints 對實際 I/O 的影響
- 避免快取命中影響結果

---

### 步驟 6.7：多次測試取平均值

為了獲得更準確的結果，建議執行多次測試：

```powershell
# 執行 5 次測試
$results = @()
for ($i = 1; $i -le 5; $i++) {
    Write-Host "`n=== 測試 $i/5 ===" -ForegroundColor Cyan
    
    # 清除快取
    if (Test-Path ".ccache") {
        Remove-Item -Recurse -Force ".ccache"
    }
    
    # 執行測試
    $output = & ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" `
        -m ".\models\open_llama_7b_v2-int4-ov" `
        -d GPU `
        -p "The Sky is blue because" `
        --nw 0 `
        -n 1 `
        --mt 20 `
        --cache_dir ".ccache"
    
    # 儲存結果
    $results += $output
    
    # 等待 5 秒
    Start-Sleep -Seconds 5
}

# 儲存所有結果
$results | Out-File -FilePath ".\nvme_dsm_test\benchmark_dsm_multiple_runs.txt"
```

---

## 📊 性能分析

### 6.8 比較測試結果

創建性能對比表格：

```powershell
Write-Host "`n=== 性能對比 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "階段 5 (After Driver Upgrade):"
Write-Host "  Load Time: 10123 ms"
Write-Host "  TTFT: 112.62 ms"
Write-Host "  Throughput: 15.74 t/s"
Write-Host ""
Write-Host "階段 6 (After DSM Configuration):"
Write-Host "  Load Time: [待記錄]"
Write-Host "  TTFT: [待記錄]"
Write-Host "  Throughput: [待記錄]"
Write-Host ""
Write-Host "變化："
Write-Host "  Load Time: [計算差異]"
Write-Host "  TTFT: [計算差異]"
Write-Host "  Throughput: [計算差異]"
```

---

## 🔄 還原配置（如需要）

### 停用 DSM Hints

如果需要還原到未配置狀態：

```powershell
# 進入工具目錄
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\2_RST_POC_Driver\DSMHint\Tool

# 停用 NVMe Hinting（注意：命令前必須加上 .\ 前綴）
# ⚠️ 使用您在步驟 6.1 中記錄的實際 ID 值
.\NvmePassthroughApp.exe `
    --scsi 0 `
    --path 4 `
    --target 0 `
    --lun 0 `
    configureDsm `
    --enableNvmeHinting 0
```

### 移除 DSM 分類

```powershell
# 進入工具目錄
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\2_RST_POC_Driver\DSMHint\Tool

# 如果工具支援移除功能（注意：命令前必須加上 .\ 前綴）
# ⚠️ 使用您在步驟 6.1 中記錄的實際 ID 值
.\NvmePassthroughApp.exe `
    --scsi 0 `
    --path 4 `
    --target 0 `
    --lun 0 `
    removeDsmClassification `
    --path "C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov"
```

---

## 🛠️ 故障排除

### 問題 1：找不到 NvmePassthroughApp.exe

**症狀：**
```
The term 'NvmePassthroughApp.exe' is not recognized as the name of a cmdlet, function, script file, or operable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
```

**根本原因：**
- PowerShell 安全機制：預設不執行當前目錄的程式
- 需要使用 `.\` 前綴明確指定當前目錄

**解決方法：**

❌ **錯誤的做法：**
```powershell
NvmePassthroughApp.exe --scsi 0 --path 2 ...
```

✅ **正確的做法：**
```powershell
.\NvmePassthroughApp.exe --scsi 0 --path 2 ...
#  ^^
#  這個 .\ 前綴很重要！
```

**詳細步驟：**
1. 進入工具目錄：`cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\2_RST_POC_Driver\DSMHint\Tool`
2. 驗證工具存在：`dir NvmePassthroughApp.exe`（應該看到檔案）
3. 執行時加上 `.\` 前綴：`.\NvmePassthroughApp.exe ...`

**為什麼？**
- `.` 表示當前目錄
- `\` 是執行運算符
- `.\` 一起表示「執行當前目錄中的程式」
- 這是 PowerShell 的安全設計，防止意外執行惡意程式

---

### 問題 2：Access Denied 錯誤

**症狀：**
```
Error: Access Denied
Unable to configure DSM settings
```

**解決方法：**
1. **以管理員身份執行 PowerShell**
2. 確認 RST POC Driver 正確安裝
3. 檢查 VMD Controller 狀態

```powershell
# 檢查是否為管理員
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "✅ 已有管理員權限" -ForegroundColor Green
} else {
    Write-Host "❌ 需要管理員權限！" -ForegroundColor Red
}
```

---

### 問題 3：無法識別設備

**症狀：**
```
Error: Device not found
SCSI 0:2:0:0 not available
```

**解決方法：**

**1. 確認使用正確的設備 ID（最重要！）**

```powershell
# 返回步驟 6.1，重新執行 RSTCLI 查詢
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\4_RSTCLI_tool\RST_PV_20.2.6.1025.3_25H2_24H2_SV2_Win10\CLI\x64
.\rstcli64.exe -I

# 仔細檢查輸出中的 "ID:" 欄位
# 例如：0-4-0-0 或 0-2-0-0
```

**2. 根據實際 ID 調整參數**

```powershell
# 如果您的 ID 是 0-2-0-0，使用：
.\NvmePassthroughApp.exe --scsi 0 --path 2 --target 0 --lun 0 ...

# 如果您的 ID 是 0-4-0-0，使用：
.\NvmePassthroughApp.exe --scsi 0 --path 4 --target 0 --lun 0 ...
```

**3. 列出所有 Storage Controllers（補充驗證）**

```powershell
# 列出所有 Storage Controllers
Get-WmiObject Win32_SCSIController | Format-Table Name, DeviceID, Index
```

**4. 使用診斷命令（如果工具支援）**

```powershell
# 嘗試掃描可用設備
.\NvmePassthroughApp.exe --scan
```

**常見的 Path 值：**
- `--path 2`：常見於 PCIe x4 配置
- `--path 4`：常見於某些 VMD 配置
- 必須與 `rstcli64.exe -I` 輸出的 ID 第二個數字一致

---

### 問題 4：配置後性能反而下降

**可能原因：**
1. **快取未清除**：舊的編譯快取影響結果
2. **配置不當**：DSM 參數不適合此場景
3. **系統資源競爭**：背景程式影響測試

**解決方法：**

```powershell
# 完全清除所有快取
Remove-Item -Recurse -Force ".ccache" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ".\nvme_dsm_test\compiled_cache" -ErrorAction SilentlyContinue

# 重新啟動系統
Write-Host "建議重新啟動系統後再測試" -ForegroundColor Yellow
```

---

### 問題 5：benchmark_genai.exe 找不到模型

**症狀：**
```
Error: Model path not found
```

**解決方法：**

```powershell
# 使用絕對路徑
$modelPath = "C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov"

# 確認路徑存在
if (Test-Path $modelPath) {
    Write-Host "✅ 模型路徑正確" -ForegroundColor Green
} else {
    Write-Host "❌ 模型路徑錯誤！" -ForegroundColor Red
}

# 使用絕對路徑執行
& "C:\Users\svd\codes\openvino-lab\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" `
    -m $modelPath `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    -n 1 `
    --mt 20 `
    --cache_dir "C:\Users\svd\codes\openvino-lab\.ccache"
```

---

### 問題 6：benchmark_genai.exe 執行後無輸出（Exit Code: -1073741515）

**症狀：**
```
Exit Code: -1073741515 (0xC0000135)
[無任何輸出]
```

**根本原因：**
- DLL 載入失敗：`$env:PATH` 未包含 OpenVINO runtime 的 bin 目錄
- Windows 無法找到 `openvino.dll` 等必要的依賴庫
- Exit Code `-1073741515` (0xC0000135) 是 Windows 標準的「DLL 未找到」錯誤

**解決方法（3 種）：**

#### **方法 6.1：臨時設定 PATH（每次執行時）**

```powershell
# 在執行 benchmark 前，設定 PATH
$env:PATH = "C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin;" + $env:PATH

# 然後執行 benchmark
& ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    -n 1 `
    --mt 20 `
    --cache_dir ".ccache"
```

#### **方法 6.2：使用 Wrapper 腳本（推薦）**

建立 `.\scripts\benchmark\run_benchmark.ps1`，自動設定 PATH：

```powershell
# 設定 OpenVINO runtime path
$env:PATH = "C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin;" + $env:PATH

# 執行 benchmark
& ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    -n 1 `
    --mt 20 `
    --cache_dir ".ccache"
```

執行：
```powershell
cd C:\Users\svd\codes\openvino-lab
.\scripts\benchmark\run_benchmark.ps1
```

#### **方法 6.3：永久設定 Windows 環境變數（推薦）** ✅ **已執行**

```powershell
# 以管理員身份執行 PowerShell，然後執行以下命令：
[Environment]::SetEnvironmentVariable('PATH', 'C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin;' + [Environment]::GetEnvironmentVariable('PATH', 'User'), 'User')
Write-Host "✅ OpenVINO path added to user PATH permanently" -ForegroundColor Green
```

**狀態：** ✅ 已在本系統執行，無需重新啟動 PowerShell

**優點：**
- 一次設定，永久生效
- 所有 PowerShell 會話自動使用
- 新開的 PowerShell 無需額外操作
- 其他應用程式也能使用 OpenVINO

**驗證方法：**
```powershell
# 重新啟動 PowerShell 或重新開啟新 PowerShell 視窗，然後執行：
$env:PATH -split ';' | Where-Object { $_ -like '*openvino_cpp_runtime*' }

# 應該看到輸出：
# C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin
```

**測試：**
```powershell
# 方法 6.3 設定後，直接執行（無需額外 PATH 設定）
cd C:\Users\svd\codes\openvino-lab
& ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    -n 1 `
    --mt 20 `
    --cache_dir ".ccache"

# 預期輸出：
# OpenVINO Runtime
#     Version : 2025.4.1
#     Build   : ...
# Load time: xxxx ms
# ...
```

---

## 📈 預期結果

### 理論上的改善

根據 Intel 文件，配置 DSM Hints 後應該觀察到：

| 指標 | 預期改善 | 原因 |
|------|---------|------|
| **Load Time** | 5-15% | SSD 預讀模型檔案 |
| **TTFT** | 10-25% | 減少首次存取延遲 |
| **Throughput** | 0-5% | 主要影響載入階段 |

### 實際影響因素

改善程度取決於：
- ✅ **模型大小**：越大的模型改善越明顯（7B+ 效果較好）
- ✅ **Storage 類型**：PCIe Gen4/Gen5 NVMe SSD
- ✅ **快取狀態**：冷啟動場景改善最明顯
- ✅ **系統負載**：背景 I/O 較少時效果較好

---

## 🎯 成功標準

完成本階段後，您應該：

- ✅ 成功執行 NvmePassthroughApp.exe 配置命令
- ✅ 為模型目錄新增 DSM 分類（Kind 2）
- ✅ 執行 Before/After 性能測試
- ✅ 記錄並分析性能差異
- ✅ 生成詳細的測試報告

---

## 📝 測試報告範本

建議創建以下報告：

```markdown
# Stage 6: DSM Hints 配置測試報告

## 配置資訊
- Driver: RST POC Driver 20.2.0.8335
- Tool: NvmePassthroughApp.exe
- Model: OpenLLaMA 7B v2 INT4
- Device: GPU

## DSM 配置
- enableNvmeHinting: 1
- userModeHinting: 1
- readHinting: 1
- writeHinting: 0
- Classification Kind: 2 (Read-intensive)
- Classified Path: models\open_llama_7b_v2-int4-ov

## 性能結果
| 指標 | Before | After | 變化 |
|------|--------|-------|------|
| Load Time | ... | ... | ... |
| TTFT | ... | ... | ... |
| Throughput | ... | ... | ... |

## 結論
[記錄觀察結果和分析]
```

---

## 🔗 相關資源

### 內部文檔
- [階段 6：升級 Storage Driver](STAGE_6_UPGRADE_STORAGE_DRIVER.md)
- [階段 5：執行性能測試](STAGE_5_RUN_BENCHMARK.md)
- [完整流程概覽](README.md)

### Intel 官方資源
- Intel RST Documentation
- NVMe DSM Specification
- VMD Controller Technical Guide

---

## ✅ 檢查清單

執行前確認：
- [ ] 已完成階段 5（RST POC Driver 已安裝）
- [ ] **已使用 rstcli64.exe 獲取設備 ID（步驟 6.1）**
- [ ] **已記錄 SCSI、Path、Target、LUN 參數值**
- [ ] NvmePassthroughApp.exe 已定位
- [ ] 以管理員身份執行 PowerShell
- [ ] 已備份重要資料
- [ ] 已記錄當前性能基準
- [x] ✅ OpenVINO PATH 已永久設定（2026-01-06 已執行方式 6.3）

執行後確認：
- [ ] DSM Hinting 已啟用
- [ ] 模型目錄已新增 DSM 分類
- [ ] 已執行 Before/After 測試
- [ ] 已記錄性能數據
- [ ] 已生成測試報告
- [x] ✅ benchmark_genai.exe 能正常執行並輸出性能指標

---

**創建日期：** 2026-01-02  
**前置階段：** Stage 5 (Storage Driver Upgrade)  
**下一階段：** 性能分析與最佳化  
**狀態：** ✅ 就緒
