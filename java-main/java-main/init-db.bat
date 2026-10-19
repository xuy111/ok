@echo off
REM ============================================================
REM  初始化 MySQL 数据库 springboot_test（建库 + user 表）
REM  编码：GBK    账号 root / 123456（密码不同请改下面 MYSQL_PWD）
REM  说明：本脚本幂等，可每次开机重复执行（已存在则跳过）
REM ============================================================
set "MYSQL=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
set "MYSQL_PWD=123456"
set "ROOT=%~dp0"

if not exist "%MYSQL%" (
    echo [错误] 未找到 mysql.exe，请修改本脚本中的 MYSQL 路径
    pause
    exit /b 1
)

echo [初始化] 执行 sql/init.sql 创建数据库与表 ...
"%MYSQL%" -uroot -p%MYSQL_PWD% < "%ROOT%springBootTest\sql\init.sql"
echo [完成] 数据库 springboot_test 已就绪（若已存在则自动跳过）。
