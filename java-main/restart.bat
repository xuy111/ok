@echo off
REM ============================================================
REM  java-main 重启脚本（先停后启）
REM  编码：GBK
REM ============================================================
call "%~dp0stop.bat"
timeout /t 3 /nobreak >nul
call "%~dp0start.bat"
