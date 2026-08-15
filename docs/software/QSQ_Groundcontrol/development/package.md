# 使用 Inno Setup 打包 QSQ GroundControl（Windows）

本教程介绍如何将已经编译、部署完成的 QSQ GroundControl 制作为 Windows 安装程序。推荐流程是：

```text
QGC 源码 → Release 编译 → dist 部署目录 → Inno Setup → Setup.exe
```

Inno Setup 只负责包装已经可以独立运行的程序。Qt DLL、插件、资源文件和 Visual C++ 运行库等依赖，应在打包前由 QGC/CMake 的安装步骤部署完整。

---

## 一、准备可发布目录

### 1. 配置和编译便携版

在 **PowerShell** 中进入 QGC 源码根目录：

```powershell
Set-Location D:\qgc

py -3.14 .\tools\configure.py `
  -B .\build-release-portable `
  --release `
  --qt-root 'C:\Qt\6.11.1\msvc2022_64' `
  -- `
  -DQGC_BUILD_INSTALLER=OFF `
  -DQGC_WINDOWS_REQUIRE_ADMIN=ON

cmake --build .\build-release-portable --config Release --parallel
```

程序本身需要管理员权限启动，因为有内嵌终端，因此 `QGC_WINDOWS_REQUIRE_ADMIN` 一定要写成 `ON`。

### 2. 部署到固定目录

将程序部署到 `dist\QSQGroundControl`，便于 Inno Setup 从固定位置收集文件：

```powershell
cmake --install .\build-release-portable `
  --config Release `
  --prefix "$PWD\dist\QSQGroundControl"
```

部署后的目录结构通常类似：

```text
dist/
└─ QSQGroundControl/
   ├─ QGroundControl.exe
   ├─ Qt6Core.dll
   ├─ Qt6Gui.dll
   ├─ platforms/
   │  └─ qwindows.dll
   ├─ imageformats/
   └─ ...
```

实际主程序名称可能是 `QGroundControl.exe`、`qgroundcontrol.exe` 或自定义名称。请先在部署目录直接运行它，确认地图、串口、视频、语言包和其他功能正常，再开始打包。

---

## 二、安装 Inno Setup

