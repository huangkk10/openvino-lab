@echo off
REM Print-only launcher for Llama chatbot (no execution)
REM This file only displays how to run the chatbot and exits.

echo.
echo === Llama Chatbot - Quick Run Hint ===
echo.
echo 1) Activate the virtual environment (PowerShell):
echo    .\venv\Scripts\Activate.ps1
echo.
echo 2) Or activate for cmd (if using cmd.exe):
echo    .\venv\Scripts\activate.bat
echo.
echo 3) Run the chatbot (from repo root):
echo    .\venv\Scripts\python.exe examples\llama_chatbot.py [DEVICE]
echo.
echo Example: CPU
echo    .\venv\Scripts\python.exe examples\llama_chatbot.py CPU
echo.
echo Example: GPU
echo    .\venv\Scripts\python.exe examples\llama_chatbot.py GPU
echo.
echo ======================================
echo.
exit /b 0
