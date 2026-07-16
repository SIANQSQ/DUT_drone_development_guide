@echo off
chcp 65001 >nul
:menu
echo ==============================
echo    Git 仓库代理管理工具
echo ==============================
echo 1. 设置代理
echo 2. 取消代理
echo 3. 退出
echo ==============================
set /p choice=请选择操作 (1/2/3):

if "%choice%"=="1" goto setproxy
if "%choice%"=="2" goto unsetproxy
if "%choice%"=="3" goto end
echo 无效选择，请重新输入。
goto menu

:setproxy
set /p port=请输入代理端口 (例如7897): 
if "%port%"=="" (
    echo 端口不能为空！
    goto menu
)
git config http.proxy http://127.0.0.1:%port%
git config https.proxy http://127.0.0.1:%port%
if %errorlevel% equ 0 (
    echo 代理已设置: http://127.0.0.1:%port%
) else (
    echo 设置代理失败！请确认当前目录是否为 Git 仓库。
)
goto menu

:unsetproxy
git config --unset http.proxy
git config --unset https.proxy
if %errorlevel% equ 0 (
    echo 代理已取消。
) else (
    echo 取消代理失败，可能未设置或当前目录不是 Git 仓库。
)
goto menu

:end
echo 再见！
pause