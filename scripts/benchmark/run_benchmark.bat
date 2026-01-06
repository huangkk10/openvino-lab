@echo off
REM ============================================================
REM One-Click Setup & Run Benchmark (Windows CMD/Batch version)
REM ============================================================
REM This batch file can be run directly from Windows Explorer
REM by double-clicking without needing to open PowerShell
REM ============================================================

chcp 65001 > nul
setlocal enabledelayedexpansion

REM Get script directory and navigate to project root
set SCRIPT_DIR=%~dp0
for %%A in ("!SCRIPT_DIR!..\..\") do set PROJECT_ROOT=%%~fA
cd /d "!PROJECT_ROOT!"

REM Define paths (relative to project root)
set OPENVINO_PATH=!PROJECT_ROOT!nvme_dsm_test\openvino_cpp_runtime\bin
set BENCHMARK_EXE=!PROJECT_ROOT!nvme_dsm_test\benchmark_app\OpenVINO_AI_apps_v01\benchmark_genai.exe
set MODEL_PATH=!PROJECT_ROOT!models\open_llama_7b_v2-int4-ov

echo.
echo ============================================================
echo     One-Click Benchmark Setup and Execution
echo ============================================================
echo.

REM Check files
echo [1] Checking system environment...
if not exist "!BENCHMARK_EXE!" (
    echo ERROR: Benchmark executable not found
    pause
    exit /b 1
)
echo OK: Benchmark executable found

if not exist "!MODEL_PATH!" (
    echo ERROR: Model path not found
    pause
    exit /b 1
)
echo OK: Model path found

if not exist "!OPENVINO_PATH!" (
    echo ERROR: OpenVINO runtime not found
    pause
    exit /b 1
)
echo OK: OpenVINO runtime found
echo.

REM Set environment variable
echo [2] Setting OpenVINO PATH...
set PATH=!OPENVINO_PATH!;!PATH!
echo OK: PATH configured
echo.

REM Verify
echo [3] Verifying environment...
"!BENCHMARK_EXE!" --help > nul 2>&1
if errorlevel 1 (
    echo ERROR: Verification failed
    pause
    exit /b 1
)
echo OK: Environment verified
echo.

REM Run benchmark
echo [4] Running Benchmark...
echo.
"!BENCHMARK_EXE!" ^
    -m "!MODEL_PATH!" ^
    -d GPU ^
    -p "The Sky is blue because" ^
    --nw 0 ^
    -n 1 ^
    --mt 20 ^
    --cache_dir ".ccache"

set RESULT=%ERRORLEVEL%
echo.
echo ============================================================
if %RESULT% equ 0 (
    echo SUCCESS: Benchmark execution completed
) else (
    echo ERROR: Benchmark execution failed (Exit Code: %RESULT%)
)
echo ============================================================
echo.
echo Press any key to close...
pause > nul
exit /b %RESULT%
