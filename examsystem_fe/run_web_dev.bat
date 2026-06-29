@echo off
echo ============================================
echo   FPT ExamHub - Flutter Web Dev Runner
echo ============================================
echo.

cd /d "%~dp0"

echo Starting Flutter Web on Chrome (CORS disabled for dev)...
echo.

flutter run -d chrome --web-browser-flag="--disable-web-security"
