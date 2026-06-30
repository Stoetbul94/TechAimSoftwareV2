@echo off
setlocal EnableExtensions

rem === TechAim one-click rebuild (cmd-safe paths) ===

set "QT_BIN=C:\Qt\6.5.3\mingw_64\bin"
set "MINGW_BIN=C:\Qt\Tools\mingw1120_64\bin"
set "SRC=C:\Users\User\Desktop\Tech Aim Software\seta10"
set "BUILD=C:\Users\User\Documents\TechAimBuild-Desktop"
set "EXE=%BUILD%\release\TechAimTarget.exe"

set "PATH=%QT_BIN%;%MINGW_BIN%;%PATH%"

echo.
echo === TechAim rebuild ===
echo Source : %SRC%
echo Build  : %BUILD%
echo.

if not exist "%QT_BIN%\qmake.exe" (
    echo ERROR: Qt not found at %QT_BIN%
    echo Install Qt 6.5.3 MinGW 64-bit or edit this script.
    goto :fail
)

if not exist "%SRC%\Seta.pro" (
    echo ERROR: Seta.pro not found at %SRC%
    goto :fail
)

echo Closing TechAim if it is running...
taskkill /IM TechAimTarget.exe /F >nul 2>&1
timeout /t 1 /nobreak >nul

rem Force QML/resources back into the binary (fixes "nothing to be done" stale builds)
copy /b "%SRC%\qml.qrc"+,, "%SRC%\qml.qrc" >nul 2>&1
if exist "%EXE%" del /f /q "%EXE%" >nul 2>&1

if not exist "%BUILD%" mkdir "%BUILD%"
cd /d "%BUILD%"

echo Running qmake...
"%QT_BIN%\qmake.exe" "%SRC%\Seta.pro" -spec win32-g++ "CONFIG+=release"
if errorlevel 1 goto :fail

echo Compiling...
mingw32-make clean >nul 2>&1
mingw32-make -j4
if errorlevel 1 goto :fail

if not exist "%EXE%" (
    echo ERROR: Build finished but exe missing:
    echo %EXE%
    goto :fail
)

echo Deploying Qt runtime DLLs...
"%QT_BIN%\windeployqt.exe" --qmldir "%SRC%" --no-translations "%EXE%"
if errorlevel 1 goto :fail

if not exist "%BUILD%\release\Qt6Core.dll" (
    echo ERROR: Qt6Core.dll missing after deploy.
    goto :fail
)

echo.
echo ========================================
echo BUILD SUCCESS
echo ========================================
echo Run:
echo   "%BUILD%\release\Start TechAim.cmd"
echo.
goto :end

:fail
echo.
echo ========================================
echo BUILD FAILED
echo ========================================
exit /b 1

:end
endlocal