可以从 [Inno Setup 官方网站](https://jrsoftware.org/isinfo.php)下载安装，也可以使用 WinGet：

```powershell
winget install --id JRSoftware.InnoSetup -e
```

安装完成后，可以使用图形界面的 **Inno Setup Compiler**，也可以调用命令行编译器 `ISCC.exe`。

---

## 三、创建 Inno Setup 脚本

在 QGC 源码根目录中新建 `installer\qsq-groundcontrol.iss`，内容如下：

```ini
; QSQ GroundControl Inno Setup script

#define MyAppName "QSQ GroundControl"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "DUT Aeromodelling Association"
#define MyAppURL "https://drone-dev.qsq.cool"
#define MyAppExeName "QGroundControl.exe"
#define SourceDir "..\dist\QSQGroundControl"

[Setup]
; 每个产品必须使用固定且唯一的 AppId。升级版本时不要修改它。
; 可在 PowerShell 中执行 [guid]::NewGuid() 生成自己的 GUID。
AppId={{12345678-1234-1234-1234-123456789ABC}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=admin

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

OutputDir=..\dist\installer
OutputBaseFilename=QSQ-GroundControl-{#MyAppVersion}-x64-Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern

UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}

; 如果已有图标和许可文件，可取消注释并修改路径。
; SetupIconFile=assets\installer.ico
; LicenseFile=assets\LICENSE.txt

[Languages]
Name: "chinesesimp"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加选项："; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "运行 {#MyAppName}"; Flags: nowait postinstall skipifsilent
```

必须修改以下内容：

- `MyAppVersion`：每次发行时更新版本号。
- `MyAppExeName`：改为部署目录中的实际 EXE 文件名。
- `SourceDir`：如果目录布局不同，改为实际部署目录。
- `AppId`：首次使用时生成自己的 GUID，此后所有升级版本保持不变。
- `MyAppPublisher` 和 `MyAppURL`：改为实际发行者信息。

如果希望允许普通用户仅为自己安装，可使用 Inno Setup 的 `PrivilegesRequiredOverridesAllowed=dialog` 等配置；地面站需要访问驱动或执行系统级操作时，应先确认权限需求再调整。

---

## 四、生成安装程序

### 使用图形界面

1. 打开 **Inno Setup Compiler**。
2. 选择 **File → Open**，打开 `installer\qsq-groundcontrol.iss`。
3. 选择 **Build → Compile**。
4. 编译成功后，在 `dist\installer` 中得到安装程序。

### 使用命令行

```powershell
& "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe" `
  .\installer\qsq-groundcontrol.iss
```

生成结果示例：

```text
dist\installer\QSQ-GroundControl-1.0.0-x64-Setup.exe
```

如需在 CI 中覆盖脚本顶部的版本宏，可以使用 `/D` 参数：

```powershell
& "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe" `
  "/DMyAppVersion=1.0.1" `
  .\installer\qsq-groundcontrol.iss
```

此时需要将脚本中的版本定义改成允许外部覆盖的形式：

```ini
#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif
```

---

## 五、测试安装、升级和卸载

不要只检查安装程序是否能够生成，至少完成以下测试：

1. 在没有 Qt 开发环境的干净 Windows 虚拟机中安装。
2. 从开始菜单和桌面快捷方式启动程序。
3. 检查串口、网络、地图、视频和自定义资源。
4. 使用相同 `AppId` 安装更高版本，验证覆盖升级和用户配置保留情况。
5. 从“设置 → 应用”卸载，确认程序文件和快捷方式被删除。
6. 分别测试中文路径、非管理员账户和 Windows 缩放显示。

静默安装和卸载可以这样测试：

```powershell
.\dist\installer\QSQ-GroundControl-1.0.0-x64-Setup.exe `
  /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /LOG="install.log"
```

默认卸载程序位于安装目录内，通常名为 `unins000.exe`：

```powershell
& "$env:ProgramFiles\QSQ GroundControl\unins000.exe" `
  /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
```

---

## 六、代码签名（正式发行时推荐）

未签名的安装程序更容易触发 Windows SmartScreen 警告。拥有可信代码签名证书后，可使用 Windows SDK 自带的 `signtool.exe` 对主程序和安装程序签名：

```powershell
signtool sign /fd SHA256 /td SHA256 `
  /tr "https://timestamp.digicert.com" `
  /f .\certificate.pfx `
  .\dist\installer\QSQ-GroundControl-1.0.0-x64-Setup.exe
```

不要将 PFX 文件和密码提交到 Git。CI 中应通过受保护的密钥存储注入证书。签名后可以验证：

```powershell
signtool verify /pa /v `
  .\dist\installer\QSQ-GroundControl-1.0.0-x64-Setup.exe
```

---

## 七、其他打包方式

### 1. CPack + Inno Setup

CMake 3.27 起提供 `INNOSETUP` 生成器，并要求 Inno Setup 6 或更高版本。前提是项目的 `CMakeLists.txt` 已正确配置 `install(...)`、CPack 元数据并执行 `include(CPack)`：

```cmake
set(CPACK_PACKAGE_NAME "QSQ GroundControl")
set(CPACK_PACKAGE_VENDOR "DUT Aeromodelling Association")
set(CPACK_PACKAGE_VERSION "1.0.0")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "QSQ GroundControl")
set(CPACK_GENERATOR "INNOSETUP")
include(CPack)
```

重新配置并编译后执行：

```powershell
cpack -G INNOSETUP `
  -C Release `
  --config .\build-release-portable\CPackConfig.cmake
