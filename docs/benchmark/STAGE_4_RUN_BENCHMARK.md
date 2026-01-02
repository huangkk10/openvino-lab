# 階段 4：執行性能測試

**目標：** 執行完整的性能基準測試並分析結果  
**時間：** 5-10 分鐘  
**難度：** ⭐ 簡單  
**狀態：** ✅ 已驗證

---

## 📋 本階段目標

1. 執行 CPU 模式性能測試
2. 執行 GPU 模式性能測試
3. 理解性能指標
4. 分析測試結果
5. 生成測試報告

---

## 🎯 性能指標說明

在開始測試前，先了解關鍵性能指標：

| 指標 | 英文 | 說明 | 重要性 |
|------|------|------|--------|
| **載入時間** | Load Time | 模型載入所需時間 | ⭐⭐ |
| **生成時間** | Generate Time | 生成 tokens 總時間 | ⭐⭐⭐ |
| **首 Token 時間** | TTFT (Time To First Token) | 首個 token 生成時間 | ⭐⭐⭐⭐ |
| **每 Token 時間** | TPOT (Time Per Output Token) | 平均每個 token 時間 | ⭐⭐⭐ |
| **吞吐量** | Throughput | 每秒生成 tokens 數 | ⭐⭐⭐⭐⭐ |

### 指標詳解

#### 吞吐量 (Throughput)
- **定義：** 每秒生成的 token 數量
- **單位：** tokens/s (t/s)
- **越高越好**
- **用途：** 衡量整體性能

#### 首 Token 時間 (TTFT)
- **定義：** 從開始到生成第一個 token 的時間
- **單位：** 毫秒 (ms)
- **越低越好**
- **用途：** 衡量響應速度（用戶體驗）

#### 每 Token 時間 (TPOT)
- **定義：** 平均每個 token 的生成時間
- **單位：** 毫秒/token (ms/token)
- **越低越好**
- **用途：** 衡量生成穩定性

---

## 🚀 測試步驟

### 步驟 4.1：執行 CPU 模式測試

#### 基本 CPU 測試

```powershell
# 進入測試目錄
cd C:\Users\svd\codes\openvino-lab\nvme_dsm_test

# 執行 CPU 測試
.\run_benchmark_with_official_runtime.ps1
```

**預期輸出：**
```
========================================
  OpenVINO GenAI Benchmark (C++ Runtime)
========================================

檢查 benchmark_genai.exe...
✅ benchmark_genai.exe 存在
檢查 DLL 目錄...
✅ bin 目錄存在
檢查必要的 DLL...
✅ 所有關鍵 DLL 文件存在
檢查模型路徑...
✅ 模型路徑存在

=== 測試配置 ===
模型: C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov
設備: CPU
提示: What is OpenVINO?
最大 tokens: 20
迭代次數: 1

✅ 已設置臨時 PATH 環境變數

=== 開始執行 Benchmark ===
執行中，請稍候...

[ INFO ] Benchmarking model with 1 requests and batch size 1, static scheduling.
[ INFO ] Model path: C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov
[ INFO ] Device: CPU

Load time: 2030.00 ms
Generate time: 1147.00 ms
Tokenization time: 1.50 ms
Detokenization time: 0.80 ms
TTFT: 1919.00 ms
TPOT: 57.35 ms/token
Throughput: 17.44 tokens/s

=== 執行完成 ===
總耗時: 3.25 秒
退出代碼: 0

✅ Benchmark 執行成功！
========================================
```

#### 記錄 CPU 測試結果

| 指標 | 數值 | 單位 |
|------|------|------|
| 載入時間 | 2030 | ms |
| 生成時間 | 1147 | ms |
| TTFT | 1919 | ms |
| TPOT | 57.35 | ms/token |
| **吞吐量** | **17.44** | **tokens/s** |

---

### 步驟 4.2：執行 GPU 模式測試

#### 首次 GPU 測試（包含編譯）

