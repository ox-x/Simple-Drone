@echo off
chcp 65001 >nul 2>&1
title CF-Drone 串口监视器
set CLI=d:\Downloads\CF-Drone-main\arduino-cli\arduino-cli.exe

echo ============================================
echo   CF-Drone 串口监视器
echo   波特率: 115200
echo ============================================
echo.

echo [1/2] 检测串口设备...
%CLI% board list
echo.

set /p PORT=请输入 ESP32 串口地址（如 COM3），然后按回车: 

if "%PORT%"=="" (
    echo 错误：未输入串口地址
    pause
    exit /b 1
)

echo.
echo [2/2] 打开串口监视器...
echo   输入 help 查看所有命令
echo   按 Ctrl+C 退出
echo.
%CLI% monitor -p %PORT% -c baudrate=115200
pause
