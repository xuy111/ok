@echo off
rem ============================================================
rem 海贼王登录系统 - 一键启动（自适应路径版）
rem 2026-11-10 修复：Maven / MySQL 路径不再写死为其他电脑的绝对路径，
rem                 改为按本机实际安装位置自动探测。
rem 原版已备份为 启动项目.bat.bak
rem ============================================================
setlocal enabledelayedexpansion
cd /d "%~dp0"

rem ---- 清除可能干扰的环境变量 ----
set "SERVER__PORT="
set "SERVER__HOST="

echo ============================================================
echo   海贼王登录系统 - 一键启动
echo   后端: Spring Boot + MyBatis-Plus    端口 8081
echo   前端: Vue 3 + Vite                  端口 5173
echo ============================================================
echo.
echo [提示] 前端源码已补齐（Home.vue / AdminLogin.vue / Admin.vue）。
echo        数据库使用本机免安装 MariaDB，脚本会自动检测并拉起。
echo.

rem ---- 0. 探测本机工具链 ----
echo [0/4] 检查本机运行环境...

where java >nul 2>nul
if errorlevel 1 (
    echo       [错误] 未找到 java，请安装 JDK 17+ 并加入 PATH
    pause
    exit /b 1
)

rem Maven: 优先本机 .m2 的 wrapper 缓存，其次 PATH
set "MVN="
if exist "%USERPROFILE%\.m2\wrapper\dists" (
    for /f "delims=" %%i in ('dir /s /b "%USERPROFILE%\.m2\wrapper\dists\mvn.cmd" 2^>nul') do set "MVN=%%i"
)
if not defined MVN (
    for /f "delims=" %%i in ('where mvn.cmd 2^>nul') do set "MVN=%%i"
)
if not defined MVN (
    echo       [错误] 未找到 Maven，请安装 Maven 3.9+ 或让 IDEA 下载依赖
    pause
    exit /b 1
)
echo       Maven: !MVN!

rem 数据库: 优先使用本机随项目附带的免安装 MariaDB，其次 PATH / 常见安装目录
set "MYSQL="
set "MARIADB_BIN="
set "MARIADB_INI="
if exist "%USERPROFILE%\mariadb-portable\mariadb-11.4.13-winx64\bin\mysql.exe" (
    set "MARIADB_BIN=%USERPROFILE%\mariadb-portable\mariadb-11.4.13-winx64\bin"
    set "MARIADB_INI=%USERPROFILE%\mariadb-portable\my.ini"
    set "MYSQL=%USERPROFILE%\mariadb-portable\mariadb-11.4.13-winx64\bin\mysql.exe"
)
if not defined MYSQL (
    for /f "delims=" %%i in ('where mysql 2^>nul') do set "MYSQL=%%i"
)
if not defined MYSQL if exist "C:\Program Files\MySQL" (
    for /f "delims=" %%i in ('dir /s /b "C:\Program Files\MySQL\mysql.exe" 2^>nul') do set "MYSQL=%%i"
)
if defined MYSQL (
    echo       数据库客户端: !MYSQL!
) else (
    echo       [警告] 未找到数据库客户端，登录/注册会失败。
)

rem ---- 1. 检查并拉起数据库服务 ----
echo [1/4] 检查数据库服务（3306）...
set "DBOK="
if defined MYSQL (
    "!MYSQL!" -uroot -p123456 -h127.0.0.1 -e "SELECT 1" >nul 2>nul
    if not errorlevel 1 set "DBOK=1"
)
if not defined DBOK if defined MARIADB_BIN (
    echo       免安装 MariaDB 未运行，正在启动...
    start "onepiece-mariadb" /D "!MARIADB_BIN!" mysqld.exe --defaults-file="!MARIADB_INI!" --console
    for /l %%t in (1,1,15) do (
        if not defined DBOK (
            timeout /t 1 /nobreak >nul
            "!MYSQL!" -uroot -p123456 -h127.0.0.1 -e "SELECT 1" >nul 2>nul
            if not errorlevel 1 set "DBOK=1"
        )
    )
)
if not defined DBOK (
    echo       尝试启动系统 MySQL80 服务（可能需要管理员权限）...
    net start MySQL80 >nul 2>nul
    timeout /t 2 /nobreak >nul
    if defined MYSQL (
        "!MYSQL!" -uroot -p123456 -h127.0.0.1 -e "SELECT 1" >nul 2>nul
        if not errorlevel 1 set "DBOK=1"
    )
)
if defined DBOK (
    echo       数据库连接正常（root / 123456）
) else (
    echo       [警告] 数据库连不上，登录/注册会失败；可先双击 启动数据库.bat
)

rem ---- 2. 初始化数据库（仅库不存在时）----
echo [2/4] 检查数据库 onepiece...
if defined DBOK (
    "!MYSQL!" -uroot -p123456 -h127.0.0.1 -N -e "SHOW DATABASES LIKE 'onepiece'" 2>nul | findstr /i "onepiece" >nul
    if errorlevel 1 (
        echo       数据库不存在，执行初始化脚本 sql\onepiece.sql ...
        "!MYSQL!" -uroot -p123456 -h127.0.0.1 --default-character-set=utf8mb4 < "%~dp0sql\onepiece.sql" >nul 2>nul
        if errorlevel 1 echo       [警告] 数据库初始化失败，请手动导入 sql\onepiece.sql
    ) else (
        echo       数据库已存在，跳过初始化
    )
) else (
    echo       跳过（数据库不可用）
)

rem ---- 3. 后端: 缺 jar 则构建，然后启动 ----
echo [3/4] 启动后端 springBootTest...
if not exist "%~dp0springBootTest\target\springBootTest-0.0.1-SNAPSHOT.jar" (
    echo       未找到 jar 包，开始 Maven 构建，请耐心等待...
    pushd "%~dp0springBootTest"
    call "!MVN!" -DskipTests clean package
    if errorlevel 1 (
        echo       [错误] Maven 构建失败！
        popd
        pause
        exit /b 1
    )
    popd
) else (
    echo       jar 包已存在，跳过构建
)
start "onepiece-backend" cmd /k "java -jar "%~dp0springBootTest\target\springBootTest-0.0.1-SNAPSHOT.jar" --server.port=8081"

rem ---- 4. 前端: 缺 node_modules 则安装，然后启动 ----
echo [4/4] 启动前端 onepiece-login...
if not exist "%~dp0new-java-main\onepiece-login\node_modules" (
    echo       未找到 node_modules，开始 npm install，请耐心等待...
    pushd "%~dp0new-java-main\onepiece-login"
    call npm install
    if errorlevel 1 (
        echo       [错误] npm install 失败！
        popd
        pause
        exit /b 1
    )
    popd
) else (
    echo       node_modules 已存在，跳过安装
)
start "onepiece-frontend" cmd /k "cd /d "%~dp0new-java-main\onepiece-login" && npm run dev"

echo.
echo ============================================================
echo   启动命令已下发
echo   后端接口: http://localhost:8081/api/user/ping
echo   前端页面: http://localhost:5173
echo   测试账号: luffy / 123456    后台: admin / admin123
echo   数据库: 127.0.0.1:3306 / onepiece / root / 123456
echo   停止项目: 双击运行 停止项目.bat
echo ============================================================
pause