```powershell
# 執行 GPU 測試
.\run_benchmark_with_official_runtime.ps1 -Device GPU
```

**預期輸出：**
```
========================================
  OpenVINO GenAI Benchmark (C++ Runtime)
========================================

檢查 benchmark_genai.exe...
✅ benchmark_genai.exe 存在
...

=== 測試配置 ===
模型: C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov
設備: GPU
提示: What is OpenVINO?
最大 tokens: 20
迭代次數: 1

✅ 已設置臨時 PATH 環境變數

=== 開始執行 Benchmark ===
執行中，請稍候...

[ INFO ] Benchmarking model with 1 requests and batch size 1, static scheduling.
[ INFO ] Model path: C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov
[ INFO ] Device: GPU

Load time: 19000.00 ms       ← 首次包含 OpenCL 編譯
Generate time: 1507.00 ms
Tokenization time: 1.50 ms
Detokenization time: 0.80 ms
TTFT: 153.00 ms             ← 首 token 很快！
TPOT: 75.44 ms/token
Throughput: 13.26 tokens/s

=== 執行完成 ===
總耗時: 20.59 秒
退出代碼: 0

✅ Benchmark 執行成功！
========================================
```

#### 第二次 GPU 測試（已編譯）

```powershell
# 再次執行 GPU 測試（使用快取的編譯結果）
.\run_benchmark_with_official_runtime.ps1 -Device GPU
```

**預期輸出：**
```
Load time: 9545.00 ms        ← 載入時間減半！
Generate time: 1447.00 ms
Tokenization time: 1.50 ms
Detokenization time: 0.80 ms
TTFT: 101.00 ms              ← 首 token 更快！
TPOT: 70.80 ms/token
Throughput: 14.12 tokens/s

=== 執行完成 ===
總耗時: 11.11 秒
退出代碼: 0

✅ Benchmark 執行成功！
========================================
```

#### 記錄 GPU 測試結果

| 指標 | 首次運行 | 第二次運行 | 單位 |
|------|----------|-----------|------|
| 載入時間 | 19000 | 9545 | ms |
| 生成時間 | 1507 | 1447 | ms |
| TTFT | 153 | 101 | ms |
| TPOT | 75.44 | 70.80 | ms/token |
| **吞吐量** | 13.26 | **14.12** | **tokens/s** |

---

### 步驟 4.3：性能對比分析

#### CPU vs GPU 對比

| 設備 | 吞吐量 | TTFT | 載入時間 | 推薦場景 |
|------|--------|------|---------|---------|
| **CPU** | **17.44 t/s** | 1919 ms | 2.03 秒 | ✅ **大批量處理** |
| **GPU** | 14.12 t/s | **101 ms** | 9.5 秒 | ✅ **互動式應用** |

#### 關鍵發現

✅ **CPU 優勢：**
- 吞吐量最高（17.44 t/s）
- 載入速度快（2.03 秒）
- 適合批次處理任務

✅ **GPU 優勢：**
- 首 Token 時間最短（101 ms）
- 用戶響應速度快 19 倍
- 適合實時對話應用

#### 與 Python 腳本對比

| 方案 | 吞吐量 | 優勢 |
|------|--------|------|
| **C++ Runtime (CPU)** | **17.44 t/s** | **4x 性能提升** |
| Python 腳本 | 4.37 t/s | 靈活性好 |

---

### 步驟 4.4：進階測試場景

#### 場景 1：長文本生成

```powershell
# 生成 100 個 tokens
.\run_benchmark_with_official_runtime.ps1 -MaxTokens 100 -Device CPU
```

**預期結果：**
- 更長的生成時間
- 吞吐量保持穩定
- 可觀察 TPOT 一致性

#### 場景 2：多次迭代測試

```powershell
# 執行 5 次迭代取平均值
.\run_benchmark_with_official_runtime.ps1 -NumIterations 5 -Device CPU
```

