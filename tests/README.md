# Running unit tests

Requires Qt 6.x with MinGW on PATH (see `run-techaim-dev.cmd` for typical paths).

```powershell
$env:PATH = "C:\Qt\6.5.3\mingw_64\bin;C:\Qt\Tools\mingw1120_64\bin;" + $env:PATH
cd tests
mkdir build -Force; cd build
qmake ..\eventprofile_test.pro
mingw32-make
.\release\eventprofile_test.exe

cd ..
mkdir build_ms -Force; cd build_ms
qmake ..\matchsession_test.pro
mingw32-make
.\release\matchsession_test.exe

cd ..
mkdir build_se -Force; cd build_se
qmake ..\scoringengine_test.pro
mingw32-make
.\release\scoringengine_test.exe
```

### targetgeometry_test

```powershell
cd ..
mkdir build_tg -Force; cd build_tg
qmake ..\targetgeometry_test.pro
mingw32-make
.\release\targetgeometry_test.exe
```

All tests should exit with code **0**.
