@echo off
setlocal
cd /d "%~dp0"
if "%GENLENS_PORT%"=="" set GENLENS_PORT=8765
where py >nul 2>nul
if errorlevel 1 (
  echo Python launcher was not found. Install Python 3.10, 3.11, or 3.12 and try again.
  pause
  exit /b 1
)
py -3.12 --version >nul 2>nul
if errorlevel 1 (
  py -3.11 --version >nul 2>nul
  if errorlevel 1 (
    py -3.10 --version >nul 2>nul
    if errorlevel 1 (
      echo Gen Lens requires Python 3.10, 3.11, or 3.12.
      pause
      exit /b 1
    ) else (set PYVER=3.10)
  ) else (set PYVER=3.11)
) else (set PYVER=3.12)
if not exist ".venv\Scripts\python.exe" (
  echo Creating Gen Lens Python environment...
  py -%PYVER% -m venv .venv
  if errorlevel 1 goto :failed
)
.venv\Scripts\python.exe -c "import paddleocr,fastapi,openpyxl,cv2,pymupdf" >nul 2>nul
if errorlevel 1 (
  echo Installing PaddleOCR and local app dependencies. Internet is required for initial setup.
  .venv\Scripts\python.exe -m pip install --upgrade pip
  if errorlevel 1 goto :failed
  .venv\Scripts\python.exe -m pip install -r requirements.txt
  if errorlevel 1 goto :failed
)
if not exist "data\inbox" mkdir "data\inbox"
if not exist "data\models" mkdir "data\models"
set "PADDLE_PDX_CACHE_HOME=%CD%\data\models"
start "Gen Lens browser" http://127.0.0.1:%GENLENS_PORT%
echo Gen Lens is local at http://127.0.0.1:%GENLENS_PORT%
echo Bundled PaddleOCR model weights are loaded from data\models. No OCR model download is needed.
echo Keep this window open while using the app. Press Ctrl+C to stop.
.venv\Scripts\python.exe -m uvicorn app.server:app --host 127.0.0.1 --port %GENLENS_PORT% --no-access-log
if errorlevel 1 goto :failed
exit /b 0
:failed
echo Gen Lens could not start. Review the message above, then try again.
pause
exit /b 1
