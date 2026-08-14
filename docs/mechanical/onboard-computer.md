# Jetson Orin NX Super 16GB 机载计算机

本项目使用 NVIDIA Jetson Orin NX 16GB 模块作为机载计算机，运行 ROS 节点、MAVROS、视觉算法和任务控制程序。本文中的性能参数来自 NVIDIA 官方模块数据表；实际可用接口、散热器、供电接口和安装孔位取决于所使用的第三方载板。

!!! danger "供电边界"
    Jetson Orin NX 模块官方支持的输入电压范围为 **5–20V**。本项目的 6S 锂电池标称 22.2V、满电 25.2V，**禁止直接接入 Jetson**；必须通过 PMU 或 DC-DC 稳压模块降压后供电，并确认稳压器在 40W 峰值功耗下仍有余量。

## NVIDIA 官方规格

| 项目 | Jetson Orin NX 16GB Super |
| --- | --- |
| GPU | NVIDIA Ampere 架构，1024 CUDA 核心、32 Tensor 核心 |
| GPU 最高频率 | 1173MHz（MAXN_SUPER） |
| AI 性能 | 最高 157 TOPS（稀疏 INT8；官方产品页） |
| CPU | 8 核 Arm Cortex-A78AE v8.2 64 位 |
| CPU 最高频率 | 2GHz |
| 内存 | 16GB 128-bit LPDDR5 |
| 内存带宽 | 102.4GB/s |
| DLA | 2 个 NVDLA；MAXN_SUPER 最高频率约 1229MHz |
| 视频 | 支持 H.265、H.264、VP9、AV1 解码/编码；具体并发能力以数据表为准 |
| 摄像头接口 | 8 路 MIPI CSI-2，D-PHY 2.1 |
| 网络 | 10/100/1000 Ethernet MAC（PHY/接口由载板提供） |
| 外部存储 | 通过 PCIe x2 或 x4 接入 NVMe；模块本身不含 eMMC |
| 模块尺寸 | 69.6mm × 45mm |
| 连接器 | 260-pin SO-DIMM |
| 模块输入电压 | 5–20V |
| 功耗档位 | 10W、15W、25W；Super 模式增加 40W 档 |
| 工作温度（结温） | -25°C 至 105°C；SoC 降频温度为 99°C |

> **说明**：TOPS、频率和功耗是 NVIDIA 的上限或参考值，不等于所有应用都能达到的实测性能。载板、电源、散热、软件版本和负载会影响实际结果。

## 本项目集成建议

### 供电

推荐链路为：

```text
6S 电池（22.2V 标称 / 25.2V 满电）
        ↓
PMU / DC-DC 稳压（输出必须处于 5–20V）
        ↓
Jetson 载板电源输入
```

- 稳压模块的连续输出功率建议不低于 40W，并为启动浪涌、NVMe、USB 设备和风扇预留余量。
- 上电前用万用表确认输出电压和正负极；不要依据 XT60、USB-C 等插头外形判断电压是否兼容。
- Jetson 与飞控、传感器共地，具体接口和电平以载板原理图为准。

### 存储与系统

- 通过载板提供的 M.2 Key-M 或其他 PCIe 接口安装 NVMe；确认载板支持的尺寸和 PCIe 通道数。
- 本项目的系统安装章节使用 Jetson Linux 35.6.1（L4T Ubuntu 20.04）和项目自定义镜像。烧录时必须匹配载板型号、启动配置和引导版本，不能把开发套件命令直接套用到所有第三方载板。
- 系统启动后建议检查：

```bash
cat /etc/nv_tegra_release
sudo nvpmodel -q
tegrastats
```

`nvpmodel -q` 用于确认当前功耗模式，`tegrastats` 用于观察 CPU/GPU/内存占用和温度。切换到 `MAXN_SUPER` 前，应确认稳压器和散热系统满足 40W 档。

### 散热与安装

- Orin NX 模块的 105°C 是结温上限，不是允许机舱长期达到的环境温度；官方给出的 SoC 降频温度为 99°C。
- 载板、散热器和风扇应固定牢靠，避免螺丝、碳板或金属支架碰触模块焊盘和 SO-DIMM 连接器。
- 机舱应留出进出风路径；在高负载视觉任务下通过 `tegrastats` 检查温度和是否发生降频。
- 模块尺寸不等于整机外形尺寸，电池仓和机架设计应按实际载板、散热器、NVMe 和线缆的包络尺寸复核。

## 相关接口与文档

| 用途 | 项目文档 |
| --- | --- |
| Jetson 与飞控连接 | [线路连接说明](../hardware/wiring/wiring.md) |
| 系统烧录 | [引导烧录与系统安装](../software/system-install.md) |
| 自定义镜像 | [自定义系统镜像烧录](../jetson/custom-image.md) |
| ROS 环境 | [ROS 安装](../jetson/ros-install.md) |

## NVIDIA 官方来源

1. [Jetson Orin NX Series Modules Data Sheet（DS-10712-001）](https://developer.download.nvidia.com/assets/embedded/secure/jetson/orin_nx/docs/Jetson-Orin-NX-Series-Modules-Datasheet_DS-10712-001_v1.7.pdf)：模块性能、接口、尺寸、输入电压、功耗和温度规格。
2. [Jetson Linux Developer Guide：Power and Performance](https://docs.nvidia.com/jetson/archives/r39.2/DeveloperGuide/SD/PlatformPowerAndPerformance/JetsonOrinNanoSeriesJetsonOrinNxSeriesAndJetsonAgxOrinSeries.html)：Orin NX 16GB 与 16GB Super 的功耗模式、频率和 `MAXN_SUPER` 配置。
3. [NVIDIA Jetson Orin 产品规格页](https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/jetson-orin/)：Orin NX 16GB Super 的产品级 AI 性能、GPU、CPU 和内存对比规格。
4. [JetPack SDK 5.1.5](https://developer.nvidia.com/embedded/jetpack-sdk-515)：Jetson Linux 35.6.1 及 Orin NX 16GB 的 40W / `MAXN_SUPER` 支持说明。

