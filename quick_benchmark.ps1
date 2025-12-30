# Stage 9 快速 Benchmark 測試腳本
# 使用方法: .\quick_benchmark.ps1

Write-Host @"

╔═══════════════════════════════════════════════════════════╗
║        OpenVINO GenAI Benchmark 快速測試工具              ║
║                    Stage 9 驗證版                         ║
╚═══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

# 設定路徑
$BENCHMARK_EXE = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
$DLL_PATH1 = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai"
$DLL_PATH2 = "C:\Users\svd\AppData\Local\Programs\Python\Python311\Lib\site-packages\openvino\libs"
$MODEL_DIR = "C:\Users\svd\codes\openvino-lab\models"

# 檢查 benchmark 是否存在
if (!(Test-Path $BENCHMARK_EXE)) {
    Write-Host "❌ 錯誤: benchmark_genai.exe 不存在！" -ForegroundColor Red
    Write-Host "   請先完成 Stage 9 的編譯步驟。" -ForegroundColor Yellow
    exit 1
}

# 設置環境變數
$env:PATH = "$DLL_PATH1;$DLL_PATH2;$env:PATH"

# 列出可用模型
Write-Host "📁 可用模型:" -ForegroundColor Yellow
$models = Get-ChildItem $MODEL_DIR -Directory | Select-Object -ExpandProperty Name
for ($i = 0; $i -lt $models.Count; $i++) {
    Write-Host "   [$($i+1)] $($models[$i])" -ForegroundColor White
}

# 選擇模型
Write-Host "`n請選擇模型編號 (1-$($models.Count)): " -NoNewline -ForegroundColor Cyan
$choice = Read-Host
$modelIndex = [int]$choice - 1

if ($modelIndex -lt 0 -or $modelIndex -ge $models.Count) {
    Write-Host "❌ 無效的選擇！" -ForegroundColor Red
    exit 1
}

$selectedModel = Join-Path $MODEL_DIR $models[$modelIndex]
Write-Host "`n✓ 已選擇模型: $($models[$modelIndex])" -ForegroundColor Green

# 選擇設備
Write-Host "`n📟 選擇推理設備:" -ForegroundColor Yellow
Write-Host "   [1] CPU (推薦，適用所有電腦)" -ForegroundColor White
Write-Host "   [2] GPU (需要 Intel GPU 或獨立顯卡)" -ForegroundColor White
Write-Host "`n請選擇設備 (1-2): " -NoNewline -ForegroundColor Cyan
$deviceChoice = Read-Host
$device = if ($deviceChoice -eq "2") { "GPU" } else { "CPU" }
Write-Host "✓ 已選擇設備: $device" -ForegroundColor Green

# 輸入提示詞
Write-Host "`n💬 輸入測試提示詞 (按 Enter 使用預設): " -NoNewline -ForegroundColor Cyan
$prompt = Read-Host
if ([string]::IsNullOrWhiteSpace($prompt)) {
    $prompt = "The Sky is blue because"
    Write-Host "   (使用預設提示詞: '$prompt')" -ForegroundColor Gray
}

# 設置參數
$maxTokens = 20
$numIter = 1
$numWarmup = 0

Write-Host "`n" + "="*60 -ForegroundColor Cyan
Write-Host "開始 Benchmark 測試..." -ForegroundColor Yellow
Write-Host "="*60 -ForegroundColor Cyan
Write-Host ""
Write-Host "模型: $($models[$modelIndex])" -ForegroundColor White
Write-Host "設備: $device" -ForegroundColor White
Write-Host "提示詞: `"$prompt`"" -ForegroundColor White
Write-Host "最大 tokens: $maxTokens" -ForegroundColor White
Write-Host "迭代次數: $numIter" -ForegroundColor White
Write-Host "預熱次數: $numWarmup" -ForegroundColor White
Write-Host ""

# 執行 benchmark
cd (Split-Path $BENCHMARK_EXE)
& $BENCHMARK_EXE `
    -m $selectedModel `
    -d $device `
    -p $prompt `
    --nw $numWarmup `
    --mt $maxTokens `
    -n $numIter

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n" + "="*60 -ForegroundColor Green
    Write-Host "✅ Benchmark 測試完成！" -ForegroundColor Green
    Write-Host "="*60 -ForegroundColor Green
} else {
    Write-Host "`n" + "="*60 -ForegroundColor Red
    Write-Host "❌ Benchmark 測試失敗 (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
    Write-Host "="*60 -ForegroundColor Red
    
    if ($device -eq "GPU") {
        Write-Host "`n💡 提示: 如果 GPU 失敗，請嘗試使用 CPU 模式。" -ForegroundColor Yellow
    }
}

Write-Host "`n按任意鍵退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
