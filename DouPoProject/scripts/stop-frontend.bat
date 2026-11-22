@echo off
chcp 936 >nul
call "%~dp0env.bat"

set "POWERSHELL_EXE=powershell"
where pwsh >nul 2>nul
if not errorlevel 1 set "POWERSHELL_EXE=pwsh"

echo [???] ????????? %FRONTEND_PORT% ????? ...
%POWERSHELL_EXE% -NoProfile -Command "$p=(Get-NetTCPConnection -LocalPort %FRONTEND_PORT% -State Listen -ErrorAction SilentlyContinue).OwningProcess; if($p){$p|Select-Object -Unique|ForEach-Object{Write-Host ('  ????? PID ' + $_); Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue}}else{Write-Host '  ?????งา????'}"
echo [???] ????
exit /b 0
