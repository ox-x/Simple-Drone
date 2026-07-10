@echo off
chcp 65001 >nul 2>&1
title CF-Drone ESP32 开发环境一键配置
set CLI=d:\Downloads\CF-Drone-main\arduino-cli\arduino-cli.exe

echo ============================================
echo   CF-Drone ESP32 开发环境一键配置脚本
echo   芯片: ESP32 / IMU: MPU6500 / 轴距: 118mm
echo ============================================
echo.

echo [1/5] 初始化 arduino-cli 配置...
%CLI% config init --overwrite >nul 2>&1
%CLI% config set board_manager.additional_urls https://espressif.github.io/arduino-esp32/package_esp32_index.json
echo     完成
echo.

echo [2/5] 更新开发板索引...
%CLI% core update-index
echo     完成
echo.

echo [3/5] 安装 ESP32 核心库（约200-300MB，请耐心等待）...
%CLI% core install esp32:esp32
echo     完成
echo.

echo [4/5] 安装 MAVLink 依赖库...
%CLI% lib install "MAVLink"
echo     完成
echo.

echo [5/5] 验证安装结果...
echo.
echo --- 已安装的开发板 ---
%CLI% core list
echo.
echo --- 已安装的库 ---
%CLI% lib list
echo.

echo ============================================
echo   环境配置完成！
echo.
echo   下一步：
echo   1. 用 USB 线连接 ESP32
echo   2. 运行 compile_upload.bat 编译并烧录
echo   3. 或用 Arduino IDE 打开 CF-Drone.ino
echo.
echo   开发板选择: ESP32 Dev Module
echo   串口波特率: 115200
echo ============================================
pause
