@echo off
REM ============================================================
REM  java-main 一键停止脚本
REM  编码：GBK    按端口结束进程（后端 8081 / 前端 5173）
REM ============================================================
echo [停止] 查找并结束 8081 / 5173 端口的进程 ...

REM 后端（8081）
for /f "tokens=5" %%a in ('netstat -ano ^| findstr /rc":8081[ ]" ^| findstr "LISTENING"') do (
    echo   结束后端进程 PID=%%a
    taskkill /PID %%a /F >nul 2>&1
)

REM 前端（5173）
for /f "tokens=5" %%a in ('netstat -ano ^| findstr /rc":5173[ ]" ^| findstr "LISTENING"') do (
    echo   结束前端进程 PID=%%a
    taskkill /PID %%a /F >nul 2>&1
)

echo [完成] 已尝试停止。残留的命令行窗口可手动关闭。
