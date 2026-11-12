@echo off
chcp 65001 >nul
rem Compile and run a single C/C++ file with the MSVC toolchain.
rem Usage: cpp-run.cmd <source-file> [output-dir]
setlocal EnableExtensions

set "VSVARS=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
if not exist "%VSVARS%" (
  echo [ERROR] MSVC environment script not found: "%VSVARS%"
  exit /b 1
)
call "%VSVARS%" >nul 2>&1

set "SRC=%~1"
set "OUT=%~2"
if "%SRC%"=="" (
  echo Usage: cpp-run.cmd ^<source-file^> [output-dir]
  exit /b 1
)
if not exist "%SRC%" (
  echo [ERROR] Source file not found: "%SRC%"
  exit /b 1
)
if "%OUT%"=="" set "OUT=%~dp1build"
if not exist "%OUT%" mkdir "%OUT%" >nul 2>&1
set "NAME=%~n1"

echo [cl] %SRC%
cl /nologo /utf-8 /std:c++20 /EHsc /W4 /Zi /Od /MD "%SRC%" /Fe:"%OUT%\%NAME%.exe" /Fo:"%OUT%\%NAME%.obj" /Fd:"%OUT%\%NAME%.pdb"
if errorlevel 1 (
  echo.
  echo [BUILD FAILED]
  exit /b 1
)

echo.
echo [run] %OUT%\%NAME%.exe
echo ----------------------------------------
"%OUT%\%NAME%.exe"
set "RC=%errorlevel%"
echo ----------------------------------------
echo [exit code] %RC%
exit /b %RC%