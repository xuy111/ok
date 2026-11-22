@echo off
chcp 936 >nul
call "%~dp0env.bat"

if not defined MYSQL_HOME (
  echo [MySQL] mysqld.exe not found. Please set the MySQL path in scripts\env.bat
  exit /b 1
)

"%MYSQLADMIN%" -u%DB_USER% -p%DB_PASS% ping >nul 2>nul
if not errorlevel 1 (
  echo [MySQL] already running on port 3306.
  exit /b 0
)

echo [MySQL] starting from %MYSQL_HOME%

rem ------------------------------------------------------------
rem Launch through Start-Process -WindowStyle Hidden:
rem   1) no extra console window, so closing a window cannot kill mysqld
rem   2) the process is detached from this script; MySQL keeps running
rem ------------------------------------------------------------
if defined MYSQL_INI (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%MYSQLD%' -ArgumentList '--defaults-file=%MYSQL_INI%' -WindowStyle Hidden" >nul 2>nul
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%MYSQLD%' -WindowStyle Hidden" >nul 2>nul
)

rem fallback: if PowerShell is blocked, use the old minimized window
if errorlevel 1 (
  if defined MYSQL_INI (
    start "MySQL" /min "%MYSQLD%" --defaults-file="%MYSQL_INI%"
  ) else (
    start "MySQL" /min "%MYSQLD%"
  )
)

set /a N=0
:waitmysql
set /a N+=1
ping -n 2 127.0.0.1 >nul 2>nul
"%MYSQLADMIN%" -u%DB_USER% -p%DB_PASS% ping >nul 2>nul
if not errorlevel 1 (
  echo [MySQL] ready on port 3306.
  exit /b 0
)
if %N% LSS 40 goto waitmysql

echo [MySQL] start failed. Check %MYSQL_INI% and the data folder.
exit /b 1
