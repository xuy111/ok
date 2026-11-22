@echo off
rem ============================================================
rem  ???????????????????? call ?????
rem  ??????????????¡¤????¦Ë????????
rem        ?????? node_modules / target????????????¦Ï??????????
rem  ?????
rem    1) ???????????? GBK + CRLF ???§µ????? cmd ???????
rem    2) npm / mvn ?????????"????¡¤??"??????????????????????
rem       ???? npm.cmd ????? %~dp0 ???§¹???? MODULE_NOT_FOUND
rem ============================================================
chcp 936 >nul

set "ROOT=%~dp0.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"

rem ---------- JDK ----------
for /d %%D in ("C:\Users\%USERNAME%\dev\jdk-21\jdk-*") do if exist "%%D\bin\java.exe" if not defined JAVA_HOME set "JAVA_HOME=%%D"
for /d %%D in ("C:\Program Files\Java\jdk*") do if exist "%%D\bin\java.exe" if not defined JAVA_HOME set "JAVA_HOME=%%D"
for /d %%D in ("C:\Program Files\Eclipse Adoptium\jdk*") do if exist "%%D\bin\java.exe" if not defined JAVA_HOME set "JAVA_HOME=%%D"
if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" set "JAVA=%JAVA_HOME%\bin\java.exe"
if not defined JAVA set "JAVA=java"

rem ---------- Maven???????????? mvn??????????????????????¡¤???? ----------
set "MVN="
for /f "delims=" %%P in ('where mvn.cmd 2^>nul') do if not defined MVN set "MVN=%%P"
for /d %%D in ("%USERPROFILE%\.m2\wrapper\dists\apache-maven-*") do for /d %%E in ("%%D\*") do if exist "%%E\bin\mvn.cmd" if not defined MVN set "MVN=%%E\bin\mvn.cmd"
for /d %%D in ("D:\IDEA\*") do if exist "%%D\plugins\maven\lib\maven3\bin\mvn.cmd" if not defined MVN set "MVN=%%D\plugins\maven\lib\maven3\bin\mvn.cmd"
for /f "delims=" %%P in ('where mvn.bat 2^>nul') do if not defined MVN set "MVN=%%P"
if not defined MVN if exist "%ROOT%\springBootTest\mvnw.cmd" set "MVN=%ROOT%\springBootTest\mvnw.cmd"

rem ---------- Node / npm???????? npm.cmd ??????¡¤???? ----------
set "NPM="
for /f "delims=" %%P in ('where npm.cmd 2^>nul') do if not defined NPM set "NPM=%%P"
if not defined NPM if exist "C:\Program Files\nodejs\npm.cmd" set "NPM=C:\Program Files\nodejs\npm.cmd"
if not defined NPM if exist "%USERPROFILE%\AppData\Roaming\npm\npm.cmd" set "NPM=%USERPROFILE%\AppData\Roaming\npm\npm.cmd"
for /d %%D in ("C:\Users\%USERNAME%\.workbuddy\binaries\node\versions\*") do if exist "%%D\npm.cmd" if not defined NPM set "NPM=%%D\npm.cmd"

rem ---------- MySQL 8??????—¨???????????????? ----------
set "MYSQL_HOME="
set "MYSQL_INI="
for /d %%D in ("C:\Users\%USERNAME%\dev\mysql8\mysql-*") do if exist "%%D\bin\mysqld.exe" if not defined MYSQL_HOME set "MYSQL_HOME=%%D"
for /d %%D in ("C:\Program Files\MySQL\MySQL Server 8*") do if exist "%%D\bin\mysqld.exe" if not defined MYSQL_HOME set "MYSQL_HOME=%%D"
for /d %%D in ("D:\mysql*") do if exist "%%D\bin\mysqld.exe" if not defined MYSQL_HOME set "MYSQL_HOME=%%D"

if exist "C:\Users\%USERNAME%\dev\mysql8\my.ini" set "MYSQL_INI=C:\Users\%USERNAME%\dev\mysql8\my.ini"
if not defined MYSQL_INI if defined MYSQL_HOME if exist "%MYSQL_HOME%\my.ini" set "MYSQL_INI=%MYSQL_HOME%\my.ini"
if not defined MYSQL_INI if defined MYSQL_HOME if exist "%MYSQL_HOME%\..\my.ini" set "MYSQL_INI=%MYSQL_HOME%\..\my.ini"

if defined MYSQL_HOME set "MYSQLD=%MYSQL_HOME%\bin\mysqld.exe"
if defined MYSQL_HOME set "MYSQL_EXE=%MYSQL_HOME%\bin\mysql.exe"
if defined MYSQL_HOME set "MYSQLADMIN=%MYSQL_HOME%\bin\mysqladmin.exe"

rem ---------- ???¡¤?? ----------
set "BACKEND=%ROOT%\springBootTest"
set "FRONTEND=%ROOT%\doupo-frontend"
set "SQLFILE=%ROOT%\sql\doupo.sql"
set "JARFILE=%BACKEND%\target\springBootTest-0.0.1-SNAPSHOT.jar"
set "BACKEND_PORT=8080"
set "FRONTEND_PORT=5173"
set "DB_USER=root"
set "DB_PASS=123456"

exit /b 0
