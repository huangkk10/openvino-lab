# 階段 5：升級 Storage Driver（可選）

**目標：** 升級到 Intel RST POC Driver 以支援 DSM Hints 功能  
**時間：** 10-15 分鐘  
**難度：** ⭐⭐⭐ 進階  
**狀態：** ✅ 已驗證  
**必要性：** ⚠️ **僅用於 DSM Hints 性能測試**

---

## 📋 本階段目標

1. 了解 RST POC Driver 的作用
2. 檢查系統硬體需求
3. 升級 Storage Driver
4. 驗證 Driver 安裝成功
5. 測試 DSM Hints 功能

---

## ⚠️ 重要說明

### 何時需要執行此階段？

✅ **需要執行的情況：**
- 測試 Intel RST DSM Hints 對 TTFT 性能的影響
- 使用支援 DSM Hints 的 POC SSD
- 系統有 Intel VMD (Volume Management Device) Controller
- 進行 Intel 平台的性能評估

❌ **不需要執行的情況：**
- 只是一般的 OpenVINO GenAI 性能測試
- 系統不是 Intel 平台（如 ARL-H）
- 沒有 VMD Controller 或 POC SSD
- 只關心 CPU/GPU 性能，不關心 Storage I/O

### 什麼是 DSM Hints？

**DSM (Dataset Management)** 是一種 NVMe 指令，允許主機向 SSD 提供資料存取模式的提示：
- **Sequential Read Hint** - 告訴 SSD 資料將被順序讀取
- **Random Read Hint** - 告訴 SSD 資料將被隨機讀取
- 可優化 SSD 預取策略，減少延遲

**對 AI 推理的影響：**
- 模型載入時間可能減少
- 首 Token 時間（TTFT）可能改善
- 特別是大型模型（> 4GB）受益明顯

---

## 🔍 系統需求檢查

### 步驟 5.1：檢查硬體平台

```powershell
# 檢查 CPU 型號
Get-WmiObject Win32_Processor | Select-Object Name, Description

# 檢查是否為 Intel 平台
$cpu = Get-WmiObject Win32_Processor
if ($cpu.Name -match "Intel") {
    Write-Host "✅ Intel 平台" -ForegroundColor Green
} else {
    Write-Host "❌ 非 Intel 平台，不建議繼續" -ForegroundColor Red
}
```

**預期輸出：**
```
Name                                    Description
----                                    -----------
Intel(R) Core(TM) i7-xxxxx              Intel64 Family 6 Model xxx
✅ Intel 平台
```

---

### 步驟 5.2：檢查 VMD Controller 狀態

```powershell
# 檢查 VMD 設備
Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Volume Management*"} | Format-Table FriendlyName, Status

# 或使用 Device Manager
devmgmt.msc
```

**預期結果：**
- 在裝置管理員中應該看到 "Intel Volume Management Device"
- 狀態應該為 "OK" 或 "正常運作"

**如果找不到 VMD：**
1. 進入 BIOS/UEFI 設置
2. 找到 "VMD Setup Options" 或 "Intel VMD"
3. 設置為 **Enabled**
4. 保存並重啟

---

### 步驟 5.3：檢查當前 Storage Driver

```powershell
# 檢查 Storage Controller 和 Driver
Get-WmiObject Win32_SCSIController | Format-List Caption, DriverName, DriverVersion

# 檢查 NVMe 裝置
Get-PhysicalDisk | Format-Table FriendlyName, MediaType, BusType, Size
```

**預期輸出：**
```
Caption       : Intel(R) Volume Management Device NVMe RAID Controller
DriverName    : iaStorVD
DriverVersion : 20.x.x.xxxx

FriendlyName          MediaType BusType        Size
------------          --------- -------        ----
NVMe SSD              SSD       NVMe     512110190592
```

---

## 🚀 Driver 升級步驟

### 步驟 5.4：備份當前系統

⚠️ **重要：** 升級 Storage Driver 有風險，請先備份！

