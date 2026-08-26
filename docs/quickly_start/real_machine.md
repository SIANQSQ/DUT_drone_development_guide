# 实机飞行

本文档介绍无人机的实机飞行操作流程，包括硬件连接检查、系统启动、任务控制节点运行等完整步骤。

## 硬件架构概述

本无人机系统由以下核心组件构成：

| 组件 | 型号 | 作用 |
|------|------|------|
| 飞控 | CUAV X25 EVO | 飞行姿态控制、传感器数据融合 |
| 机载计算机 | Jetson Orin NX | 运行 ROS 任务控制节点、视觉处理 |
| 数传电台 | P8 / P9 数传 | 地面站与飞控之间遥测通信 |
| 电源模块 | PMU2 Lite | 整机供电、电池检测 |
| RTK | CUAV 2HP / 9PS RTK | 高精度定位 |

详细的硬件接线方式请参考 [线路连接说明](../hardware/wiring/wiring.md)。

---

## 前置条件

在进行实机飞行之前，请确保：

- [ ] 已完成 [环境部署](./environment.md) 中的基础环境安装
- [ ] 已安装 PX4-Autopilot 固件，可从以下链接下载：[固件源码下载](https://storage.qsq.cool/%E8%88%AA%E6%A8%A1%E7%A4%BE/%E9%A3%9E%E6%8E%A7%E5%9B%BA%E4%BB%B6/%E5%9B%BA%E4%BB%B6%E6%BA%90%E7%A0%81)
- [ ] 已安装 ROS 与 MAVROS
- [ ] 已确认所有硬件接线正确（参考 [线路连接说明](../hardware/wiring/wiring.md)）
- [ ] 飞控已刷入正确固件并通过 QGroundControl 完成基础校准（罗盘、加速度计、水平等）
- [ ] 电池电量充足
- [ ] 遥控器与接收机已对频

---

## 飞行前检查

### 1. 硬件连接检查

执行飞行前，请逐一检查以下连接：

| 检查项 | 说明 |
|--------|------|
| 电池电量 | 确认电池电压正常，电量充足 |
| 电源模块 (PMU) → 飞控 POWER C1 | 整机供电主接口 |
| 电机电调 → 飞控 M1~M8 | 电机信号线连接牢固 |
| 数传电台 → 飞控 TELEM1 | 遥测数据通信 |
| RTK → 飞控 CAN1 | 高精度定位 |
| 激光雷达 → 飞控 TELEM2 | 避障定高数据 |
| GPS → 飞控 GPS & SAFETY | 主定位系统 |
| 机载计算机 USB → 飞控 USB | 飞控与 Jetson Offboard 通信 |
| 摄像头 USB → 机载计算机 | 视觉识别数据 |
| 舵机控制板 → 机载计算机 40-Pin GPIO | 投放机构控制 |
| 安全开关 | 确保安全开关可正常操作 |
| TF 卡 | 插入飞控 TF 卡槽，用于记录飞行日志 |

### 2. 结构检查

- [ ] 机臂、脚架无松动
- [ ] 螺旋桨安装方向正确，螺母拧紧
- [ ] 各模块固定牢固，无晃动
- [ ] 线缆捆扎整齐，不干涉运动部件

---

## 实机飞行操作

### 1. 上电启动

按以下顺序操作：

1. **安装电池**：将动力电池连接到 PMU 电源模块
2. **等待飞控初始化**：飞控上电后 LED 指示灯亮起，等待 GPS 锁定（约 2~5 分钟，首次冷启动可能更久）
3. **机载计算机自启**：Jetson Orin NX 随供电自动开机

!!! warning "注意"
    上电后请勿立即靠近螺旋桨。始终保持安全距离，直到确认飞控处于 **DISARMED（未解锁）** 状态。

---

### 2. 启动 MAVROS 连接飞控

!!! warning "与仿真环境的区别"
    实机环境下 MAVROS 的连接命令与仿真不同。实机使用 USB 串口连接飞控，而非 UDP 端口。

确认 Jetson 已启动完成并 SSH 登录后，启动 MAVROS：

```bash
roslaunch mavros px4.launch fcu_url:="/dev/ttyACM0:921600"
```

??? tip "与仿真连接的区别"
    | 环境 | 飞控连接命令 |
    |------|------------|
    | 实机 | `fcu_url:="/dev/ttyACM0:921600"` |
    | 仿真 | `fcu_url:="udp://:14550@127.0.0.1:18570"` |

!!! note "说明"
    - `/dev/ttyACM0` 是飞控通过 USB 连接到 Jetson 后识别的串口设备，实际设备名可能不同，可通过 `ls /dev/tty*` 确认
    - `921600` 是推荐的通信波特率，支持高速 MAVLink 2 协议
    - 如果连接失败，检查飞控 USB 线是否已连接到 Jetson 的正确 USB 口

---

### 3. 启动任务控制节点

新开终端窗口，启动各功能节点：

```bash
roslaunch px4_controller start.launch
```

此命令会启动 `px4_controller` 功能包中的所有任务节点，包括：

- **无人机状态机**：管理飞行状态切换（手动 / Offboard / 自主任务）
- **PX4 接口通信**：MAVLink 消息的收发封装
- **瞄准与跟踪**：基于视觉的目标识别与跟踪
- **目标侦察**：目标检测与识别
- **投放控制**：舵机投放机构控制
- **位置发布**：目标位置估计与发布

!!! info "提示"
    任务控制节点的详细说明请参考 [软件功能包](../software/px4_controller/state-machine.md) 章节。

---

## 验证系统运行

### 基本检查

完成以上步骤后，通过以下方式验证系统是否正常运行：

```bash
# 查看当前所有 ROS 话题
rostopic list

# 查看飞控状态（确认飞控已连接且通信正常）
rostopic echo /mavros/state

# 查看 GPS 状态
rostopic echo /mavros/global_position/global
```

### 关键状态确认

| 检查项 | 正常状态 | 严重异常 |
|--------|----------|----------|
| `mavros/state.connected` | `True` | `False` |
| `mavros/state.armed` | `False`（未解锁） | `True`（误解锁，危险） |
| `mavros/state.guided` | `True` | `False` |
| GPS 卫星数 | ≥ 10 颗 | < 6 颗 |
| RTK 状态 | FIX（固定解） | FLOAT / NONE |

---

## 常见问题

### 1. MAVROS 无法连接飞控

- 检查飞控 USB 线是否已连接到 Jetson
- 确认串口设备：`ls /dev/ttyACM*`
- 检查串口权限：`sudo chmod 666 /dev/ttyACM0`
- 检查 MAVROS 是否已安装：`roslaunch mavros px4.launch`

### 2. GPS / RTK 无法定位

- 确保天线放置在开阔无遮挡的位置
- 等待冷启动完成（首次可能需要 5~10 分钟）
- 确认 RTK 基准站已正常工作
- 检查 RTK 与飞控 CAN1 的连接

### 3. 任务节点启动异常

- 确认工作空间已正确 source：`source ~/catkin_ws/devel/setup.bash`
- 检查功能包是否已编译：`catkin_make`
- 查看日志排查错误：`roslaunch px4_controller start.launch --screen`

### 4. 舵机 / 投放器不工作

- 确认舵机控制板与 Jetson 的 40-Pin GPIO 接线正确
- 检查舵机供电是否正常（舵机需外接 BEC 供电，飞控不给舵机供电）

### 5. 飞控无法解锁

- 检查遥控器是否已打开且油门处于最低位
- 确认安全开关已按下
- 在 QGroundControl 中查看解锁拒绝原因（如 GPS 卫星数不足、校准未完成等）