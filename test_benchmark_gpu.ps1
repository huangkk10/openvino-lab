# Stage 9 Benchmark GPU 測試腳本

Write-Host "`n========== Stage 9 Benchmark GPU 測試 ==========" -ForegroundColor Cyan

# 設定路徑
$BENCHMARK_EXE = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
$DLL_PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai"
$MODEL_PATH = "C:\Users\svd\codes\openvino-lab\models\TinyLlama-1.1B-Chat-int4"

# 添加 DLL 路徑到 PATH
$env:PATH = "$DLL_PATH;$env:PATH"

Write-Host "`n檢查文件..." -ForegroundColor Yellow
if (!(Test-Path $BENCHMARK_EXE)) {
    Write-Host "Error: benchmark_genai.exe 不存在！" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $MODEL_PATH)) {
    Write-Host "Error: 模型不存在！" -ForegroundColor Red
    Write-Host "可用模型:" -ForegroundColor Yellow
    Get-ChildItem "C:\Users\svd\codes\openvino-lab\models" -Directory | ForEach-Object { Write-Host "  - $($_.Name)" }
    exit 1
}

Write-Host "✓ 文件檢查完成`n" -ForegroundColor Green

# 測試命令參數格式（您提供的格式）
Write-Host "執行 Benchmark 測試..." -ForegroundColor Cyan
Write-Host "  模型: TinyLlama-1.1B-Chat-int4"
Write-Host "  設備: GPU"
Write-Host "  提示詞: 'The Sky is blue because'"
Write-Host "  參數: -nw 0 -mt 20 -n 1`n"

Write-Host "執行命令:" -ForegroundColor Yellow
Write-Host "  benchmark_genai.exe -m $MODEL_PATH -d GPU -p `"The Sky is blue because`" -nw 0 -mt 20 -n 1`n"

# 執行
try {
    & $BENCHMARK_EXE -m $MODEL_PATH -d GPU -p "The Sky is blue because" -nw 0 -mt 20 -n 1
    Write-Host "`n✓ GPU 測試完成" -ForegroundColor Green
} catch {
    Write-Host "`n✗ 執行失敗: $_" -ForegroundColor Red
}

# 如果 GPU 失敗，嘗試 CPU
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nGPU 測試失敗，嘗試使用 CPU..." -ForegroundColor Yellow
    & $BENCHMARK_EXE -m $MODEL_PATH -d CPU -p "The Sky is blue because" -nw 0 -mt 20 -n 1
}

Write-Host "`n========== 測試結束 ==========" -ForegroundColor Cyan
