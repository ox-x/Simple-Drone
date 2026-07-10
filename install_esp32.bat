@echo off
chcp 65001 >nul 2>&1
title CF-Drone 离线安装 ESP32 工具链
echo ============================================
echo  ESP32 工具链安装（带自动重试）
echo ============================================
echo.
echo 当前时间：%TIME%
echo.
echo 步骤说明：
echo 1. 使用 PowerShell 下载（比 arduino-cli 更稳定）
echo 2. 需要从 GitHub 下载约 200MB 文件，请耐心等待
echo 3. 如果网络不通，请开启 VPN/代理后再试
echo.

set CLI=d:\Downloads\CF-Drone-main\arduino-cli\arduino-cli.exe

echo [1/3] 使用 PowerShell 下载 GDB 工具（32MB）...
echo     如果下载超时，请开启 VPN 或使用手机热点
del /f C:\Users\admin\AppData\Local\Arduino15\staging\packages\xtensa-esp-elf-gdb-16.3_20250913-x86_64-w64-mingw32.zip 2>nul

powershell -Command "$ProgressPreference='SilentlyContinue'; $url='https://github.com/espressif/crosstool-NG/releases/download/esp-14.2.0_20260121/xtensa-esp-elf-gdb-16.3_20250913-x86_64-w64-mingw32.zip'; $out='C:\Users\admin\AppData\Local\Arduino15\staging\packages\xtensa-esp-elf-gdb-16.3_20250913-x86_64-w64-mingw32.zip'; $retry=3; while($retry -gt 0){ try{ Invoke-WebRequest -Uri $url -OutFile $out -TimeoutSec 300; Write-Host '下载成功!'; break } catch{ $retry--; Write-Host ('下载失败('+$retry+'次重试剩余): '$_.Exception.Message); Start-Sleep 3 } }"

if not exist C:\Users\admin\AppData\Local\Arduino15\staging\packages\xtensa-esp-elf-gdb-16.3_20250913-x86_64-w64-mingw32.zip (
    echo.
    echo 下载失败！请检查网络后重试。
    pause
    exit /b 1
)

echo.
echo [2/3] 安装 ESP32 核心库...
%CLI% core install esp32:esp32
if errorlevel 1 (
    echo 安装失败！请检查网络后重试。
    pause
    exit /b 1
)

echo.
echo [3/3] 验证安装...
%CLI% core list
echo.

echo ============================================
echo  ESP32 工具链安装完成！
echo.
echo  下一步：运行 compile_upload.bat 编译烧录
echo  COM口请选择：COM3
echo ============================================
pause
