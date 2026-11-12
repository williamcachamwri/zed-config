@echo off
chcp 65001 >nul
rem Configure and build a CMake project with MSVC + Ninja,
rem or fall back to single-file build & run if no CMakeLists.txt exists.
rem Usage: cpp-build.cmd <project-root> [preset] [current-file]
setlocal EnableExtensions

set "ROOT=%~1"
set "PRESET=%~2"
set "CURRENT_FILE=%~3"
if "%ROOT%"=="" set "ROOT=%CD%"
if "%PRESET%"=="" set "PRESET=debug"
cd /d "%ROOT%" || exit /b 1

rem If this workspace is not a CMake project, fall back to building the current C/C++ file.
if not exist "%ROOT%\CMakePresets.json" if not exist "%ROOT%\CMakeLists.txt" (
  if not "%CURRENT_FILE%"=="" (
    echo [info] Khong tim thay CMakePresets.json / CMakeLists.txt trong "%ROOT%".
    echo [info] Tu dong chuyen sang build ^& run file hien tai: "%CURRENT_FILE%"
    echo.
    call "%~dp0cpp-run.cmd" "%CURRENT_FILE%" "%ROOT%\build\single"
    exit /b %errorlevel%
  )
  echo [ERROR] "%ROOT%" khong phai CMake project ^(khong co CMakePresets.json hoac CMakeLists.txt^).
  echo [TIP] Hay mo file .cpp/.c va dung task "C++: Build & run current file (MSVC)".
  exit /b 1
)

set "VSVARS=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
if not exist "%VSVARS%" (
  echo [ERROR] MSVC environment script not found: "%VSVARS%"
  exit /b 1
)
call "%VSVARS%" >nul 2>&1

rem Prepend the toolchain so this works even when the parent process
rem inherited a PATH from before CMake/Ninja/LLVM were installed.
set "PATH=C:\Program Files\CMake\bin;C:\Program Files\LLVM\bin;%LOCALAPPDATA%\Microsoft\WinGet\Packages\Ninja-build.Ninja_Microsoft.Winget.Source_8wekyb3d8bbwe;%PATH%"

if exist "%ROOT%\CMakePresets.json" (
  echo [cmake] configure preset "%PRESET%"
  cmake --preset "%PRESET%"
  if errorlevel 1 (
    echo [CONFIGURE FAILED]
    exit /b 1
  )

  echo.
  echo [cmake] build preset "%PRESET%"
  cmake --build --preset "%PRESET%"
  if errorlevel 1 (
    echo [BUILD FAILED]
    exit /b 1
  )
) else (
  set "BUILD_TYPE=Debug"
  if /i "%PRESET%"=="release" set "BUILD_TYPE=Release"
  echo [cmake] configure "%ROOT%" ^(%BUILD_TYPE%^)
  cmake -S "%ROOT%" -B "%ROOT%\build\%PRESET%" -G Ninja -DCMAKE_BUILD_TYPE=%BUILD_TYPE%
  if errorlevel 1 (
    echo [CONFIGURE FAILED]
    exit /b 1
  )

  echo.
  echo [cmake] build "%ROOT%\build\%PRESET%"
  cmake --build "%ROOT%\build\%PRESET%"
  if errorlevel 1 (
    echo [BUILD FAILED]
    exit /b 1
  )
)

echo.
echo [OK] build finished
exit /b 0
