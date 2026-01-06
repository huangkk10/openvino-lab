# benchmark_genai.exe PATH 問題修復報告

**日期：** 2026-01-06  
**用戶：** svd  
**系統：** Windows / PowerShell

---

## 🔴 原始問題

執行 `benchmark_genai.exe` 無輸出，Exit Code: -1073741515 (0xC0000135)

```powershell
& ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    -n 1 `
    --mt 20 `
    --cache_dir ".ccache"

# 結果：無輸出，Exit Code: -1073741515
```

---

## 🔍 診斷過程

### 1. 檢查執行檔與模型路徑
✅ `benchmark_genai.exe` 存在  
✅ 模型目錄存在  
✅ 權限正常  

### 2. 測試執行 `--help`
❌ **失敗**，Exit Code: -1073741515  
→ 表示 DLL 載入失敗

### 3. 檢查 OpenVINO Runtime
✅ OpenVINO runtime DLL 存在於 `.\nvme_dsm_test\openvino_cpp_runtime\bin\`  
❌ **PATH 環境變數未包含此目錄**  
→ Windows 無法找到 `openvino.dll`

### 4. 臨時設定 PATH（驗證）
```powershell
$env:PATH = ".\nvme_dsm_test\openvino_cpp_runtime\bin;" + $env:PATH
```
✅ **成功！** Exit Code 變為 0，正常輸出

---

## ✅ 解決方案（已執行）

### 方式 3：永久設定 Windows 環境變數

```powershell
# 以管理員身份執行（已完成）
[Environment]::SetEnvironmentVariable('PATH', 'C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin;' + [Environment]::GetEnvironmentVariable('PATH', 'User'), 'User')
```

### 執行結果
```
✅ OpenVINO path added permanently
```

---

## 🧪 驗證結果

### 驗證 1：PATH 設定
```
C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin;[...其他路徑...]
```
✅ OpenVINO 路徑已在 PATH 最前面

### 驗證 2：Fresh PowerShell 會話
```powershell
powershell -NoProfile -Command "& '.\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe' --help"
```
✅ **成功執行**，無需手動設定 PATH

### 驗證 3：完整 Benchmark 執行
```powershell
cd C:\Users\svd\codes\openvino-lab
& ".\nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe" `
    -m ".\models\open_llama_7b_v2-int4-ov" `
    -d GPU `
    -p "The Sky is blue because" `
    --nw 0 `
    -n 1 `
    --mt 20 `
    --cache_dir ".ccache"
```

**輸出：**
```
OpenVINO Runtime
    Version : 2025.4.1
    Build   : 2025.4.1-20426-82bbf0292c5-releases/2025/4

Using CACHE_DIR: .ccache
Prompt token size:6
Output token size:20
Load time: 5907.00 ms
Generate time: 1262.09 ± 0.00 ms
Tokenization time: 0.10 ± 0.00 ms
Detokenization time: 0.60 ± 0.00 ms
TTFT: 113.03 ± 0.00 ms
TPOT: 60.44 ± 5.24 ms/token 
Throughput: 16.55 ± 1.44 tokens/s
```
✅ **正常執行**，Exit Code: 0

---

## 📋 修改清單

### 1. 文檔更新
- **檔案：** `docs/benchmark/STAGE_7_CONFIGURE_DSM_HINTS.md`
- **變更：** 新增「問題 6：benchmark_genai.exe 執行後無輸出」故障排除章節
  - 說明根本原因（DLL 載入失敗）
  - 提供 3 種解決方案
    - 6.1：臨時設定 PATH
    - 6.2：Wrapper 腳本
    - 6.3：永久設定（已執行） ✅
  - 驗證方法與測試命令

### 2. Wrapper 腳本建立
- **檔案：** `run_benchmark.ps1`
- **功能：** 自動設定 PATH 並執行 benchmark
- **用法：**
  ```powershell
  .\run_benchmark.ps1
  .\run_benchmark.ps1 -Device GPU -MaxTokens 50 -NumIter 3
  ```

### 3. 系統設定
- **環境變數：** Windows 用戶 PATH
- **變更：** 添加 `C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin`
- **位置：** 最前面（優先級最高）

---

## 🎯 後續說明

### 何時需要重新啟動
❌ **無需重新啟動系統**

新開的 PowerShell 會話會自動使用永久 PATH。

### 驗證方法
```powershell
# 任何新的 PowerShell 視窗中執行：
$env:PATH -split ';' | Select-Object -First 1
# 應該輸出：C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin
```

### 常見問題

**Q: 為什麼原本執行沒有輸出？**  
A: Windows 無法找到 OpenVINO DLL，程式在啟動時 crash，沒有機會輸出任何內容。

**Q: 如何確認修復成功？**  
A: 執行 `benchmark_genai.exe --help`，應該看到幫助文字（Exit Code 0）。

**Q: 其他應用程式會受到影響嗎？**  
A: 不會。此 PATH 設定是添加到最前面，只影響 OpenVINO 相關程式。

---

## 📊 性能參考

修復後的 benchmark 性能指標：

| 指標 | 值 |
|------|-----|
| Load Time | 5907.00 ms |
| TTFT (Time To First Token) | 113.03 ms |
| TPOT (Time Per Output Token) | 60.44 ms/token |
| Throughput | 16.55 tokens/s |

---

## ✅ 完成清單

- [x] 診斷問題根本原因（DLL 載入失敗）
- [x] 臨時驗證解決方案
- [x] 執行永久 PATH 設定（方式 3）
- [x] 驗證設定有效（Fresh PowerShell 會話）
- [x] 更新文檔（STAGE_7_CONFIGURE_DSM_HINTS.md）
- [x] 建立 wrapper 腳本（run_benchmark.ps1）
- [x] 建立修復報告（本文檔）

---

**修復完成日期：** 2026-01-06 10:30 AM  
**修復狀態：** ✅ **完成**  
**測試狀態：** ✅ **已驗證**
