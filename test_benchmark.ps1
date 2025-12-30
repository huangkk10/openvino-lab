# Stage 9 Benchmark 測試腳本
# 測試 benchmark_genai.exe 是否能正常運行

Write-Host "`n========== Stage 9 Benchmark 測試 ==========" -ForegroundColor Cyan

# 設定路徑
$BENCHMARK_EXE = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\samples\cpp\text_generation\Release\benchmark_genai.exe"
$DLL_PATH = "C:\Users\svd\codes\openvino-lab\src\openvino.genai\build_cpp\openvino_genai"
$MODEL_PATH = "C:\Users\svd\codes\openvino-lab\models\TinyLlama-1.1B-Chat-int4"

# 添加 DLL 路徑到 PATH
$env:PATH = "$DLL_PATH;$env:PATH"

Write-Host "`n檢查文件是否存在..." -ForegroundColor Yellow
Write-Host "  Benchmark: $(Test-Path $BENCHMARK_EXE)"
Write-Host "  DLL: $(Test-Path "$DLL_PATH\openvino_genai.dll")"
Write-Host "  Model: $(Test-Path $MODEL_PATH)"

if (!(Test-Path $BENCHMARK_EXE)) {
    Write-Host "`nError: benchmark_genai.exe 不存在！" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $MODEL_PATH)) {
    Write-Host "`nError: 模型路徑不存在！" -ForegroundColor Red
    exit 1
}

Write-Host "`n執行 benchmark 測試..." -ForegroundColor Green
Write-Host "  模型: TinyLlama-1.1B-Chat-int4"
Write-Host "  設備: CPU"
Write-Host "  提示詞: 'What is OpenVINO?'"
Write-Host "  最大 tokens: 20`n"

# 執行 benchmark
& $BENCHMARK_EXE -m $MODEL_PATH -d CPU -p "What is OpenVINO?" -mt 20 -n 1

Write-Host "`n========== 測試完成 ==========" -ForegroundColor Cyan
