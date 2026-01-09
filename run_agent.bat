@echo off
REM Llama AI Agent 啟動腳本
REM 這個腳本會啟動 AI Agent，讓 Llama 可以執行系統命令

echo ========================================
echo Llama AI Agent 啟動器
echo ========================================
echo.

REM 檢查虛擬環境
if not exist "venv\Scripts\activate.bat" (
    echo [錯誤] 找不到虛擬環境！
    echo 請先執行: python -m venv venv
    pause
    exit /b 1
)

REM 啟動虛擬環境並執行 Agent
echo 正在啟動 AI Agent...
echo.
call venv\Scripts\activate.bat
python examples\llama_agent.py

echo.
echo ========================================
echo Agent 已結束
echo ========================================
pause
