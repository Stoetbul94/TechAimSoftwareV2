@echo off
setlocal
set "APP_DIR=C:\Users\User\Documents\TechAimBuild-Desktop\release"
set "PATH=C:\Qt\6.5.3\mingw_64\bin;C:\Qt\Tools\mingw1120_64\bin;%PATH%"
set "QML2_IMPORT_PATH=C:\Qt\6.5.3\mingw_64\qml"
start "" /D "%APP_DIR%" "%APP_DIR%\TechAimTarget.exe"
endlocal