```powershell
# 創建系統還原點
Checkpoint-Computer -Description "Before RST Driver Upgrade" -RestorePointType MODIFY_SETTINGS

Write-Host "✅ 系統還原點已創建" -ForegroundColor Green
```

---

### 步驟 5.5：啟用 Windows 測試模式

⚠️ **關鍵步驟：** 由於 RST POC Driver 可能未經 Microsoft 正式簽署，需要啟用測試模式才能安裝。

#### 檢查當前測試模式狀態

```powershell
# 檢查測試簽名狀態
bcdedit /enum | Select-String "testsigning"
```

**預期輸出（未啟用）：**
```
testsigning             No
```

#### 啟用測試模式

```powershell
# 必須以管理員身份執行 PowerShell

# 1. 啟用測試簽名模式
bcdedit /set testsigning on

# 2. 確認設置成功
bcdedit /enum | Select-String "testsigning"
```

**預期輸出（已啟用）：**
```
testsigning             Yes
The operation completed successfully.
```

#### 重新啟動系統

```powershell
# 重啟以應用測試模式
Write-Host "`n⚠️  需要重新啟動以啟用測試模式" -ForegroundColor Yellow
$restart = Read-Host "是否立即重啟？(Y/N)"
if ($restart -eq "Y") {
    Restart-Computer
}
```

**重啟後驗證：**
- 開機後桌面右下角會顯示 "測試模式" 或 "Test Mode" 浮水印
- 這是正常現象，表示測試模式已啟用

#### 測試模式說明

**測試模式的作用：**
- ✅ 允許安裝未經 Microsoft 數位簽章的驅動程式
- ✅ 用於開發和測試階段的驅動程式
- ✅ Intel POC (Proof of Concept) Driver 通常需要此模式

**安全考量：**
- ⚠️ 測試模式會降低系統安全性
- ⚠️ 僅用於測試環境，不建議在生產環境使用
- ⚠️ 完成測試後可關閉測試模式（見下方說明）

**完成測試後關閉測試模式：**
```powershell
# 關閉測試簽名模式（完成所有測試後執行）
bcdedit /set testsigning off

# 重新啟動
Restart-Computer
```

---

### 步驟 5.6：準備 Driver 文件

```powershell
# 進入 Driver 目錄
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\2_RST_POC_Driver\DSMHint\Driver

# 列出 Driver 文件
dir

# 驗證必要文件存在
$requiredFiles = @("iaStorVD.sys", "iaStorVD.inf", "iaStorVD.cat")
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file 存在" -ForegroundColor Green
    } else {
        Write-Host "❌ $file 缺失" -ForegroundColor Red
    }
}
```

**預期輸出：**
```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----                                     xxxxx  iaStorVD.cat
-a----                                     xxxxx  iaStorVD.inf
-a----                                     xxxxx  iaStorVD.sys

✅ iaStorVD.sys 存在
✅ iaStorVD.inf 存在
✅ iaStorVD.cat 存在
```

---

### 步驟 5.7：安裝 Driver（方法 1：Device Manager）

#### 使用裝置管理員安裝

1. **開啟裝置管理員：**
```powershell
devmgmt.msc
```

2. **找到 Storage Controller：**
   - 展開 "Storage controllers"
   - 找到 "Intel(R) Volume Management Device NVMe RAID Controller"

3. **更新 Driver：**
   - 右鍵點擊控制器
   - 選擇 "Update driver"（更新驅動程式）
   - 選擇 "Browse my computer for drivers"（瀏覽我的電腦以尋找驅動程式）
   - 輸入路徑：`C:\Users\svd\codes\openvino-lab\evaluation_requirements\2_RST_POC_Driver\DSMHint\Driver`
   - 點擊 "Next"

4. **確認安裝：**
   - Windows 會顯示驅動程式更新進度
   - 成功後會顯示 "Windows has successfully updated your drivers"

5. **重新啟動：**
```powershell
Restart-Computer -Confirm
```

---

### 步驟 5.8：安裝 Driver（方法 2：PowerShell 命令）

```powershell
# 需要以管理員身份執行 PowerShell

