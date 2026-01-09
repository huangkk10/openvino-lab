# 常用命令參考

此文件收集了 OpenVINO Lab 評估工作中的常用命令，方便快速查閱和執行。

---

## 📋 目錄

1. [RSTCLI 工具命令](#rstcli-工具命令)
2. [NvmePassthroughApp 命令](#nvmepassthroughapp-命令)
3. [Benchmark 命令](#benchmark-命令)
4. [文件系統命令](#文件系統命令)

---

## RSTCLI 工具命令

### 查詢 NVMe 設備 ID

**用途：** 獲取 NVMe 設備的 SCSI 參數，用於後續的 NvmePassthroughApp.exe 配置。

```powershell
# 進入 RSTCLI Tool 目錄
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\4_RSTCLI_tool\RST_PV_20.2.6.1025.3_25H2_24H2_SV2_Win10\CLI\x64

# 執行 RSTCLI 查詢命令，列出所有存儲設備
.\rstcli64.exe -I
```

**預期輸出：**
```
--CONTROLLER INFORMATION--

ID:                     Scsi0
Name:                   Intel(R) RST VMD Controller AD0B \\Scsi0
Type:                   VMD
...

--DEVICE INFORMATION--

ID:                     0-4-0-0
Type:                   Disk
Disk Type:              PCIE SSD
Port Interface:         NVMe
Model:                  Micron_4600_MTFDLBA1T0THJ
...
```

**關鍵信息提取：**
| 字段 | 範例值 | 用途 |
|------|--------|------|
| **ID** | `0-4-0-0` | 完整設備識別符 |
| SCSI | 0 | --scsi 參數值 |
| Path | 4 | --path 參數值 |
| Target | 0 | --target 參數值 |
| LUN | 0 | --lun 參數值 |

**⚠️ 重要提醒：**
- 每個系統的 ID 可能不同（例如：`0-2-0-0`、`0-4-0-0` 等）
- **必須使用您實際系統的 ID 值**，不能硬編碼
- 後續所有 NvmePassthroughApp.exe 命令都依賴這些參數

---

### 查詢 RAID 控制器狀態

```powershell
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\4_RSTCLI_tool\RST_PV_20.2.6.1025.3_25H2_24H2_SV2_Win10\CLI\x64

# 查詢詳細的控制器和設備信息
.\rstcli64.exe -I

# 查詢特定控制器（如果有多個）
.\rstcli64.exe -I scsi0
```

---

## NvmePassthroughApp 命令

### 配置 DSM Hinting 設置

**用途：** 啟用 NVMe DSM Hints 功能，優化 Storage I/O 性能。

```powershell
# 進入 NvmePassthroughApp 工具目錄
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\2_RST_POC_Driver\DSMHint\Tool

# ⚠️ 重要：將下列參數替換為您的實際 ID 值！
# 示例使用 ID: 0-4-0-0 (scsi=0, path=4, target=0, lun=0)
# 如果您的 ID 是 0-2-0-0，則改為 --path 2

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

**參數說明：**

| 參數 | 值 | 說明 |
|------|---|------|
| `--scsi` | 0 | SCSI Controller ID（第一個數字） |
| `--path` | 4 | SCSI Path（第二個數字，常見值：2 或 4） |
| `--target` | 0 | Target ID（第三個數字） |
| `--lun` | 0 | Logical Unit Number（第四個數字） |
| `--enableNvmeHinting` | 1 | 啟用 DSM Hinting (1=啟用, 0=停用) |
| `--userModeHinting` | 1 | 啟用使用者模式提示 |
| `--pageFileHinting` | 0 | 停用分頁檔案提示 |
| `--readHinting` | 1 | **啟用讀取提示**（AI 模型載入時重要） |
| `--writeHinting` | 0 | 停用寫入提示（推理階段寫入極少） |

**為什麼需要 .\ 前綴？**
- PowerShell 安全機制：預設不執行當前目錄的程式
- `.\` 表示「執行當前目錄中的程式」

---

### 為模型目錄新增 DSM 分類

**用途：** 告訴 SSD 某個特定目錄中的文件應該如何優化（讀取密集）。

```powershell
# 進入工具目錄
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\2_RST_POC_Driver\DSMHint\Tool

# ⚠️ 重要：使用您在上一步獲取的實際 ID 值！
.\NvmePassthroughApp.exe `
    --scsi 0 `
    --path 4 `
    --target 0 `
    --lun 0 `
    addDsmClassification `
    --kind 2 `
    --path "C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov"
```

**Kind 類型說明：**
- `0` - Default（預設）
- `1` - Write-intensive（寫入密集）
- `2` - Read-intensive（讀取密集）← **適合 AI 模型**
- `3` - Sequential（連續存取）

**為什麼使用 Kind 2？**
- AI 模型推理主要是讀取操作
- SSD 可以預讀和優化讀取路徑
- 減少首次存取延遲

---

### 停用 DSM Hinting（還原配置）

**用途：** 如果需要還原到未配置狀態。

```powershell
# 進入工具目錄
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\2_RST_POC_Driver\DSMHint\Tool

# ⚠️ 使用您的實際 ID 值
.\NvmePassthroughApp.exe `
    --scsi 0 `
    --path 4 `
    --target 0 `
    --lun 0 `
    configureDsm `
    --enableNvmeHinting 0
```

---

## Benchmark 命令

### 執行 GPU Benchmark（基準測試）

**用途：** 測試 AI 推理性能，測量 Load Time、TTFT、Throughput 等指標。

```powershell
# 進入項目根目錄
cd C:\Users\svd\codes\openvino-lab

# 清除編譯快取（重要！確保重新加載模型）
if (Test-Path ".ccache") {
    Remove-Item -Recurse -Force ".ccache"
    Write-Host "✅ 已清除編譯快取" -ForegroundColor Green
}

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

**參數說明：**

| 參數 | 值 | 說明 |
|------|---|------|
| `-m` | 模型路徑 | AI 模型位置 |
| `-d` | GPU | 使用 GPU 進行推理 |
| `-p` | 提示文本 | 輸入提示詞 |
| `--nw` | 0 | 預填充詞數 |
| `-n` | 1 | 運行次數 |
| `--mt` | 20 | 最大令牌數 |
| `--cache_dir` | `.ccache` | 編譯快取目錄 |

**預期輸出：**
```
OpenVINO Runtime
    Version : 2025.4.1
    Build   : ...

Model: ./models/open_llama_7b_v2-int4-ov
Device: GPU

Load time: 10123 ms
TTFT: 112.62 ms
Throughput: 15.74 t/s
...
```

---

### 執行多次 Benchmark（獲取平均值）

**用途：** 執行多次測試以消除偶然性，獲得更準確的性能數據。

```powershell
# 進入項目根目錄
cd C:\Users\svd\codes\openvino-lab

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

# 儲存所有結果到文件
$results | Out-File -FilePath ".\nvme_dsm_test\benchmark_multiple_runs.txt"
Write-Host "`n✅ 測試完成，結果已保存到 benchmark_multiple_runs.txt" -ForegroundColor Green
```

---

### 執行 Benchmark 並保存結果

**用途：** 在檔案中記錄性能測試結果，便於分析和對比。

```powershell
# 進入項目根目錄
cd C:\Users\svd\codes\openvino-lab

# 清除快取
if (Test-Path ".ccache") {
    Remove-Item -Recurse -Force ".ccache"
}

# 執行測試並將結果保存到文件
& ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    -n 1 `
    --mt 20 `
    --cache_dir ".ccache" | Tee-Object -FilePath ".\nvme_dsm_test\benchmark_result_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').txt"
```

---

## 文件系統命令

### 驗證 OpenVINO PATH 配置

**用途：** 確認 OpenVINO runtime 的 bin 目錄已正確添加到系統 PATH。

```powershell
# 查看 PATH 中是否包含 openvino_cpp_runtime
$env:PATH -split ';' | Where-Object { $_ -like '*openvino_cpp_runtime*' }

# 預期輸出：
# C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin
```

### 檢查虛擬環境狀態

```powershell
# 查看虛擬環境路徑
$env:VIRTUAL_ENV

# 確認已激活虛擬環境
if ($env:VIRTUAL_ENV) {
    Write-Host "✅ 虛擬環境已激活: $env:VIRTUAL_ENV" -ForegroundColor Green
} else {
    Write-Host "❌ 虛擬環境未激活！" -ForegroundColor Red
    Write-Host "   請運行: .\venv\Scripts\Activate.ps1" -ForegroundColor Yellow
}
```

### 驗證模型路徑

```powershell
# 進入項目根目錄
cd C:\Users\svd\codes\openvino-lab

# 檢查模型是否存在
$modelPath = ".\models\open_llama_7b_v2-int4-ov"
if (Test-Path $modelPath) {
    Write-Host "✅ 模型已找到: $modelPath" -ForegroundColor Green
    Get-ChildItem $modelPath | Select-Object Name, Length | Format-Table
} else {
    Write-Host "❌ 模型未找到: $modelPath" -ForegroundColor Red
}
```

### 列出所有 Storage 控制器（Windows WMI）

```powershell
# 列出所有 SCSI 控制器
Get-WmiObject Win32_SCSIController | Format-Table Name, DeviceID, Index

# 查找 VMD 控制器
Get-WmiObject Win32_SCSIController | Where-Object {$_.Name -like "*VMD*"} | Format-List Name, DriverName, Status

# 列出所有物理磁碟
Get-PhysicalDisk | Format-Table FriendlyName, BusType, Size
```

### 監控磁碟空間

```powershell
# 查看磁碟空間使用情況
Get-Volume | Where-Object {$_.DriveLetter} | Format-Table DriveLetter, FileSystemLabel, Size, SizeRemaining

# 查看特定目錄大小
$path = ".\models"
if (Test-Path $path) {
    $size = (Get-ChildItem $path -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1GB
    Write-Host "✅ $path 資料夾大小: $([math]::Round($size, 2)) GB" -ForegroundColor Green
}
```

---

## 快速命令速查表

| 任務 | 命令 |
|------|------|
| 獲取設備 ID | `rstcli64.exe -I` |
| 啟用 DSM | `NvmePassthroughApp.exe ... configureDsm ...` |
| 新增 DSM 分類 | `NvmePassthroughApp.exe ... addDsmClassification ...` |
| 執行 Benchmark | `benchmark_genai.exe -m ... -d GPU ...` |
| 清除快取 | `Remove-Item -Recurse -Force ".ccache"` |
| 驗證 PATH | `$env:PATH -split ';' \| grep openvino` |
| 激活虛擬環境 | `.\venv\Scripts\Activate.ps1` |
| 查看模型 | `Get-ChildItem .\models\*` |

---

## 📌 常見錯誤與解決方案

### 錯誤：找不到 NvmePassthroughApp.exe

**症狀：**
```
The term 'NvmePassthroughApp.exe' is not recognized
```

**解決：** 確保在命令前加上 `.\` 前綴
```powershell
.\NvmePassthroughApp.exe ...  # ✅ 正確
NvmePassthroughApp.exe ...    # ❌ 錯誤
```

### 錯誤：Device not found

**症狀：**
```
Error: Device not found - SCSI 0:2:0:0 not available
```

**解決：** 使用 rstcli64.exe 查詢實際的設備 ID，確保 --path 參數正確

```powershell
# 重新查詢您的設備 ID
rstcli64.exe -I

# 根據輸出調整 --path 參數
# 如果您的 ID 是 0-2-0-0，使用 --path 2
# 如果您的 ID 是 0-4-0-0，使用 --path 4
```

### 錯誤：Benchmark 無輸出（Exit Code: -1073741515）

**症狀：**
```
Exit Code: -1073741515 (0xC0000135)
[無任何輸出]
```

**解決：** 設定 OpenVINO PATH

```powershell
# 臨時設定（此次會話有效）
$env:PATH = "C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin;" + $env:PATH

# 或永久設定（一次設定，永久有效）
[Environment]::SetEnvironmentVariable('PATH', 'C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin;' + [Environment]::GetEnvironmentVariable('PATH', 'User'), 'User')
```

---

## 相關文檔

- [STAGE_7_CONFIGURE_DSM_HINTS.md](./STAGE_7_CONFIGURE_DSM_HINTS.md) - 完整的 DSM Hints 配置指南
- [STAGE_5_RUN_BENCHMARK.md](./STAGE_5_RUN_BENCHMARK.md) - 性能測試完整指南
- [STAGE_6_UPGRADE_STORAGE_DRIVER.md](./STAGE_6_UPGRADE_STORAGE_DRIVER.md) - Storage Driver 升級指南

---

**最後更新：** 2026-01-09  
**版本：** 1.0  
**用途：** 快速參考常用命令

