@echo off
chcp 936 >nul
call "%~dp0env.bat"

rem 首次运行（或数据库被清）时自动导入 sql；已存在则跳过
if not defined MYSQL_EXE (
  echo [数据库] 未找到 mysql.exe，跳过检查
  exit /b 0
)
if not exist "%SQLFILE%" (
  echo [数据库] 未找到 SQL 文件：%SQLFILE%
  exit /b 1
)

"%MYSQL_EXE%" -u%DB_USER% -p%DB_PASS% -e "use doupo; select 1 from t_user limit 1;" >nul 2>nul
if not errorlevel 1 (
  echo [数据库] doupo 库已存在，跳过初始化
  exit /b 0
)

echo [数据库] 首次运行，正在导入建库脚本 ...
"%MYSQL_EXE%" -u%DB_USER% -p%DB_PASS% --default-character-set=utf8mb4 -e "source %SQLFILE:\=/%"
if errorlevel 1 (
  echo [数据库] 导入失败
  exit /b 1
)
echo [数据库] 导入完成
exit /b 0