# 1. 進入 Driver 目錄
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\2_RST_POC_Driver\DSMHint\Driver

# 2. 使用 pnputil 安裝 Driver
pnputil /add-driver iaStorVD.inf /install

# 3. 檢查安裝狀態
Write-Host "`n檢查 Driver 安裝狀態..." -ForegroundColor Cyan
Get-WmiObject Win32_PnpSignedDriver | Where-Object {$_.DeviceName -like "*Volume Management*"} | Format-Table DeviceName, DriverVersion, Manufacturer

# 4. 重新啟動系統
Write-Host "`n⚠️  需要重新啟動系統以完成 Driver 安裝" -ForegroundColor Yellow
$restart = Read-Host "是否立即重啟？(Y/N)"
if ($restart -eq "Y") {
    Restart-Computer
}
```

**預期輸出：**
```
Microsoft PnP Utility

Processing inf : iaStorVD.inf
Successfully installed the driver on a device on the system.
Driver package added successfully.
Published Name:     oem123.inf

Total driver packages:  1
Added driver packages:  1

DeviceName                                           DriverVersion   Manufacturer
----------                                           -------------   ------------
Intel(R) Volume Management Device NVMe RAID Controller 20.2.x.xxxx   Intel

⚠️  需要重新啟動系統以完成 Driver 安裝
```

---

## ✅ 驗證 Driver 安裝

### 步驟 5.9：重啟後驗證

重新啟動系統後，執行以下檢查：

```powershell
# 1. 檢查 Driver 版本 (推薦方法)
Write-Host "=== 檢查 Storage Driver 版本 ===" -ForegroundColor Cyan
Get-WmiObject Win32_PnpSignedDriver | Where-Object {$_.DeviceName -like "*VMD*"} | Select-Object DeviceName, DriverVersion, Manufacturer

# 2. 檢查 Driver 文件
Write-Host "`n=== 檢查 Driver 文件 ===" -ForegroundColor Cyan
Get-ChildItem "$env:SystemRoot\System32\drivers\iaStorVD.sys" | Format-Table Name, Length, LastWriteTime

# 3. 檢查裝置狀態
Write-Host "`n=== 檢查裝置狀態 ===" -ForegroundColor Cyan
Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Volume Management*"} | Format-Table FriendlyName, Status, InstanceId

