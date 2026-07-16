# ROS安装
---
#### ROS(Robot Operation System)，机器人操作系统，能够实现复杂的软件包构件，同时提供了相当多的工具用于机器人开发与部署。很多现代化机器人的开发都是依赖于ROS。
目前ROS有两代，分别是ROS1与ROS2。ROS2对ROS1存在的诸多问题进行了改进，也丰富了功能。但是由于笔者最早接触这个比赛的时候选择了ROS1，那么到目前为止我们的一切工作都是基于ROS1的基础上开发的。后续如果有条件，我十分支持能将整个代码包全部更新为ROS2版本的代码，以保持代码的先进性，并获得更好的控制性能与稳定性。
---
## 一、ROS的版本
需要注意的是，ROS的版本是与我们使用的Ubuntu相关的，每个版本的Ubuntu都对应自己的ROS版本，例如我们目前使用的Ubuntu20.04，对应的ROS就是ROS1 Noetic。
另外，ROS1 Noetic是官方支持的最后一个版本的ROS1，也就是说，如果Ubuntu使用更新的版本，例如Ubuntu22.04，那么就无法使用ROS1了，只能安装ROS2 Humble。
这也是我们费九牛二虎之力，给我们的Jetson Orin NX去安装Ubuntu20.04的原因。（从这个角度来看，当时挖的坑终究是要填的 >_< ）

## 二、ROS1 Noetic的安装
不同版本的ROS安装方法基本上是一致的，这里就以我们目前使用的ROS1 Noetic为例，讲述ROS的安装方法。

### 1. 配置系统软件源
首先需要将系统的软件源设置为ROS官方的软件源：
```bash
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
```

### 2. 添加ROS官方密钥
导入ROS官方的GPG密钥，确保下载的包是完整且未被篡改的：
```bash
sudo apt install -y curl
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
```

### 3. 更新软件包索引
添加新的软件源后，需要更新本地的软件包索引：
```bash
sudo apt update
```

### 4. 安装ROS桌面完整版
ROS提供了多种安装版本，我们选择安装 **桌面完整版**（`desktop-full`），它包含了ROS核心功能、可视化工具（如Rviz）以及仿真环境（如Gazebo），可以满足我们的开发需求。安装时间较长，请耐心等待：

```bash
sudo apt install -y ros-noetic-desktop-full
```

各安装版本的区别：
| 版本 | 包含内容 |
|------|----------|
| `ros-noetic-desktop-full` | ROS核心 + 可视化工具 + 仿真环境 + 2D/3D仿真器 |
| `ros-noetic-desktop` | ROS核心 + 可视化工具 + rqt工具箱 |
| `ros-noetic-ros-base` | ROS核心 + 基础通信包 |
| `ros-noetic-ros-core` | 仅ROS核心包 |

### 5. 初始化rosdep
`rosdep` 是ROS用于管理系统依赖的工具，在安装ROS后需要初始化它：
```bash
sudo rosdep init
rosdep update
```

### 6. 配置ROS环境变量
为了方便每次终端启动时自动加载ROS环境，将环境配置文件写入 `.bashrc`：
```bash
echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### 7. 安装构建工具
为了后续编译自己的ROS功能包，还需要安装一些常用的构建依赖工具：
```bash
sudo apt install -y python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential python3-catkin-tools
```

### 8. 验证安装
安装完成后，可以通过以下方式验证ROS是否安装成功。

打开终端，输入 `roscore` 启动ROS核心：
```bash
roscore
```
如果能正常启动并看到类似以下输出，则说明安装成功：
```
... logging to /home/username/.ros/log/...
started roslaunch server http://localhost:xxxxx/
ros_comm version 1.16.0
...
```

### 9. 创建工作空间（可选）
建议创建自己的工作空间，用于存放我们自己的ROS功能包。后续我们的任务控制器及相关代码将放置在此工作空间中：

```bash
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws
catkin build
```

> **注意**：本文使用 `catkin build`（即 `catkin_tools`）而非 `catkin_make`，`catkin build` 提供了更好的构建管理和输出隔离。我们已在第 7 步中安装了 `python3-catkin-tools`。

创建工作空间后，也将工作空间的环境变量加入 `.bashrc`：
```bash
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

---

## 三、常见问题

### 1. `rosdep init` 网络错误
由于网络原因，`rosdep init` 可能无法正常连接。可以尝试更换网络环境，或使用代理。

### 2. `apt-key` 提示已弃用
较新的系统可能会提示 `apt-key` 已弃用，但仍可正常使用。如遇到问题，可采用以下替代方式：
```bash
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/ros-latest.list
```

### 3. Jetson ARM64 架构
由于 Jetson 使用的是 ARM64 架构，而非 x86，ROS 官方源对 ARM64 的支持是完整的，安装过程与普通 PC 完全一致，无需额外配置。

---

——屈圣桥 2026.7.1，凌晨