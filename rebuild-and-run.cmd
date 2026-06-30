@echo off
cd /d "%~dp0"
call "%~dp0rebuild-release.cmd"
if errorlevel 1 (
    echo.
    pause
    exit /b 1
)
echo.
echo Starting TechAim...
start "" "C:\Users\User\Documents\TechAimBuild-Desktop\release\TechAimTarget.exe"
exit /b 0
