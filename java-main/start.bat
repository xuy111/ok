@echo off
REM ============================================================
REM  java-main 一键启动脚本（后端 Spring Boot + 前端 Vue）
REM  编码：GBK    路径：相对路径（基于本脚本所在目录）
REM  说明：每次开机 node_modules / target 会被清空，
REM        本脚本在运行时重建它们，启动前不依赖这两个目录。
REM  前置：1) MySQL 已启动且库 springboot_test 已建（见 init-db.bat）
REM        2) 已联网（首次会下载 Maven / npm 依赖，之后走缓存）
REM ============================================================
setlocal
set "ROOT=%~dp0"

echo ============================================
echo  [启动] java-main（后端 + 前端）
echo ============================================

REM ---------- 1. 后端 Spring Boot（端口 8081）----------
echo [1/2] 启动后端 springBootTest（mvnw spring-boot:run）...
start "SpringBoot-Backend" cmd /k "cd /d %ROOT%springBootTest && call mvnw.cmd spring-boot:run"

REM 给后端一点编译/启动时间
timeout /t 20 /nobreak >nul

REM ---------- 2. 前端 Vue（端口 5173）----------
echo [2/2] 安装依赖并启动前端 shinchan-vue（npm install + vite）...
start "ShinchanVue-Frontend" cmd /k "cd /d %ROOT%shinchan-vue\shinchan-vue && call npm install && call npm run dev -- --port 5173"

echo ============================================
echo  后端窗口：SpringBoot-Backend
echo  前端窗口：ShinchanVue-Frontend
echo  后端地址：http://127.0.0.1:8081
echo  前端地址：http://127.0.0.1:5173
echo  停止请运行 stop.bat
echo ============================================
endlocal
