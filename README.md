<div align="center">

# sckoc

[![license](https://img.shields.io/badge/license-Proprietary-lightgrey)](https://github.com/SkyWalkerAMD/sckoc-dist/releases/latest)
![platform](https://img.shields.io/badge/platform-linux%20x86__64-blue)
![deps](https://img.shields.io/badge/runtime%20deps-none-brightgreen)

[English](README.en.md) | 中文

Intel / AMD 服务器与工作站的**只读**硬件监控工具

</div>

一条命令看清 CPU 的实时状态：每个核心的频率、温度、电压、功耗、负载，以及内存、缓存、功率墙等平台信息。

**只读**——不写任何寄存器，不改任何设置，随时可以在正在干活的机器上运行。

## 安装

推荐用软件仓库，装一次以后跟着系统一起更新：

```bash
curl -fsSL https://skywalkeramd.github.io/sckoc-dist/setup.sh | sudo bash
```

也可以直接装 [Releases](https://github.com/SkyWalkerAMD/sckoc-dist/releases/latest) 里的包：

```bash
sudo dnf install -y ./sckoc-<版本>-1.x86_64.rpm    # el7 / el8 / el9 / Fedora 都用这一个
sudo apt install -y ./sckoc_<版本>-1_amd64.deb     # 任意 amd64 Debian / Ubuntu
```

不想经过包管理器，也可以只拿那个二进制文件：

```bash
chmod +x sckoc-<版本>-static-x86_64
sudo install -m755 sckoc-<版本>-static-x86_64 /usr/local/bin/sckoc
sudo modprobe msr                                  # Intel 平台需要
```

## 开始用

```bash
sudo sckoc            # 实时总览
sudo sckoc info       # 平台配置报告
sudo sckoc --watch    # 每 2 秒自动刷新
```

就这三条。核心多的机器上表格会自动分成多列，窗口放不下才拆，拉大窗口又会变回一列。

## 常用命令

| 命令 | 作用 |
|---|---|
| `sckoc` | 实时总览（每 Socket + 每核心） |
| `sckoc info` | 平台配置：安全状态、频率上限、功率墙、内存、缓存 |
| `sckoc vid` | 逐核请求电压 |
| `sckoc uncore` | uncore / mesh 频率限值（Intel） |
| `sckoc --watch=3` | 每 3 秒原地刷新 |
| `sckoc --json` | 机器可读输出，便于接监控系统 |
| `sckoc help` | 完整帮助 |

详细说明见 `man sckoc`。

## 需要什么

需要 root。Intel 平台需要内核 `msr` 模块——用 rpm/deb 安装会自动配好，裸二进制方式手动 `sudo modprobe msr` 即可。

程序是静态编译的，**不依赖任何运行时库**，一个文件从 el7（3.10 内核）到最新发行版都能跑，不用挑版本。

`ipmitool` 装了的话能多显示 BMC 提供的内存和 CPU 温度、DRAM 轨电压；没装就是这几项留空，不影响其它功能。

## 有些数据显示 N/A？

这是正常的——某项数据拿不到时，sckoc 会明确写 `N/A` 并说明原因，而不是编一个数字给你。常见情况：

| 显示 | 原因 |
|---|---|
| Intel uncore/mesh 为 N/A | 缺 `intel-uncore-frequency` 驱动（内核 5.6+ 自带） |
| AMD 温度为 N/A | 缺 `k10temp`，或内核版本太老不认这颗 CPU |
| AMD FCLK / PPT 为 N/A | 内核太旧，没有 HSMP 驱动。EPYC / Threadripper PRO 需要 5.18 以上，桌面 Socket 的 Threadripper 需要 6.10 以上；消费级 Ryzen 走 `ryzen_smu`。内核够新却仍为 N/A，才需要去 BIOS 打开 HSMP Support |
| 内存温度、DRAM 电压为空 | 机器没有 BMC，或没装 `ipmitool` |

AMD 平台的这些驱动，包安装时会在后台自动配置，进度可以看：

```bash
journalctl -u sckoc-setup.service
```

机器访问不了 GitHub 时，在 `/etc/sckoc/setup.conf` 里写一行 `GH_PROXY=auto` 即可自动选择可用镜像；`GH_PROXY=off` 则固定直连。内核过旧的机器不必折腾，装一个新内核才是唯一能让这几项有数的办法。

## 卸载

```bash
sudo dnf remove sckoc      # 或 sudo apt remove sckoc
sudo sckoc uninstall -y    # 不是用包管理器装的
```

## License

专有软件。Copyright (C) 2026 SkyWalkerAMD. All rights reserved.

授权内部使用（含商用），禁止再分发与逆向。完整条款见软件包内 `/usr/share/doc/sckoc/`。分发的二进制静态链接 musl C 库（MIT）。

再分发授权或其他许可问题：scka7t@gmail.com
