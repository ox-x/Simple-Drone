@echo off
chcp 65001 >nul 2>&1
title CF-Drone 编译与烧录
set CLI=d:\Downloads\CF-Drone-main\arduino-cli\arduino-cli.exe
set SKETCH=d:\Downloads\CF-Drone-main\CF-Drone.ino

echo ============================================
echo   CF-Drone 编译与烧录
echo ============================================
echo.

echo [1/3] 检测串口设备...
%CLI% board list
echo.

set /p PORT=请输入 ESP32 串口地址（如 COM3），然后按回车: 

if "%PORT%"=="" (
    echo 错误：未输入串口地址
    pause
    exit /b 1
)

echo.
echo [2/3] 编译项目（ESP32 Dev Module）...
%CLI% compile --fqbn esp32:esp32:esp32 --library "%~dp0drivers" "%SKETCH%"
if errorlevel 1 (
    echo.
    echo 编译失败！请检查错误信息。
    pause
    exit /b 1
)
echo     编译成功
echo.

echo [3/3] 烧录到 ESP32（端口: %PORT%）...
%CLI% upload -p %PORT% --fqbn esp32:esp32:esp32 --library "%~dp0drivers" "%SKETCH%"
if errorlevel 1 (
    echo.
    echo 烧录失败！请检查：
    echo   - ESP32 是否已通过 USB 连接
    echo   - 串口是否被其他程序占用
    echo   - 是否需要按住 BOOT 键
    pause
    exit /b 1
)

echo.
echo ============================================
echo   烧录成功！
echo.
echo   串口监视器：运行 monitor.bat
echo   或用 Arduino IDE 串口监视器，波特率 115200
echo ============================================
pause
