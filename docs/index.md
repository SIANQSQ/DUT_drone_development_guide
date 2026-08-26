# 多旋翼无人机开发文档

欢迎阅读 **大连理工大学航模协会多旋翼无人机开发指南**。本文档面向大连理工大学航模协会多旋翼无人机开发团队成员，系统性地介绍了多旋翼无人机的硬件配置、软件开发、仿真调试与实机飞行等全流程开发内容。

---

## 项目概述

本项目基于 **CUAV X25 EVO** 飞控与 **Jetson Orin NX** 机载计算机搭建的多旋翼无人机开发平台，使用 **ROS1 Noetic** + **PX4 Autopilot** 进行 Offboard 自主任务开发。

### 核心硬件

| 组件 | 型号 |
|------|------|
| 飞控 | CUAV X25 EVO |
| 机载计算机 | NVIDIA Jetson Orin NX |
| 电源模块 | PMU2 Lite |
| RTK 定位 | CUAV 2HP / 9PS RTK |
| 数传电台 | P8 / P9 数传 |

### 开发环境

| 项目 | 版本/工具 |
|------|----------|
| 操作系统 | Ubuntu 20.04 (L4T 35.6.1) |
| ROS 版本 | ROS1 Noetic |
| 飞控固件 | PX4 Autopilot |
| 仿真环境 | Gazebo (SITL) |
| 地面站 | QGroundControl / QSQ Groundcontrol |
| 编译器 | GCC / Catkin Tools |

---

## 文档导航

### :rocket: 快速开始

如果你是初次接触本项目，建议按以下顺序阅读：

1. **[环境部署](quickly_start/environment.md)** — 基础开发环境安装与配置
2. **[Gazebo 仿真](quickly_start/simulation.md)** — 仿真环境下的飞行调试
3. **[实机飞行](quickly_start/real_machine.md)** — 真机飞行的完整操作流程

---

### :wrench: 机械结构

- **[机体结构](mechanical/airframe.md)** — 无人机机架结构与装配
- **[机载计算机](mechanical/onboard-computer.md)** — Jetson 安装与固定

---

### :electric_plug: 硬件配置

#### 飞行控制器

- **[CUAV X25 EVO](hardware/flight_controller/cuav-x25-evo.md)** — 飞控介绍与配置

#### 数传电台

- **[P8 数传](hardware/radio/telemetry-p8.md)** — 远距离遥测通信
- **[P9 数传](hardware/radio/telemetry-p9.md)** — 远距离遥测通信

#### 传感器

- **[CUAV 2HP RTK](hardware/flight_controller/2hp-rtk.md)** — 高精度定位模块
- **[CUAV 9PS RTK](hardware/flight_controller/9ps-rtk.md)** — 高精度定位模块
- **[激光雷达](hardware/flight_controller/lidar.md)** — 避障与定高

#### 执行器

- **[舵机控制板](hardware/flight_controller/servo-controller.md)** — 舵机驱动控制
- **[舵机投放器](hardware/flight_controller/servo-dispenser.md)** — 物品投放机构
- **[电调](hardware/flight_controller/esc.md)** — 电机调速控制
- **[电机](hardware/flight_controller/motor.md)** — 动力系统

#### 电源

- **[PMU Lite](hardware/power/pmu-lite.md)** — 电源管理模块
- **[50PL_6S2P](hardware/power/50PL_6S2P.md)** — 动力电池
- **[格氏电池](hardware/power/geshi_battery.md)** — 动力电池

#### 机载计算机

- **[Jetson Orin NX](hardware/computer/jetson-orin-nx.md)** — 机载计算平台

#### 电源树

- **[电源树设计](hardware/power_tree/power-tree-design.md)** — 供电路由设计
- **[电源树连接](hardware/power_tree/power-tree-connection.md)** — 实际供电接线

#### 线路连接

- **[线路连接说明](hardware/wiring/wiring.md)** — 全系统接线总览

---

### :computer: 机载计算机配置

- **[引导烧录与系统安装](jetson/system-install.md)** — Jetson 系统烧录（L4T Ubuntu 20.04）
- **[自定义系统镜像烧录](jetson/custom-image.md)** — 预配置系统镜像烧录
- **[ROS 安装](jetson/ros-install.md)** — ROS1 Noetic 安装指南
- **[任务控制器](jetson/task-controller.md)** — Drone Task Controller 部署

---

### :package: 软件功能包

`px4_controller` 功能包包含以下核心节点：

- **[无人机状态机](software/px4_controller/state-machine.md)** — 飞行模式管理与状态切换
- **[PX4 接口](software/px4_controller/px4-interface.md)** — MAVLink 通信封装
- **[瞄准与跟踪](software/px4_controller/aiming-tracking.md)** — 基于视觉的目标跟踪
- **[侦察](software/px4_controller/detection.md)** — 目标检测与识别
- **[投放](software/px4_controller/throw.md)** — 投放机构控制
- **[位置发布](software/px4_controller/position-publish.md)** — 目标位置估计与发布

---

### :satellite: 自定义地面站软件

#### QSQ Groundcontrol

- **[软件简介](software/QSQ_Groundcontrol/introduction.md)** — 功能概述
- **[软件安装](software/QSQ_Groundcontrol/install.md)** — 安装步骤
- **[软件使用](software/QSQ_Groundcontrol/use.md)** — 操作指南
- **[更新日志](software/QSQ_Groundcontrol/changelog.md)** — 版本更新记录
- **[自定义开发](software/QSQ_Groundcontrol/development/build.md)** — 编译与运行

#### 其他工具

- **[无人机控制台](software/upper_machine/drone-console.md)** — 命令行控制工具
- **[数据遥测](software/upper_machine/data-telemetry.md)** — 飞行数据遥测工具

---

## 快速链接

- :globe_with_meridians: [项目文档网站](https://drone-dev.qsq.cool)
- :octocat: [GitHub 仓库](https://github.com/SIANQSQ/Drone_Task_Controller)
- :package: [固件源码下载](https://storage.qsq.cool/%E8%88%AA%E6%A8%A1%E7%A4%BE/%E9%A3%9E%E6%8E%A7%E5%9B%BA%E4%BB%B6/%E5%9B%BA%E4%BB%B6%E6%BA%90%E7%A0%81)
- :floppy_disk: [虚拟机镜像下载](https://storage.qsq.cool/%E8%88%AA%E6%A8%A1%E7%A4%BE/%E8%99%9A%E6%8B%9F%E6%9C%BA%E9%95%9C%E5%83%8F/ROS-DUT.zip)

---

## 贡献指南

本文档由大连理工大学航模社无人机开发团队维护。如果你在阅读过程中发现任何错误或有意补充内容，欢迎提出 Issue 或 Pull Request。

---

<div align="center">
  <p><strong>DUT Aeromodelling Association</strong></p>
  <p>Copyright &copy; 2026 DUT Aeromodelling Association - Shengqiao Qu</p>
</div>