# 4. 檢查磁碟健康狀態
Write-Host "`n=== 檢查磁碟狀態 ===" -ForegroundColor Cyan
Get-PhysicalDisk | Format-Table FriendlyName, HealthStatus, OperationalStatus, Size
```

### 完整驗證步驟說明

#### 方法 1：使用 Get-WmiObject Win32_PnpSignedDriver（推薦）

此方法直接獲取簽署的驅動程式資訊，最準確：

```powershell
Get-WmiObject Win32_PnpSignedDriver | Where-Object {$_.DeviceName -like "*VMD*"} | Select-Object DeviceName, DriverVersion, Manufacturer
```

**實際執行結果（2026-01-02）：**
```
DeviceName                       DriverVersion Manufacturer     
----------                       ------------- ----------------
Intel(R) RST VMD Controller AD0B 20.2.0.8335   Intel Corporation
```

**說明：**
- **DeviceName**: Intel(R) RST VMD Controller AD0B（您的系統為 AD0B 型號）
- **DriverVersion**: 20.2.0.8335 ✅ (RST POC Driver 版本)
- **Manufacturer**: Intel Corporation

---

#### 方法 2：檢查 Driver 文件

```powershell
Get-ChildItem "$env:SystemRoot\System32\drivers\iaStorVD.sys" | Format-Table Name, @{Name="SizeKB"; Expression={[math]::Round($_.Length/1KB, 2)}}, LastWriteTime
```

**實際執行結果（2026-01-02）：**
```
Name          SizeKB     LastWriteTime
----          ------     -------------
iaStorVD.sys  1579.01    1/2/2026 7:06:16 AM
```

**說明：**
- **Name**: iaStorVD.sys（英特爾儲存管理驅動程式）
- **Size**: 1,579.01 KB（約 1.5 MB）
- **Last Write Time**: 2026-01-02 07:06:16（驅動安裝時間戳記）

---

#### 方法 3：檢查 PnP 裝置狀態

```powershell
Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Volume Management*" -or $_.FriendlyName -like "*VMD*"} | Format-Table FriendlyName, Status, InstanceId
```

**實際執行結果（2026-01-02）：**
```
FriendlyName                     Status InstanceId
------------                     ------ ----------
Intel(R) RST VMD Controller AD0B OK     PCI\VEN_8086&DEV_AD0B&SUBSYS_0A1B1028&REV_00\0
```

**說明：**
- **FriendlyName**: Intel(R) RST VMD Controller AD0B（裝置名稱）
- **Status**: OK ✅（正常運作）
- **InstanceId**: PCI\VEN_8086&DEV_AD0B...（PCI 設備識別碼）
  - VEN_8086 = Intel (供應商)
  - DEV_AD0B = Arrow Lake-H VMD Controller (設備代碼)
  - SUBSYS_0A1B1028 = Dell 系統子系統 ID
  - REV_00 = 版本號

---

#### 方法 4：檢查磁碟狀態

```powershell
Get-PhysicalDisk | Format-Table FriendlyName, MediaType, HealthStatus, OperationalStatus, @{Name="SizeGB"; Expression={[math]::Round($_.Size/1GB, 2)}}
```

**實際執行結果（2026-01-02）：**
```
FriendlyName                   MediaType HealthStatus OperationalStatus SizeGB
------------                   --------- ------------ ----------------- ------
NVMe Micron_4600_MTFDLBA1T0THJ SSD       Healthy      OK                953.87
```

**說明：**
- **FriendlyName**: NVMe Micron_4600_MTFDLBA1T0THJ
  - Micron_4600 = SSD 型號（Micron 4600）
  - MTFDLBA1T0THJ = 完整型號識別碼
- **MediaType**: SSD（固態硬碟）
- **HealthStatus**: Healthy ✅（健康狀態良好）
- **OperationalStatus**: OK ✅（運作正常）
- **Size**: 953.87 GB（實際可用容量，約 1 TB）

---

#### 方法 5：使用 WMI 獲取詳細的 SCSI Controller 資訊

```powershell
Get-WmiObject Win32_SCSIController | Where-Object {$_.Caption -like "*Volume Management*" -or $_.Caption -like "*VMD*"} | Format-List Caption, Description, DriverName, DriverVersion, Status, Manufacturer, DeviceID
```

**實際執行結果（2026-01-02）：**
```
Caption       : Intel(R) RST VMD Controller AD0B
Description   : Storage controllers
DriverName    : iaStorVD
DriverVersion : 
Status        : OK
Manufacturer  : Intel Corporation
DeviceID      : PCI\VEN_8086&DEV_AD0B&SUBSYS_0A1B1028&REV_00
```

**說明：**
- **Caption**: 裝置完整名稱
- **Description**: 裝置類別（儲存控制器）
- **DriverName**: iaStorVD（驅動程式名稱）
- **Status**: OK（正常運作）
- **DeviceID**: PCI 設備識別碼

---

#### 方法 6：使用 WMIC 命令行工具

```powershell
# 簡潔輸出
wmic logicaldisk get name, size, freespace

# 詳細的系統信息
wmic os get caption, version, buildnumber

