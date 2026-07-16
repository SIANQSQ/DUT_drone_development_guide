#  烧录引导与官方系统镜像配置教程
## Jetson Orin NX Super 烧录引导和系统（L4T Ubuntu 20.04）

由于我们的代码基于 ROS1 开发，而 Jetson 电脑自带的 L4T 是 Ubuntu 22.04，只能运行 ROS2，因此需要重新配置系统。

### 1. 下载所需文件
下载以下两个文件：

- [`Tegra_Linux_Sample-Root-Filesystem_R35.6.1_aarch64.tbz2`](http://storage.qsq.cool:5666/%E8%88%AA%E6%A8%A1%E7%A4%BE/Jetson%E5%B7%A5%E5%85%B7%E5%8F%8A%E8%B5%84%E6%96%99/Linux%E5%AE%98%E6%96%B9%E7%B3%BB%E7%BB%9F%E5%8C%85/35.6.1/Tegra_Linux_Sample-Root-Filesystem_R35.6.1_aarch64.tbz2)


- [`Jetson_Linux_R35.6.1_aarch64.tbz2`](http://storage.qsq.cool:5666/%E8%88%AA%E6%A8%A1%E7%A4%BE/Jetson%E5%B7%A5%E5%85%B7%E5%8F%8A%E8%B5%84%E6%96%99/Linux%E5%AE%98%E6%96%B9%E7%B3%BB%E7%BB%9F%E5%8C%85/35.6.1/Jetson_Linux_R35.6.1_aarch64.tbz2)

### 2. 配置虚拟机环境
建议使用已配置好的虚拟机 **ROS_DUT**，或自行准备一台 **Ubuntu 20.04** 的虚拟机。

已经配置好的虚拟机下载链接：[`ROS_DUT.zip`](http://storage.qsq.cool:5666/%E8%88%AA%E6%A8%A1%E7%A4%BE/%E8%99%9A%E6%8B%9F%E6%9C%BA%E9%95%9C%E5%83%8F/ROS-DUT.zip)

### 3. 虚拟机操作步骤

#### 3.1 准备软件环境
在虚拟机中打开终端，执行以下命令安装必要软件并创建工作目录：
```bash
sudo apt update && sudo apt install -y qemu-user-static sshpass nfs-kernel-server libxml2-utils binutils device-tree-compiler python3-pip lbzip2
mkdir -p ~/jetson_orin && cd ~/jetson_orin
```
将第 1 步下载的两个文件移动到 `~/jetson_orin` 文件夹内，然后依次解压并准备系统文件：
```bash
tar xf Jetson_Linux_R35.6.1_aarch64.tbz2
cd Linux_for_Tegra
sudo tar xpf ../Tegra_Linux_Sample-Root-Filesystem_R35.6.1_aarch64.tbz2 -C rootfs/
cd ~/jetson_orin
sudo ./Linux_for_Tegra/apply_binaries.sh
```

#### 3.2 使 Jetson 进入 Recovery 模式并连接
- 短接 Jetson 载板特定排针（`REV`），使其进入 **Recovery** 模式。
- 使用数据线连接 Jetson 与你的计算机，并将 USB 设备接入虚拟机。
- 在虚拟机终端输入 `lsusb`，看到类似以下内容即表示成功进入烧写模式：
  ```
  Bus 003 Device 015: ID 0955:7e19 NVIDIA Corp. APX       <注意 APX>
  ```

#### 3.3 执行烧录命令
进入解压出的系统文件目录，运行以下命令烧写引导和系统：
```bash
cd Linux_for_Tegra
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 \
  -c tools/kernel_flash/flash_l4t_external.xml \
  -p "-c bootloader/t186ref/cfg/flash_t234_qspi.xml" \
  --showlogs --network usb0 jetson-orin-nano-devkit internal
```
> 该命令会烧写 **L4T Ubuntu 20.04**，对应版本 **35.6.1**，JetPack 为 **5.\***。

#### 3.4 等待任务完成
烧写成功后，控制台会输出类似以下内容：
```
writing item=17, 9:0:secondary_gpt, 62545444352, 16896, gpt_secondary_9_0.bin, 16896, fixed-<reserved>-0, 892160f68456aad01aaf1f9ab9c6a11dd09d7131
[ 594]: l4t_flash_from_kernel: Successfully flash the external device
[ 594]: l4t_flash_from_kernel: Flashing success
[ 594]: l4t_flash_from_kernel: The device size indicated in the partition layout xml is smaller than the actual size. This utility will try to fix the GPT.
Flash is successful
Reboot device
Cleaning up...
Log is saved to Linux_for_Tegra/initrdlog/flash_3-2_0_20260630-093533.log 
```
看到 `Flash is successful` 即表示第一章任务完成。

---


——屈圣桥 2026.7.1，凌晨