```

这种方式便于将安装规则统一放进 CMake，但自定义安装向导时不如手写 `.iss` 灵活。可参考 [CPack Inno Setup Generator 官方文档](https://cmake.org/cmake/help/latest/cpack_gen/innosetup.html)。

### 2. NSIS

[NSIS](https://nsis.sourceforge.io/Docs/) 适合生成轻量的 EXE 安装程序，脚本能力强，也是 CPack 常用的 Windows 后端。

安装 NSIS：

```powershell
winget install --id NSIS.NSIS -e
```

如果项目已生成 `CPackConfig.cmake`，可以直接运行：

```powershell
cpack -G NSIS `
  -C Release `
  --config .\build-release-portable\CPackConfig.cmake
```

NSIS 3.03 及以上版本可用于当前 CPack NSIS 生成器；图标、安装目录、开始菜单和卸载行为可通过 `CPACK_NSIS_*` 变量配置，详见 [CMake 官方说明](https://cmake.org/cmake/help/latest/cpack_gen/nsis.html)。

### 3. WiX Toolset（MSI）

[WiX Toolset](https://wixtoolset.org/docs/) 用于生成标准 MSI，适合企业批量部署、组策略和需要 MSI 组件模型的场景。配置成本通常高于 Inno Setup。

当 CMake 项目已经配置 CPack 时，可以尝试：

```powershell
cpack -G WIX `
  -C Release `
  --config .\build-release-portable\CPackConfig.cmake
```

必须事先安装兼容版本的 WiX，并确保相应命令在 `PATH` 中。CPack 对 WiX 版本及扩展的要求见 [CPack WiX Generator 文档](https://cmake.org/cmake/help/latest/cpack_gen/wix.html)。

### 4. MSIX Packaging Tool

MSIX 适合现代 Windows 应用分发，具有更可控的安装、更新和卸载体验，但驱动程序、系统级修改以及某些传统桌面行为可能需要额外适配。

```powershell
winget install "MSIX Packaging Tool"
```

基本流程：

1. 准备一台干净的虚拟机。
2. 打开 MSIX Packaging Tool，选择“应用程序包”。
3. 让工具监视现有 Inno Setup 安装程序的安装过程。
4. 补充包名、发布者、版本和程序入口。
5. 保存并使用受信任证书签名生成的 `.msix`。

微软也支持用命令行模板自动转换，具体限制和步骤见 [MSIX Packaging Tool 官方教程](https://learn.microsoft.com/windows/msix/packaging-tool/create-app-package)。

### 5. ZIP/7-Zip 便携包

如果不需要注册卸载信息、创建快捷方式或请求安装权限，可以直接压缩部署目录：

```powershell
Compress-Archive `
  -Path .\dist\QSQGroundControl\* `
  -DestinationPath .\dist\QSQ-GroundControl-1.0.0-x64-portable.zip `
  -CompressionLevel Optimal
```

便携包最简单，适合内部测试和快速分发；缺点是无法自动创建快捷方式、处理升级或在“已安装的应用”中卸载。

---

## 方案选择建议

| 方案 | 输出格式 | 适合场景 | 特点 |
| --- | --- | --- | --- |
| Inno Setup | EXE | 普通用户安装、定制安装向导 | 易用、脚本清晰，本项目推荐 |
| CPack + Inno Setup | EXE | 已维护完整 CMake 安装规则 | 自动化程度高 |
| NSIS | EXE | 轻量安装器、高度脚本化 | 灵活，但脚本学习成本较高 |
| WiX Toolset | MSI | 企业部署、组策略 | 标准 MSI，配置更复杂 |
| MSIX | MSIX | 现代 Windows 分发和受控部署 | 安装干净，但兼容限制更多 |
| ZIP/7-Zip | ZIP/7z | 内部测试、便携分发 | 最简单，没有安装和升级逻辑 |

对当前 QSQ GroundControl，建议日常正式发行使用 **Inno Setup**，内部测试同时提供 **ZIP 便携包**；只有明确需要企业 MSI 或 MSIX 分发时，再引入 WiX 或 MSIX。

注：笔者使用的是Inno Setup
