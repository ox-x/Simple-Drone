# XTX Drone - ESP32 无人机飞控固件

基于 ESP32 的微型四轴无人机飞控固件，支持 Web 遥控器、多飞行模式、MAVLink 地面站通讯。

## 硬件要求

| 芯片 | 推荐 |
|------|------|
| **ESP32** 经典款 | ✅ 默认配置，WiFi/WebRC 全开 |
| ESP32-S3 | ✅ 需 `board_config.h` 适配 |
| ESP32-C3 | ⚠️ 单核性能有限，WiFi 默认关闭 |

| 传感器 | 通信 |
|--------|------|
| MPU6500 | SPI |
| MPU9250 | SPI |
| BMP388 *(可选)* | I2C (GPIO21/22) |

## 功能特性

### 飞行控制
- **4 种模式**：`RAW`（直通）、`ACRO`（特技/角速率）、`STAB`（自稳/角度）、`AUTO`（自动）
- **串级 PID**：角度外环 + 角速率内环，三轴独立
- **推力映射**：`MOT_THR_MIN`/`MOT_THR_MAX` 限制油门范围
- **软件配平**：`CTL_TRIM_ROLL`/`CTL_TRIM_PITCH` 补偿漂移
- **电机混控**：X 型四轴布局，含饱和处理
- **缓降**：松油门后 2 秒线性缓降至怠速，再持续缓降（不自动上锁）

### 姿态估计
- 互补滤波（陀螺积分 + 加速度计重力修正）
- Mahony 风格水平修正
- 摇杆门控（打杆时衰减修正权重）
- 上电静止时自动学习陀螺偏置

### 翻转功能
- 网页一键翻转（🔁 按钮）
- 解锁且油门最低时触发
- 三阶段执行：弹跳 → ~160° 翻转 → STAB 回正 + 缓冲落地
- 翻转时自动切换 ACRO 模式，结束后恢复原模式
- 倒置保护在翻转中自动跳过

### Web 遥控器
- WiFi 热点 `Drone_WiFi`，浏览器访问 `http://192.168.4.1`
- 虚拟摇杆（油门/横滚/俯仰/偏航）
- 6 个功能按钮：解锁、切换模式、调试、上锁、急停、翻转
- 开屏动画
- 实时遥测显示（姿态/电池/连接状态）
- 调试控制台

### 遥控输入
- 支持 CRSF/ELRS（420000 baud）和 SBUS（100000 baud）
- 8 步交互式通道校准
- 手势解锁/上锁（油门最低 + 偏航最左/最右）

### CLI 命令行
| 命令 | 说明 |
|------|------|
| `help` | 显示帮助 |
| `p` | 显示所有参数 |
| `p <name>` | 显示指定参数 |
| `p <name> <value>` | 设置参数 |
| `preset` | 恢复默认参数并重启 |
| `arm` / `disarm` | 解锁 / 上锁 |
| `stop` | 上锁（同 disarm） |
| `raw` / `acro` / `stab` / `auto` | 切换飞行模式 |
| `mfr` / `mfl` / `mrr` / `mrl` | 电机测试 |
| `ca` | 加速度计六面标定 |
| `cr` | RC 遥控器校准 |
| `ps` / `psq` | 显示姿态（欧拉角/四元数） |
| `imu` | 显示 IMU 状态 |
| `rc` | 显示 RC 通道值 |
| `mot` | 显示电机输出 |
| `wifi` | 显示 WiFi 状态 |
| `ap <ssid> <pwd>` | 配置 AP 模式 |
| `sta <ssid> <pwd>` | 配置 STA 模式 |
| `time` | 显示运行时间 |
| `sys` | 显示系统信息 |
| `log` / `log dump` | 日志操作 |
| `fliplog` | 导出翻转调试日志 |
| `reset` | 重置姿态 |
| `reboot` | 重启 |

### LED 状态指示

| 状态 | LED | 条件 |
|------|-----|------|
| 待机 | 常灭 | 未解锁，电压正常 |
| 待机低电 | 快闪 8Hz | 未解锁，电压 < 3.5V |
| 正常飞行 | 慢闪 1Hz | 已解锁，无告警 |
| 飞行告警 | 快闪 8Hz | 倒置 / RC 失联 / Web RC 失联 / 电池低压 |

### 故障保护
- **RC 失联**：超时自动平滑降落
- **Web RC 失联**：>8 秒无心跳启动降落
- **倒置保护**：倾角超 134° 持续 1.5 秒停机
- **电池低压保护**：三级保护（禁止解锁 → 告警 → 自动降落）

### 通讯
- **MAVLink**：兼容 QGroundControl（心跳/姿态/IMU/参数/命令）
- **WiFi**：AP / STA 模式，UDP 通讯

## 开发环境搭建

### Arduino IDE
1. 安装 Arduino IDE 2.3.x+
2. **文件 → 首选项** → 附加开发板管理器网址：
```
https://espressif.github.io/arduino-esp32/package_esp32_index.json
```
3. **工具 → 开发板管理器** → 搜索安装 `esp32 by Espressif Systems`
4. **工具 → 库管理器** → 搜索安装 `MAVLink`
5. 打开 `CF-Drone.ino`，选择 `ESP32 Dev Module`，上传

### 命令行（arduino-cli）
```bash
# 安装 ESP32 核心
arduino-cli core update-index
arduino-cli core install esp32:esp32

# 安装 MAVLink 库
arduino-cli lib install MAVLink

# 编译
cd CF-Drone
arduino-cli compile --fqbn esp32:esp32:esp32

# 烧录（COM3 为例）
arduino-cli upload --fqbn esp32:esp32:esp32 -p COM3
```

## 固件烧录

使用 esptool 直接烧录合并固件：
```bash
esptool write_flash 0x0 firmware/CF-Drone.ino.merged.bin
```

## 首次使用

1. 烧录固件后连接串口（115200 baud）
2. 输入 `ca` 执行加速度计六面标定
3. 输入 `cr` 执行 RC 校准（若使用物理遥控器）
4. 手机连接 `Drone_WiFi`（密码 `12345678`）
5. 浏览器访问 `http://192.168.4.1`
6. 点击 🔓 解锁 → 推油门起飞

## 参数

90+ 参数可通过 CLI / Web / MAVLink 修改，涵盖 PID、电机、RC、IMU、WiFi、故障保护等，存储于 NVS 断电不丢失。

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.1 | 2026-07 | 翻转功能完善、缓冲落地优化、调试日志系统 |
| v1.0 | 2026-07 | 缓降、开屏动画、按钮重排、stop指令、Web按钮修复 |
| - | 2026-05 | 优化姿态控制 |
| - | 2026-05 | 适配 ESP32-C3，优化 PWM 频率 |
| - | 2026-04 | 重构 Web 遥控器、LED 状态提示、倒置保护、电池保护 |

## 开源许可

基于琛光无人机开源项目修改。
