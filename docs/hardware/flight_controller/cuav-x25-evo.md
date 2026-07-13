# CUAV X25 EVO 飞控简介
## 飞控简介

飞控简介链接:
---

## 机载计算机与飞控以太网连接配置教程

### 网络规划 (以下IP地址均为当前实机的地址)

- **机载计算机 IP**：
  - `1号机:192.168.88.1`
  - `2号机:192.168.88.2`

- **飞控 IP**：  
  - `1号机:192.168.88.101`
  - `2号机:192.168.88.102`

> 以下操作以飞控 IP `192.168.88.101` 为例，另一地址仅需修改 `IPADDR` 即可。

---

### 一、飞控网络配置

在QGC内打开Mavlink控制台，执行以下命令。

#### 1. 写入网络配置

```bash
echo DEVICE=eth0 > /fs/microsd/net.cfg
echo BOOTPROTO=fallback >> /fs/microsd/net.cfg
echo IPADDR=192.168.88.101 >> /fs/microsd/net.cfg
echo NETMASK=255.255.255.0 >> /fs/microsd/net.cfg
echo ROUTER=192.168.88.1 >> /fs/microsd/net.cfg
echo DNS=192.168.88.1 >> /fs/microsd/net.cfg
```

**参数说明：**
- `DEVICE=eth0`：指定网卡为以太网接口
- `BOOTPROTO=fallback`：优先使用静态配置，静态失效时尝试 DHCP
- `IPADDR`：飞控静态 IP 地址
- `NETMASK`：子网掩码
- `ROUTER`：网关地址（指向机载计算机）
- `DNS`：域名服务器（此处设为机载计算机）

#### 2. 检查配置文件

```bash
cat /fs/microsd/net.cfg
```

确认内容与写入一致。

#### 3. 加载配置并重启网络

```bash
netman update
```

执行后飞控会自动重启网络服务（可能触发整个飞控重启，请确保安全）。

#### 4. 验证当前网络配置

```bash
netman show
```

查看当前生效的 IP 地址、网关等信息是否正确。

---

### 二、MAVLink 以太网参数配置

在飞控参数系统中设置以下参数（例如通过 QGC 或 `param set` 命令）。

| 参数名 | 推荐值 | 选项/说明 |
|--------|--------|-----------|
| `MAV_2_CONFIG` | `1000` | 配置 MAVLink 实例 2 通过以太网传输 |
| `MAV_2_BROADCAST` | `1` | 始终广播 MAVLink 消息 |
| `MAV_2_MODE` | `0` | Normal 模式，发送标准 GCS 消息集 |
| `MAV_2_RADIO_CTL` | `0` | 禁用流量软件限制 |
| `MAV_2_RATE` | `100000` | 最大发送速率 100000 B/s |
| `MAV_2_REMOTE_PRT` | `14550` | 远程端口 14550（用于 GCS 连接） |
| `MAV_2_UDP_PRT` | `14540` | 本地 UDP 端口 14540（用于接收 GCS 指令） |

> **重要**：`MAV_2_UDP_PRT` 为飞控本地监听端口，通常与机载计算机发送端口对应，请根据实际需求核对，注释中标记 `#注意此处`。

#### 使用 `param set` 命令配置示例

```bash
param set MAV_2_CONFIG 1000
param set MAV_2_BROADCAST 1
param set MAV_2_MODE 0
param set MAV_2_RADIO_CTL 0
param set MAV_2_RATE 100000
param set MAV_2_REMOTE_PRT 14550
param set MAV_2_UDP_PRT 14540
```

配置完成后建议重启飞控或重新连接 MAVLink 以生效。

---

### 三、连接验证

1. 确保机载计算机 IP 已正确设置为 `192.168.88.1`。
2. 在机载计算机上 ping 飞控 IP，例如：
   ```bash
   ping 192.168.88.101
   ```
3. 启动地面站软件（如 QGC），配置 UDP 连接，目标端口 `14550`，监听端口 `14540`（或根据实际情况调整），检查心跳和参数是否正确接收。

---

### 四、注意事项

- 若使用 `192.168.88.102`，仅需将配置中的 `IPADDR` 改为对应地址，其余参数相同。
- 修改网络参数可能导致飞控瞬时断连，请在非飞行状态下操作。
- 确保防火墙未阻止 UDP 14540/14550 端口通信。
- 如遇连接异常，可先用 `netman show` 和 `param show` 复查配置。
