@echo off
rem Open an interactive sqlcmd session against SQL Server.
rem Usage: sql-shell.cmd [server] [database]
setlocal EnableExtensions

set "SQLCMD=sqlcmd"
if exist "C:\Program Files\sqlcmd\sqlcmd.exe" set "SQLCMD=C:\Program Files\sqlcmd\sqlcmd.exe"

set "SERVER=%~1"
set "DB=%~2"
if "%SERVER%"=="" set "SERVER=localhost\SQLEXPRESS"

set "DBARG="
if not "%DB%"=="" set "DBARG=-d "%DB%""

echo [sqlcmd] interactive session on %SERVER%  (type GO to run, EXIT to quit)
"%SQLCMD%" -S "%SERVER%" -E -C %DBARG%