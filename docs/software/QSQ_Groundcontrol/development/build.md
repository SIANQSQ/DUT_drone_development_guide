# 使用 Ninja 编译自定义 QGroundControl (Windows)

本教程将引导你在 Windows 环境下，使用 **Ninja** 构建系统配合 MSVC 编译器 (`cl.exe`)，编译自定义的 QGroundControl (QGC) 地面站，并禁用 GStreamer 视频流功能。围绕以下核心命令展开：

```bash
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER="cl.exe" -DCMAKE_CXX_COMPILER="cl.exe" -DQGC_ENABLE_GSTREAMER=OFF ..
ninja
```

---

## 前置准备

### 1. 安装必需工具
- **Visual Studio** (推荐 2019/2022)：安装时勾选“使用 C++ 的桌面开发”工作负载，以获得 MSVC 编译器 (`cl.exe`) 和 Windows SDK。
- **CMake** (≥3.16)：从 [cmake.org](https://cmake.org/download/) 下载安装，确保加入系统 PATH。
- **Ninja**：可从 [GitHub Releases](https://github.com/ninja-build/ninja/releases) 下载 `ninja-win.zip`，解压后将 `ninja.exe` 放入某个 PATH 目录（例如 `C:\Windows` 或 CMake 的 bin 目录）。
- **Git**：用于克隆 QGC 源码。

### 2. 获取 QGC 源码
打开命令提示符 (或 PowerShell)，克隆仓库并进入目录：
```bash
git clone https://github.com/mavlink/qgroundcontrol.git
cd qgroundcontrol
```
若要编译特定版本，可 `git checkout <tag>`（如 `v4.2.8`）。建议更新子模块：
```bash
git submodule update --init --recursive
```

### 3. 配置 MSVC 环境
**关键**：需要在能调用 `cl.exe` 的环境下执行 CMake。打开 **“x64 Native Tools Command Prompt for VS 2022”**（或对应版本），它会自动设置 MSVC 编译器和相关库的路径。  
如果使用普通命令提示符，也可以手动运行 `vcvarsall.bat x64`，例如：
```bash
"C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
```

---

## 配置 CMake（生成 Ninja 构建文件）

确保位于 QGC 源码根目录。推荐使用**独立构建目录**（如 `build`）保持源码整洁：
```bash
mkdir build
cd build
```

执行以下 CMake 配置命令，该命令将：
- 指定生成器为 Ninja (`-G Ninja`)
- 设置构建类型为 Release
- 强制使用 MSVC 编译器 (`cl.exe`)
- 关闭 GStreamer 支持，避免依赖 GStreamer 库

```bash
cmake -G Ninja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_C_COMPILER="cl.exe" ^
      -DCMAKE_CXX_COMPILER="cl.exe" ^
      -DQGC_ENABLE_GSTREAMER=OFF ^
      ..
```

> **说明**  
> `-DCMAKE_C_COMPILER="cl.exe"` 和 `-DCMAKE_CXX_COMPILER="cl.exe"` 通常非必须（若在 Native Tools 终端中 CMake 会自动检测），但显式指定可避免环境混乱导致调用了 MinGW 或其他编译器。  
> `-DQGC_ENABLE_GSTREAMER=OFF` 禁用视频流功能，可加快编译并减少运行时依赖。  
> 行末的 `..` 表示上级目录（即源码根目录）的 CMakeLists.txt。

如果 CMake 配置成功，你会看到 `-- Build files have been written to: .../build` 类似信息。若有缺失依赖（如 Qt），请参考下文“常见问题”解决。

---

## 编译 QGC

生成构建文件后，直接使用 Ninja 编译（在 `build` 目录下）：
```bash
ninja
```
Ninja 会并行编译所有目标。如需指定并行任务数，可加 `-j N`（例如 `ninja -j 8`），但通常默认会根据 CPU 核心数自动优化。

编译完成后，在 `build` 目录下会生成 `qgroundcontrol.exe`（或 `staging` 子目录中，取决于 QGC 版本）。你可以双击运行测试。

---

## 额外说明与常见问题

### 1. 必须使用 MSVC 编译器？
QGC 在 Windows 上仅官方支持 MSVC（Visual Studio 编译器）。`cl.exe` 是 MSVC 的 C/C++ 编译器驱动。若你配置了 MinGW，必须通过上述选项强制指定为 `cl.exe`，否则 CMake 可能选择错误编译器。

### 2. 缺少 Qt 依赖
QGC 依赖 Qt 库。最简单的办法是通过 QGC 官方提供的 **预编译 Qt 包**（或自行编译 Qt for MSVC）。  
通常在 CMake 配置时，通过 `-DQT_DIR=<path>` 或设置 `CMAKE_PREFIX_PATH` 指定 Qt 路径，例如：
```bash
cmake ... -DCMAKE_PREFIX_PATH=C:\Qt\5.15.2\msvc2019_64
```
详细 Qt 安装说明请参考 [QGC 构建文档](https://docs.qgroundcontrol.com/master/en/qgc-dev-guide/build/build_windows.html)。

### 3. GStreamer 的作用
GStreamer 用于视频流接收（如 RTSP 视频）。关闭后 QGC 仍可正常执行导航、遥测、参数配置等功能，仅无法显示视频流。

### 4. 清理与重新配置
若要完全重新编译，只需删除 `build` 文件夹，再重复上述步骤：
```bash
rmdir /s /q build
mkdir build && cd build
cmake -G Ninja ... ..
ninja
```
Ninja 的增量编译很可靠，简单修改源码后直接 `ninja` 即可。

### 5. Debug 版本
将 `-DCMAKE_BUILD_TYPE=Release` 改为 `Debug` 即可生成带调试信息的版本。

---

## 总结
通过 Ninja 配合 MSVC 编译 QGC 的关键步骤：
1. 在正确配置的 MSVC 环境中打开终端。
2. 使用 CMake 指定 Ninja 生成器、编译器类型，并根据需要关闭 GStreamer。
3. 执行 `ninja` 完成编译。

这种方式相较于 Visual Studio 工程，**命令行更轻量，构建速度更快**，非常适合持续集成和快速迭代开发。祝你编译顺利！
