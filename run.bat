@echo off
REM DeveloperCat DK - Quick Run Script for Windows
REM This script loads environment variables from .env and runs the Flutter app

REM Check if .env file exists
if not exist .env (
    echo Error: .env file not found!
    echo Please create a .env file with your API keys:
    echo GEMINI_API_KEY=your_key_here
    echo SUPABASE_URL=your_url_here
    echo SUPABASE_ANON_KEY=your_key_here
    exit /b 1
)

REM Load environment variables from .env
for /f "usebackq tokens=1,* delims==" %%a in (.env) do (
    if not "%%a"=="" if not "%%b"=="" (
        set %%a=%%b
    )
)

REM Default device is Chrome (web)
set DEVICE=%1
if "%DEVICE%"=="" set DEVICE=chrome

echo 🚀 Starting DeveloperCat DK on %DEVICE%...
echo 📦 Using Gemini API Key: %GEMINI_API_KEY:~0,10%...

REM Run Flutter with environment variables
flutter run -d %DEVICE% --dart-define=GEMINI_API_KEY=%GEMINI_API_KEY% --dart-define=SUPABASE_URL=%SUPABASE_URL% --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY%
