@echo off
rem ============================================================
rem 海贼王登录系统 - 一键启动脚本
rem 功能: 初始化数据库(仅首次) + 构建并启动后端(8081) + 安装依赖并启动前端(5173)
rem 说明: node_modules 和 target 目录每次开机会被清除，本脚本会自动重新安装/构建
rem ============================================================
setlocal enabledelayedexpansion
cd /d "%~dp0"

rem ---- 清除可能干扰的环境变量（WorkBuddy 沙箱会注入 SERVER__PORT 覆盖端口）----
set SERVER__PORT=
set SERVER__HOST=

echo ============================================================
echo   海贼王登录系统 - 一键启动
echo   后端: Spring Boot + MyBatis-Plus    端口 8081
echo   前端: Vue 3 + Vite                  端口 5173
echo ============================================================
echo.

rem ---- 工具路径（本机环境）----
set "MYSQL=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
set "MVN=C:\Users\Administrator\.m2\wrapper\dists\apache-maven-3.9.9-bin\4nf9hui3q3djbarqar9g711ggc\apache-maven-3.9.9\bin\mvn.cmd"

rem ---- 1. 检查/启动 MySQL 服务 ----
echo [1/4] 检查 MySQL 服务...
"%MYSQL%" -uroot -p123456 -e "SELECT 1" >nul 2>nul
if errorlevel 1 (
    echo       MySQL 未运行，尝试启动 MySQL80 服务（可能需要管理员权限）...
    net start MySQL80 >nul 2>nul
    timeout /t 3 /nobreak >nul
    "%MYSQL%" -uroot -p123456 -e "SELECT 1" >nul 2>nul
    if errorlevel 1 (
        echo       [错误] 无法连接 MySQL，请手动启动 MySQL80 服务后重试！
        pause
        exit /b 1
    )
)
echo       MySQL 连接正常

rem ---- 2. 初始化数据库（库不存在时才执行，不丢数据）----
echo [2/4] 检查数据库 onepiece...
"%MYSQL%" -uroot -p123456 -N -e "SHOW DATABASES LIKE 'onepiece'" 2>nul | findstr /i "onepiece" >nul
if errorlevel 1 (
    echo       数据库不存在，执行初始化脚本 sql\onepiece.sql ...
    "%MYSQL%" -uroot -p123456 --default-character-set=utf8mb4 < "%~dp0sql\onepiece.sql" 2>nul
    if errorlevel 1 (
        echo       [错误] 数据库初始化失败！
        pause
        exit /b 1
    )
    echo       数据库初始化完成
) else (
    echo       数据库已存在，跳过初始化
)

rem ---- 3. 后端: 缺 jar 则构建，然后启动 ----
echo [3/4] 启动后端 springBootTest...
if not exist "%~dp0springBootTest\target\springBootTest-0.0.1-SNAPSHOT.jar" (
    echo       未找到 jar 包（target 被清除），开始 Maven 构建，请耐心等待...
    pushd "%~dp0springBootTest"
    call "%MVN%" -DskipTests clean package
    if errorlevel 1 (
        echo       [错误] Maven 构建失败！请检查 Maven 路径: %MVN%
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
    echo       未找到 node_modules（已被清除），开始 npm install，请耐心等待...
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
echo   启动完成！
echo   后端接口: http://localhost:8081/api/user/ping
echo   前端页面: http://localhost:5173   (Vite 会自动打开浏览器)
echo   测试账号: luffy / 123456
echo   停止项目: 双击运行 停止项目.bat
echo ============================================================
pause
