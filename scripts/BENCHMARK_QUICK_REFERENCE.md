# Benchmark 快速執行參考

## 🚀 最簡單的方式（推薦）

```powershell
.\scripts\run_benchmark_easy.ps1 -Device CPU -NumIter 1
```

---

## 📋 常用命令速查

### 1. 快速測試（1 次，不預熱）
```powershell
.\scripts\run_benchmark_easy.ps1 -Device CPU -NumIter 1
```

### 2. 標準測試（5 次，預熱 2 次）
```powershell
.\scripts\run_benchmark_easy.ps1 -Device CPU -NumWarmup 2 -NumIter 5
```

### 3. 精確測試（10 次，預熱 5 次）
```powershell
.\scripts\run_benchmark_easy.ps1 -Device CPU -NumWarmup 5 -NumIter 10
```

### 4. 長文本生成測試（生成 100 tokens）
```powershell
.\scripts\run_benchmark_easy.ps1 -Device CPU -MaxTokens 100 -NumIter 5
```

### 5. 自訂提示詞
```powershell
.\scripts\run_benchmark_easy.ps1 `
    -Prompt "Explain quantum computing in detail" `
    -Device CPU `
    -NumIter 3
```

---

## 🔧 不使用 Helper 腳本的方式

### 方式 A：使用參數陣列（推薦）

```powershell
# 1. 設置環境
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;$env:PATH"

# 2. 定義路徑
$benchmarkExe = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
$modelPath = "C:\Users\svd\codes\openvino-lab\models\open_llama"

# 3. 執行
$args = @(
    '-m', $modelPath,
    '-d', 'CPU',
    '-p', 'The Sky is blue because',
    '--nw', '0',
    '--mt', '20',
    '-n', '1'
)
& $benchmarkExe @args
```

### 方式 B：直接命令（最簡潔）

```powershell
$env:PATH="C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;$env:PATH"

& "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe" `
    -m "C:\Users\svd\codes\openvino-lab\models\open_llama" `
    -d CPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1
```

### 方式 C：先進入目錄（傳統方式）

```powershell
# 1. 設置環境
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;$env:PATH"

# 2. 進入目錄
cd "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release"

# 3. 執行
.\benchmark_genai.exe `
    -m "C:\Users\svd\codes\openvino-lab\models\open_llama" `
    -d CPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1
```

---

## 🔄 批次測試（多個配置）

### CPU vs GPU 對比

```powershell
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;$env:PATH"

$benchmarkExe = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
$modelPath = "C:\Users\svd\codes\openvino-lab\models\open_llama"

foreach ($device in @("CPU", "GPU")) {
    Write-Host "`n[*] Testing on $device" -ForegroundColor Cyan
    
    & $benchmarkExe `
        -m $modelPath `
        -d $device `
        -p "The Sky is blue because" `
        --nw 2 `
        --mt 20 `
        -n 5
}
```

### 不同 Token 數量對比

```powershell
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;$env:PATH"

$benchmarkExe = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
$modelPath = "C:\Users\svd\codes\openvino-lab\models\open_llama"

foreach ($tokens in @(20, 50, 100)) {
    Write-Host "`n[*] Testing with MaxTokens=$tokens" -ForegroundColor Cyan
    
    & $benchmarkExe `
        -m $modelPath `
        -d CPU `
        -p "The Sky is blue because" `
        --nw 1 `
        --mt $tokens `
        -n 3
}
```

---

## 📝 參數快速查看

| 參數 | 說明 | 範例 | 預設值 |
|------|------|------|--------|
| `-m` | 模型路徑 | `/models/open_llama` | 必需 |
| `-d` | 設備（CPU/GPU/NPU） | `CPU` | `CPU` |
| `-p` | 提示詞 | `"What is AI?"` | `""` |
| `--nw` | 預熱迭代次數 | `2` | `1` |
| `--mt` | 最大生成 Token 數 | `50` | `20` |
| `-n` | 測試迭代次數 | `5` | `3` |

**⚠️ 重要：** `--nw` 和 `--mt` 使用**雙破折號**！

---

## 💾 保存測試結果

### 保存到文件

```powershell
# 執行 benchmark 並保存輸出
$output = & "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe" `
    -m "C:\Users\svd\codes\openvino-lab\models\open_llama" `
    -d CPU `
    -p "The Sky is blue because" `
    --nw 0 `
    --mt 20 `
    -n 1

# 保存結果
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$output | Out-File -FilePath "benchmark_result_$timestamp.txt" -Encoding UTF8

Write-Host "結果已保存到: benchmark_result_$timestamp.txt" -ForegroundColor Green
```

### 保存為 CSV（多次測試）

```powershell
$env:PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai;C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs;$env:PATH"

$benchmarkExe = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
$modelPath = "C:\Users\svd\codes\openvino-lab\models\open_llama"
$results = @()

foreach ($device in @("CPU", "GPU")) {
    foreach ($tokens in @(20, 50)) {
        Write-Host "Testing: $device, $tokens tokens"
        
        $output = & $benchmarkExe `
            -m $modelPath `
            -d $device `
            -p "Test" `
            --nw 1 `
            --mt $tokens `
            -n 3 2>&1 | Out-String
        
        # 解析輸出提取吞吐量
        if ($output -match "Throughput: ([\d.]+)") {
            $throughput = $matches[1]
            $results += @{
                Device = $device
                Tokens = $tokens
                Throughput = $throughput
                Time = Get-Date
            }
        }
    }
}

# 保存到 CSV
$results | Export-Csv -Path "benchmark_results.csv" -NoTypeInformation -Encoding UTF8
Write-Host "結果已保存到: benchmark_results.csv" -ForegroundColor Green
```

---

## 🎯 常用場景範本

### 範本 1：日常快速測試
```powershell
.\scripts\run_benchmark_easy.ps1
```

### 範本 2：性能對比（CPU vs GPU）
```powershell
.\scripts\run_benchmark_easy.ps1 -Device CPU -NumIter 5
.\scripts\run_benchmark_easy.ps1 -Device GPU -NumIter 5
```

### 範本 3：模型對比
```powershell
# 假設已下載多個模型
.\scripts\run_benchmark_easy.ps1 -Model "./models/open_llama" -Device CPU -NumIter 5
.\scripts\run_benchmark_easy.ps1 -Model "./models/TinyLlama" -Device CPU -NumIter 5
```

### 範本 4：準確基準測試
```powershell
.\scripts\run_benchmark_easy.ps1 `
    -Device CPU `
    -NumWarmup 5 `
    -MaxTokens 100 `
    -NumIter 10
```

---

## ⚠️ 常見問題

**Q: 執行時找不到 benchmark_genai.exe**
- A: 使用 Helper 腳本（自動處理） 或確保已設置環境變數

**Q: 執行時找不到模型文件**
- A: 確保模型路徑正確，使用絕對路徑最安全

**Q: GPU 模式不工作**
- A: 改用 `-Device CPU` 測試，或檢查 GPU 驅動安裝

**Q: 怎樣重複執行多次取平均？**
- A: 使用 `-NumIter 5` （或更多）參數

---

## 📚 更多信息

詳見 `STAGE_9_GUIDE.md` 中的「在 PowerShell 中執行 Benchmark」章節。

---

**最後更新：** 2025-12-31  
**作者：** OpenVINO Lab