# 獲取所有簽署驅動程式
wmic sysdriver list brief
```

---

### 實際驗證結果摘要（2026-01-02）

**✅ 所有驗證項目通過！**

| 檢查項目 | 結果 | 詳細資訊 |
|---------|------|---------|
| **Driver 版本** | ✅ | 20.2.0.8335 (RST POC Driver) |
| **Driver 檔案** | ✅ | iaStorVD.sys (1,579 KB) |
| **檔案日期** | ✅ | 2026-01-02 07:06:16 |
| **裝置狀態** | ✅ | OK - Intel(R) RST VMD Controller AD0B |
| **磁碟狀態** | ✅ | Healthy - Micron 4600 (953.87 GB) |
| **磁碟健康** | ✅ | OK - 運作正常 |

**總結：**
- ✅ RST POC Driver 20.2.0.8335 已成功安裝
- ✅ Driver 文件完整且有效
- ✅ VMD Controller (AD0B) 正常運作
- ✅ NVMe 磁碟健康狀態良好
- ✅ 系統已準備好進行 Stage 6 DSM Hints 配置測試

---

## 🧪 測試 DSM Hints 功能

### 步驟 5.10：使用 RSTCLI Tool 測試

```powershell
# 進入 RSTCLI Tool 目錄
cd C:\Users\svd\codes\openvino-lab\evaluation_requirements\4_RSTCLI_tool\RST_PV_20.2.6.1025.3_25H2_24H2_SV2_Win10\CLI

# 檢查 RAID 控制器資訊
.\rstcli64.exe --information

# 檢查磁碟資訊
.\rstcli64.exe --disk-information

# 檢查 DSM Hints 支援（如果可用）
.\rstcli64.exe --disk-features
```

---

### 步驟 5.11：執行 Benchmark 對比測試

現在進行 Before/After 對比測試：

#### 測試 1：使用新 Driver 測試 TTFT

```powershell
# 進入測試目錄
cd C:\Users\svd\codes\openvino-lab\nvme_dsm_test

# 執行 CPU 測試（關注 Load time 和 TTFT）
.\run_benchmark_with_official_runtime.ps1 -Device CPU -NumIterations 3

# 執行 GPU 測試
.\run_benchmark_with_official_runtime.ps1 -Device GPU -NumIterations 3
```

#### 測試 2：記錄性能數據

| 指標 | 舊 Driver | 新 RST POC Driver | 改善 |
|------|----------|------------------|------|
| Load Time (CPU) | 2030 ms | ??? ms | ??? % |
| TTFT (CPU) | 1919 ms | ??? ms | ??? % |
| Load Time (GPU) | 9545 ms | ??? ms | ??? % |
| TTFT (GPU) | 101 ms | ??? ms | ??? % |

---

## 📊 性能影響分析

### DSM Hints 對不同場景的影響

| 場景 | 預期改善 | 說明 |
|------|---------|------|
| **模型載入** | 5-15% | Sequential read hint 加速大文件讀取 |
| **首 Token 生成** | 3-10% | 減少初始化延遲 |
| **小模型 (< 2GB)** | < 5% | 影響較小 |
| **大模型 (> 7GB)** | 10-20% | 影響顯著 |

---

## ⚠️ 故障排除

### 問題 1：測試模式無法啟用

**症狀：** "The value is protected by Secure Boot policy"

**解決方案：**
```powershell
# 需要在 BIOS/UEFI 中暫時禁用 Secure Boot
# 1. 重啟電腦進入 BIOS (通常按 F2 或 Del)
# 2. 找到 Secure Boot 設定
# 3. 設置為 Disabled
# 4. 保存並重啟
# 5. 再次執行啟用測試模式命令

bcdedit /set testsigning on
```

---

### 問題 2：Driver 安裝失敗

**症狀：** "Windows cannot verify the digital signature"

**解決方案：**
```powershell
# 1. 檢查系統是否啟用測試簽名
bcdedit /enum | Select-String "testsigning"

# 2. 如果需要，啟用測試簽名（需管理員權限）
bcdedit /set testsigning on