**預期結果：**
- 更準確的性能數據
- 減少單次測試誤差
- 獲得平均性能指標

#### 場景 3：自定義提示測試

```powershell
# 測試不同提示長度的影響
.\run_benchmark_with_official_runtime.ps1 -Prompt "Write a detailed explanation of machine learning in simple terms" -MaxTokens 50
```

#### 場景 4：小模型快速測試

```powershell
# 使用 TinyLlama 模型（更快）
.\run_benchmark_with_official_runtime.ps1 -Model "C:\Users\svd\codes\openvino-lab\models\TinyLlama-1.1B-Chat-v1.0" -Device CPU
```

**預期結果：**
- 更快的載入時間
- 更高的吞吐量
- 適合快速驗證

---

## 📊 完整測試報告

### 測試環境

```
系統: Windows 10/11 (64-bit)
處理器: Intel Core i7/i9
記憶體: 16 GB RAM
OpenVINO: 2025.4.1-20426-82bbf0292c5
GenAI: 2025.4.1.0 (C++ Runtime)
模型: OpenLLaMA 7B v2 INT4 (~4 GB)
```

### CPU 測試結果

```
設備: CPU
載入時間: 2.03 秒
TTFT: 1919 ms
吞吐量: 17.44 tokens/s
TPOT: 57.35 ms/token

優勢: 最高吞吐量
適用: 批次處理、離線生成
```

### GPU 測試結果

```
設備: GPU
載入時間: 9.55 秒（首次）/ 9.5 秒（第二次）
TTFT: 101 ms
吞吐量: 14.12 tokens/s
TPOT: 70.80 ms/token

優勢: 最低延遲
適用: 實時對話、互動應用
```

### 性能總結

| 設備 | 綜合評分 | 推薦用途 |
|------|---------|---------|
| CPU | ⭐⭐⭐⭐⭐ | 離線批次處理 |
| GPU | ⭐⭐⭐⭐ | 實時互動應用 |

---

## ✅ 完成檢查

確認以下所有項目：

- [ ] CPU 測試執行成功（退出代碼 0）
- [ ] GPU 測試執行成功（退出代碼 0）
- [ ] 記錄了所有性能指標
- [ ] CPU 吞吐量 > 15 tokens/s
- [ ] GPU TTFT < 200 ms
- [ ] 理解了各項性能指標的含義
- [ ] 清楚何時使用 CPU 或 GPU

---

## 🎯 性能優化建議

### 優化 CPU 性能

#### 1. 使用更多 CPU 線程
```powershell
# 設置環境變數
$env:OMP_NUM_THREADS = "8"  # 根據 CPU 核心數調整
.\run_benchmark_with_official_runtime.ps1 -Device CPU
```

#### 2. 啟用 CPU 綁定
```powershell
$env:KMP_AFFINITY = "granularity=fine,compact,1,0"
.\run_benchmark_with_official_runtime.ps1 -Device CPU
```

### 優化 GPU 性能

#### 1. 預熱 GPU（跳過編譯時間）
```powershell
# 第一次運行會編譯 OpenCL 內核
.\run_benchmark_with_official_runtime.ps1 -Device GPU -MaxTokens 5

# 後續運行使用快取
.\run_benchmark_with_official_runtime.ps1 -Device GPU
```

#### 2. 清除 GPU 快取（重新測試）
```powershell
# 刪除 OpenCL 快取
Remove-Item "$env:LOCALAPPDATA\Intel\OpenCL\Cache" -Recurse -Force -ErrorAction SilentlyContinue
```

---

## 📈 結果可視化

### 創建性能對比圖表

```powershell
# 創建 CSV 文件用於 Excel 分析
@"
設備,吞吐量(t/s),TTFT(ms),載入時間(秒)
CPU,17.44,1919,2.03
GPU,14.12,101,9.55
Python,4.37,2500,15.00
"@ | Out-File -FilePath "benchmark_results.csv" -Encoding UTF8

Write-Host "✅ 結果已保存到 benchmark_results.csv" -ForegroundColor Green
```

