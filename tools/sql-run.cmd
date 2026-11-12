@echo off
rem Run a .sql file against SQL Server using Windows Authentication.
rem Usage: sql-run.cmd <file.sql> [server] [database]
setlocal EnableExtensions

set "SQLCMD=sqlcmd"
if exist "C:\Program Files\sqlcmd\sqlcmd.exe" set "SQLCMD=C:\Program Files\sqlcmd\sqlcmd.exe"

set "SQLFILE=%~1"
set "SERVER=%~2"
set "DB=%~3"
if "%SQLFILE%"=="" (
  echo Usage: sql-run.cmd ^<file.sql^> [server] [database]
  exit /b 1
)
if not exist "%SQLFILE%" (
  echo [ERROR] SQL file not found: "%SQLFILE%"
  exit /b 1
)
if "%SERVER%"=="" set "SERVER=localhost\SQLEXPRESS"

set "DBARG="
if not "%DB%"=="" set "DBARG=-d "%DB%""

echo [sqlcmd] %SERVER%  ^<- %SQLFILE%
echo ----------------------------------------
"%SQLCMD%" -S "%SERVER%" -E -C -i "%SQLFILE%" -W -s " | " %DBARG%
set "RC=%errorlevel%"
echo ----------------------------------------
echo [exit code] %RC%
exit /b %RC%