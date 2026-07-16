# Gazebo 仿真

本文档介绍如何使用 Gazebo 仿真环境进行无人机飞行仿真调试。

## 仿真的作用

仿真实现了构建在虚拟物理引擎中构建的一架飞机的操作，在我们修改了基本的飞行控制功能之后，为了快速且低成本的验证算法的正确性，我们常常采用仿真的方式。
</br>幸运的是我们的ROS自带了一套仿真工具，Gazebo和RViz，其中Gazebo负责展示物理模型，RViz负责视觉相关的仿真，我们主要用到的是Gazebo。

注意：虚拟机ROS-DUT中已经完整配置好了仿真的全部环境，打开即用。</br>
另外不建议在Jetson上运行仿真，除非设置成让Gazebo使用显卡资源加速，否则使用CPU会很卡很慢。
## 前置条件

在进行仿真操作之前，请确保已完成以下准备工作：

- [ ] 已完成 [环境部署](./environment.md) 中的基础环境安装
- [ ] 已安装 PX4-Autopilot 固件（位于 `~/PX4_Firmware`），可从以下链接下载：[固件源码下载](http://storage.qsq.cool:5666/%E8%88%AA%E6%A8%A1%E7%A4%BE/%E9%A3%9E%E6%8E%A7%E5%9B%BA%E4%BB%B6/%E5%9B%BA%E4%BB%B6%E6%BA%90%E7%A0%81)
- [ ] 已安装 ROS 与 MAVROS
- [ ] 已安装 Gazebo 仿真器

---

## 仿真使用操作

### 1. 启动 Gazebo 仿真并加载无人机模型

进入 `~/PX4_Firmware` 目录，打开终端，执行以下命令：

```bash
cd ~/PX4_Firmware/
make px4_sitl_default gazebo
```

!!! note "说明"
    此命令会启动 PX4 软件在环仿真（SITL），默认加载的是 PX4 内置的标准多旋翼飞机模型。
    如果需要更换其他无人机模型，可以修改 Gazebo 配置文件来加载自定义模型。

执行成功后，将会看到 Gazebo 仿真界面，无人机模型会出现在默认的世界场景中。

---

### 2. 启动 MAVROS 连接飞控

!!! warning "注意"
    仿真环境下的飞控连接命令与实机环境不同，请确保使用正确的参数。

新开一个终端窗口（同样在 `~/PX4_Firmware` 目录下），输入以下命令：

```bash
roslaunch mavros px4.launch fcu_url:="udp://:14550@127.0.0.1:18570"
```

此命令会启动 MAVROS 节点，通过 UDP 协议连接到仿真中的飞控。

??? tip "与实机连接的区别"
    | 环境 | 飞控连接命令 |
    |------|------------|
    | 仿真 | `fcu_url:="udp://:14550@127.0.0.1:18570"` |
    | 实机 | 通常使用串口连接，如 `fcu_url:="/dev/ttyACM0:921600"` |

---

### 3. 启动任务控制节点

新开终端窗口，启动各功能节点：

```bash
roslaunch px4_controller start.launch
```

此命令会启动 `px4_controller` 功能包中的所有任务节点，包括：

- 无人机状态机
- PX4 接口通信
- 瞄准与跟踪
- 目标侦察
- 投放控制
- 位置发布

!!! info "提示"
    任务控制节点的详细说明请参考 [软件功能包](../software/px4_controller/state-machine.md) 章节。

---

## 验证仿真运行

完成以上三步操作后，即可在 Gazebo 仿真环境中观察到无人机的飞行状态。你可以通过以下方式验证系统是否正常运行：

1. 在 Gazebo 界面中观察无人机模型是否正确加载
2. 使用 `rostopic list` 查看是否有飞控相关的话题发布
3. 检查 MAVROS 连接状态是否正常

```bash
# 查看当前所有 ROS 话题
rostopic list

# 查看飞控状态
rostopic echo /mavros/state
```

---

## 常见问题

### 1. Gazebo 启动失败

- 检查 Gazebo 是否正确安装：`gazebo --version`
- 确保 PX4 固件已完整编译：`make px4_sitl_default`
- 尝试清理并重新编译：`make clean && make px4_sitl_default gazebo`

### 2. MAVROS 无法连接

- 确认飞控仿真已经成功启动
- 检查 UDP 端口 `14550` 和 `18570` 是否被其他进程占用
- 确保 MAVROS 已正确安装：`roslaunch mavros px4.launch`

### 3. 任务节点启动异常

- 确认工作空间已正确 `source`：`source ~/catkin_ws/devel/setup.bash`
- 检查功能包是否已编译：`catkin_make`