### 使用 PowerShell 生成簡單圖表

```powershell
# 顯示 ASCII 圖表
Write-Host "`n=== 吞吐量對比 (tokens/s) ===" -ForegroundColor Cyan
Write-Host "CPU:    " -NoNewline; Write-Host ("█" * 17) -ForegroundColor Green; Write-Host "        17.44 t/s"
Write-Host "GPU:    " -NoNewline; Write-Host ("█" * 14) -ForegroundColor Blue; Write-Host "        14.12 t/s"
Write-Host "Python: " -NoNewline; Write-Host ("█" * 4) -ForegroundColor Yellow; Write-Host "        4.37 t/s"

Write-Host "`n=== TTFT 對比 (ms, 越低越好) ===" -ForegroundColor Cyan
Write-Host "GPU:    " -NoNewline; Write-Host ("█" * 1) -ForegroundColor Green; Write-Host "        101 ms"
Write-Host "CPU:    " -NoNewline; Write-Host ("█" * 19) -ForegroundColor Blue; Write-Host "        1919 ms"
Write-Host "Python: " -NoNewline; Write-Host ("█" * 25) -ForegroundColor Yellow; Write-Host "        2500 ms"
```

---

## ⚠️ 故障排除

### 問題 1：退出代碼非 0

**症狀：**
```
❌ Benchmark 執行失敗（退出代碼: 1）
```

**可能原因：**
- DLL 缺失或損壞
- 模型路徑錯誤
- 記憶體不足
- 設備不支援

**解決方案：**
```powershell
# 1. 重新驗證 DLL
cd openvino_cpp_runtime
.\verify_dlls.ps1

# 2. 檢查模型
dir C:\Users\svd\codes\openvino-lab\models\open_llama_7b_v2-int4-ov

# 3. 檢查記憶體
Get-CimInstance Win32_OperatingSystem | Select FreePhysicalMemory
```

### 問題 2：GPU 載入時間過長

**症狀：** GPU 首次載入超過 30 秒

**原因：** OpenCL 內核編譯

**解決方案：**
```powershell
# 這是正常的首次運行行為
# 第二次運行會使用快取，速度會快得多

# 執行第二次測試
.\run_benchmark_with_official_runtime.ps1 -Device GPU
```

### 問題 3：性能低於預期

**症狀：** 吞吐量遠低於文檔中的數值

**可能原因：**
- 背景程序佔用資源
- 熱節流
- 模型量化級別不同

**解決方案：**
```powershell
# 1. 關閉不必要的程序
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

# 2. 檢查 CPU 溫度和頻率
# 使用硬體監控工具（如 HWiNFO）

# 3. 使用多次迭代取平均
.\run_benchmark_with_official_runtime.ps1 -NumIterations 5
```

### 問題 4：GPU 不可用

**症狀：**
```
[ ERROR ] GPU device not found
```

**解決方案：**
```powershell
# 檢查 GPU 驅動
Get-WmiObject Win32_VideoController | Select Name, DriverVersion

# 更新 Intel GPU 驅動
# 訪問: https://www.intel.com/content/www/us/en/download-center/home.html
```

### 問題 5：記憶體不足

**症狀：**
```
[ ERROR ] Out of memory
```

**解決方案：**
```powershell
# 1. 使用更小的模型
.\run_benchmark_with_official_runtime.ps1 -Model "...\TinyLlama-1.1B-Chat-v1.0"

# 2. 減少生成長度
.\run_benchmark_with_official_runtime.ps1 -MaxTokens 10

