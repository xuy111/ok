@echo off
chcp 936 >nul
call "%~dp0env.bat"
title ???????????? - ??????

echo ==================================================
echo   ?????????
echo ==================================================
echo  ???????%ROOT%
echo  MySQL   ??%MYSQL_HOME%
echo  Java    ??%JAVA%
echo  Maven   ??%MVN%
echo  npm     ??%NPM%
echo --------------------------------------------------

netstat -ano | findstr ":3306 " | findstr "LISTENING" >nul 2>nul
if errorlevel 1 (echo  [3306 MySQL ] ¦Ä????) else (echo  [3306 MySQL ] ??????)

netstat -ano | findstr ":%BACKEND_PORT% " | findstr "LISTENING" >nul 2>nul
if errorlevel 1 (echo  [%BACKEND_PORT% ???  ] ¦Ä????) else (echo  [%BACKEND_PORT% ???  ] ??????  http://localhost:%BACKEND_PORT%)

netstat -ano | findstr ":%FRONTEND_PORT% " | findstr "LISTENING" >nul 2>nul
if errorlevel 1 (echo  [%FRONTEND_PORT% ???  ] ¦Ä????) else (echo  [%FRONTEND_PORT% ???  ] ??????  http://localhost:%FRONTEND_PORT%)

echo --------------------------------------------------
pause
