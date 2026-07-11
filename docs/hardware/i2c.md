# Jetson I2C 与 Adafruit ServoKit 安装配置记录

本文档整理 Jetson 设备上检查 I2C、判断是否需要启用接口，以及安装 `adafruit_servokit` 的操作步骤。

## 1. 检查系统中已有的 I2C 总线

先安装常用工具：

```bash
sudo apt update
sudo apt install -y i2c-tools python3-pip python3-venv git
```

加载 I2C 用户态设备模块：

```bash
sudo modprobe i2c-dev
```

检查系统中是否已经有 I2C 设备节点：

```bash
ls -l /dev/i2c*
```

查看 I2C 总线列表：

```bash
i2cdetect -l
```

如果能看到类似下面的输出，说明系统已经注册了 I2C 总线：

```text
/dev/i2c-0
/dev/i2c-1
/dev/i2c-7
```

注意：`/dev/i2c-1` 中的 `1` 不一定等于硬件文档里的 I2C1，需要结合 Jetson 型号和 `i2cdetect -l` 输出判断。

## 2. Jetson-IO 页面中是否需要选择功能

如果进入 Jetson-IO 后看到类似这些选项：

```text
aud
extperiph3_clk
extperiph4_clk
i2s2
pwm1
pwm5
pwm7
spi1
spi3
uart-cts/rts
```

这些都不是 I2C。

含义大致如下：

| 选项 | 含义 |
| --- | --- |
| `i2s2` | 音频 I2S 接口 |
| `pwm1` / `pwm5` / `pwm7` | PWM 输出 |
| `spi1` / `spi3` | SPI 总线 |
| `uart-cts/rts` | UART 串口硬件流控 |
| `aud` / `extperiph*_clk` | 音频或外设时钟相关功能 |

如果目标是使用 I2C 设备，不需要勾选这些选项。

截图里没有 `i2c` 选项，通常说明：

1. 40-pin 上的 I2C 已经默认启用；
2. 当前板子的 I2C 不是通过 Jetson-IO 这个页面切换；
3. 需要通过设备树或 pinmux 配置，但这通常是自定义载板才需要。

## 3. 扫描 I2C 设备

接好 I2C 设备后，先确认接线：

| Jetson | I2C 设备 |
| --- | --- |
| `3.3V` | `VCC` |
| `GND` | `GND` |
| `SDA` | `SDA` |
| `SCL` | `SCL` |

然后扫描常见总线：

```bash
sudo i2cdetect -r -y 1
```

如果没有发现设备，可以根据 `i2cdetect -l` 的结果尝试其他总线，例如：

```bash
sudo i2cdetect -r -y 0
sudo i2cdetect -r -y 7
```

如果使用的是 Adafruit PCA9685 舵机驱动板，默认地址通常是：

```text
0x40
```

扫描结果中看到 `40`，通常表示 PCA9685 已被识别。

## 4. 安装 Adafruit ServoKit

Python 导入名是：

```python
from adafruit_servokit import ServoKit
```

但 pip 安装包名是：

```text
adafruit-circuitpython-servokit
```

直接安装：

```bash
python3 -m pip install adafruit-blinka
python3 -m pip install adafruit-circuitpython-servokit
```

安装完成后测试导入：

```bash
python3 -c "from adafruit_servokit import ServoKit; print('ServoKit OK')"
```

如果输出：

```text
ServoKit OK
```

说明安装成功。

## 5. 如果 pip 报 externally-managed-environment

部分系统不允许直接向系统 Python 安装包，可能出现 `externally-managed-environment` 报错。

这种情况下建议使用虚拟环境：

```bash
python3 -m venv ~/servokit-env
source ~/servokit-env/bin/activate
pip install adafruit-blinka adafruit-circuitpython-servokit
```

以后运行程序前先进入虚拟环境：

```bash
source ~/servokit-env/bin/activate
python3 your_script.py
```

## 6. ServoKit 简单测试程序

如果 I2C 能扫描到 PCA9685，例如地址为 `0x40`，可以创建测试脚本：

```python
from adafruit_servokit import ServoKit

kit = ServoKit(channels=16)

kit.servo[0].angle = 90
```

运行：

```bash
python3 your_script.py
```

如果遇到 I2C 权限问题，可以先用 sudo 测试：

```bash
sudo python3 your_script.py
```

更长期的做法是把当前用户加入 I2C 相关用户组，具体组名以系统为准。

## 7. 常见问题

### 7.1 找不到 `/dev/i2c*`

先执行：

```bash
sudo modprobe i2c-dev
ls -l /dev/i2c*
```

如果仍然没有，说明当前系统没有启用对应 I2C 控制器，或者设备树/pinmux 未配置好。

### 7.2 Jetson-IO 里没有 I2C 选项

这是常见情况。不要选择 `spi`、`pwm`、`i2s` 来代替 I2C。

应先用下面命令确认系统是否已有 I2C 总线：

```bash
ls -l /dev/i2c*
i2cdetect -l
```

### 7.3 `i2cdetect` 扫不到设备

检查以下内容：

1. 设备是否供电；
2. `SDA` 和 `SCL` 是否接反；
3. 是否共地；
4. I2C 设备是否只支持 3.3V 或 5V；
5. 是否有上拉电阻；
6. 是否扫描了正确的 I2C bus；
7. 设备地址是否和默认地址不同。

### 7.4 不建议直接使用 Raspberry Pi 的 `dtoverlay`

Jetson 与 Raspberry Pi 的设备树加载方式不同。

在 Jetson 上通常使用：

```bash
sudo /opt/nvidia/jetson-io/jetson-io.py
```

或根据 Jetson Linux 文档配置 DTB/DTBO 与 `/boot/extlinux/extlinux.conf`。

不要直接照搬：

```bash
dtoverlay -d /boot/dtb/overlay i2cX
```

这通常不是 Jetson 的正确操作方式。

## 8. 推荐执行顺序

完整流程建议如下：

```bash
sudo apt update
sudo apt install -y i2c-tools python3-pip python3-venv git
sudo modprobe i2c-dev

ls -l /dev/i2c*
i2cdetect -l
sudo i2cdetect -r -y 1

python3 -m pip install adafruit-blinka
python3 -m pip install adafruit-circuitpython-servokit

python3 -c "from adafruit_servokit import ServoKit; print('ServoKit OK')"
```

如果 `pip install` 报错，则改用虚拟环境：

```bash
python3 -m venv ~/servokit-env
source ~/servokit-env/bin/activate
pip install adafruit-blinka adafruit-circuitpython-servokit
python3 -c "from adafruit_servokit import ServoKit; print('ServoKit OK')"
```