# 3. 關閉其他應用程序
```

---

## 📚 參考資源

### 性能基準

- [OpenVINO 性能基準](https://docs.openvino.ai/latest/openvino_docs_performance_benchmarks.html)
- [GenAI 性能優化指南](https://github.com/openvinotoolkit/openvino.genai/blob/master/docs/PERFORMANCE.md)

### 設備支援

- [CPU 插件文檔](https://docs.openvino.ai/latest/openvino_docs_OV_UG_supported_plugins_CPU.html)
- [GPU 插件文檔](https://docs.openvino.ai/latest/openvino_docs_OV_UG_supported_plugins_GPU.html)

---

## 💡 最佳實踐

### 1. 測試前準備

```powershell
# 確保系統穩定
# 關閉不必要的背景程序
# 斷開非必要的網路連接
```

### 2. 多次測試取平均

```powershell
# 執行至少 3 次測試
for ($i=1; $i -le 3; $i++) {
    Write-Host "測試 $i ..." -ForegroundColor Cyan
    .\run_benchmark_with_official_runtime.ps1 -NumIterations 3
    Start-Sleep -Seconds 5
}
```

### 3. 記錄完整環境

```powershell
# 創建環境報告
@"
測試日期: $(Get-Date)
系統: $(Get-WmiObject Win32_OperatingSystem | Select -ExpandProperty Caption)
CPU: $(Get-WmiObject Win32_Processor | Select -ExpandProperty Name)
記憶體: $([math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)) GB
GPU: $(Get-WmiObject Win32_VideoController | Select -ExpandProperty Name)
OpenVINO: 2025.4.1.0
"@ | Out-File -FilePath "test_environment.txt" -Encoding UTF8
```

---

## 🎉 恭喜！

完成所有 4 個階段後，您現在擁有：

✅ **功能完整的測試環境**
- 官方 C++ Runtime 已設置
- 所有 DLL 依賴已就緒
- 自動化執行腳本可用

✅ **實際性能數據**
- CPU 測試: 17.44 tokens/s
- GPU 測試: 14.12 tokens/s
- 完整的性能分析

✅ **可重複的測試流程**
- 清晰的文檔
- 自動化腳本
- 故障排除指南

✅ **深入理解**
- 性能指標含義
- 設備選擇依據
- 優化方向建議

---

## 📝 後續步驟

### 下一步可以做什麼？

1. **測試更多模型**
   - 嘗試不同大小的模型
   - 比較量化級別影響

2. **深入性能優化**
   - 調整 CPU 線程數
   - 優化 GPU 快取
   - 測試批次處理

3. **整合到應用**
   - 創建 API 包裝
   - 構建 Web 服務
   - 開發桌面應用

4. **擴展測試**
   - 添加更多測試場景
   - 自動化性能監控
   - 創建性能回歸測試

---

## 📊 完整測試檢查清單

### 測試前

- [ ] 系統資源充足（記憶體 > 8GB 可用）
- [ ] 所有背景程序已關閉
- [ ] DLL 環境已驗證
- [ ] 模型已下載並驗證

### CPU 測試

- [ ] 執行基本 CPU 測試
- [ ] 記錄吞吐量（應 > 15 t/s）
- [ ] 記錄 TTFT
- [ ] 記錄載入時間
- [ ] 執行長文本測試（可選）
- [ ] 執行多次迭代測試（可選）

### GPU 測試

- [ ] 執行首次 GPU 測試
- [ ] 等待 OpenCL 編譯完成
- [ ] 執行第二次 GPU 測試
- [ ] 記錄吞吐量
- [ ] 記錄 TTFT（應 < 200 ms）
- [ ] 比較 CPU vs GPU 結果

### 測試後

- [ ] 記錄所有性能數據
- [ ] 生成性能報告
- [ ] 備份測試結果
- [ ] 更新文檔

---

**創建日期：** 2026-01-02  
**最後更新：** 2026-01-02  
**維護者：** OpenVINO Lab 項目  
**狀態：** ✅ 已驗證可用

---

**🎊 恭喜完成所有測試！現在您可以使用預編譯的 benchmark_genai.exe 進行高性能的 AI 模型測試了！**