# 3. 重新啟動
Restart-Computer
```

---

### 問題 3：系統無法啟動

**症狀：** 安裝 Driver 後無法進入 Windows

**解決方案：**
1. 進入 Windows 安全模式（開機時按 F8）
2. 回滾 Driver：
```powershell
pnputil /delete-driver oem123.inf /uninstall
```
3. 或使用之前創建的系統還原點

---

### 問題 4：VMD Controller 找不到

**症狀：** 裝置管理員中沒有 VMD 裝置

**解決方案：**
1. 進入 BIOS/UEFI
2. Advanced → VMD Setup
3. 啟用 VMD Controller
4. 保存並重啟

---

### 問題 5：Driver 版本沒有更新

**症狀：** 安裝後 Driver 版本沒變

**解決方案：**
```powershell
# 1. 強制卸載舊 Driver
pnputil /enum-drivers | Select-String "iaStorVD"
pnputil /delete-driver oem<number>.inf /force

# 2. 重新安裝新 Driver
pnputil /add-driver iaStorVD.inf /install

# 3. 重新啟動
Restart-Computer
```

---

### 問題 6：測試模式浮水印影響使用

**症狀：** 桌面右下角顯示 "測試模式" 浮水印

**說明：**
- 這是啟用測試模式的正常現象
- 不影響系統功能和性能測試
- 完成所有測試後可關閉測試模式來移除浮水印

**移除浮水印（完成測試後）：**
```powershell
# 關閉測試模式
bcdedit /set testsigning off

# 重新啟動
Restart-Computer
```

---

## 📚 參考資源

### Intel RST 文檔
- [Intel Rapid Storage Technology](https://www.intel.com/content/www/us/en/support/products/55005/software/chipset-software/intel-rapid-storage-technology-intel-rst.html)
- [VMD Technology Guide](https://www.intel.com/content/www/us/en/support/articles/000059228/memory-and-storage.html)

### NVMe DSM 規範
- [NVMe Dataset Management Commands](https://nvmexpress.org/specifications/)

---

## 💡 最佳實踐

### 1. 測試前後對比

```powershell
# 創建測試報告
$reportPath = "driver_upgrade_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

@"
Intel RST POC Driver 升級測試報告
================================
測試日期: $(Get-Date)
系統: $(Get-WmiObject Win32_OperatingSystem | Select -ExpandProperty Caption)

Driver 資訊:
$(Get-WmiObject Win32_SCSIController | Where-Object {$_.Caption -like "*Volume Management*"} | Format-List | Out-String)

測試結果:
[在此記錄 Before/After 性能數據]
"@ | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "✅ 報告已保存到: $reportPath" -ForegroundColor Green
```

### 2. 保留舊 Driver 備份

在升級前，備份舊 Driver：
```powershell
# 導出當前 Driver
pnputil /export-driver iaStorVD C:\Backup\OldDriver
```

---

## ✅ 完成檢查

在進入下一步前，確認以下項目：

- [ ] 系統為 Intel 平台
- [ ] VMD Controller 已啟用
- [ ] 系統還原點已創建
- [ ] **測試模式已啟用（桌面有浮水印）**
- [ ] RST POC Driver 已成功安裝
- [ ] Driver 版本為 20.2.x
- [ ] 系統可正常啟動
- [ ] 磁碟健康狀態正常
- [ ] 已執行 Before/After 性能測試
- [ ] 性能數據已記錄

---

## 📝 下一步

完成 Driver 升級後：

1. **返回階段 4** - 重新執行性能測試
2. **對比結果** - 分析 DSM Hints 的影響
3. **記錄數據** - 更新性能報告
4. **優化配置** - 根據結果調整參數

---

**創建日期：** 2026-01-02  
**最後更新：** 2026-01-02  
**維護者：** OpenVINO Lab 項目  
**狀態：** ✅ 已驗證可用

---

**⚠️ 注意：** 此階段為可選項，僅在需要測試 DSM Hints 功能時執行！
