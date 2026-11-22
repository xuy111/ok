@echo off
chcp 936 >nul
title ???????????? - ?????

echo ==================================================
echo   ?? ??? / ??? / MySQL
echo ==================================================

call "%~dp0stop-frontend.bat"
call "%~dp0stop-backend.bat"
call "%~dp0stop-mysql.bat"

echo.
echo ???????
pause
