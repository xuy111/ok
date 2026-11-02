@echo off
rem ============================================================
rem 海贼王登录系统 - 一键停止脚本
rem 功能: 按端口停止后端(8081)和前端(5173)进程，不影响 MySQL 服务
rem ============================================================
setlocal
cd /d "%~dp0"

echo ============================================================
echo   海贼王登录系统 - 停止前后端服务
echo ============================================================

set FOUND=0

rem ---- 停止后端 (端口 8081) ----
for /f "tokens=5" %%a in ('netstat -ano ^| findstr /r /c:":8081 .*LISTENING"') do (
    echo 正在停止后端进程 PID=%%a ...
    taskkill /F /T /PID %%a >nul 2>nul
    set FOUND=1
)

rem ---- 停止前端 (端口 5173) ----
for /f "tokens=5" %%a in ('netstat -ano ^| findstr /r /c:":5173 .*LISTENING"') do (
    echo 正在停止前端进程 PID=%%a ...
    taskkill /F /T /PID %%a >nul 2>nul
    set FOUND=1
)

if "%FOUND%"=="0" (
    echo 未发现运行中的前后端服务。
) else (
    echo 停止完成。MySQL 服务保持运行不受影响。
)
echo.
pause
