<div align="center">

# sckoc

[![license](https://img.shields.io/badge/license-Proprietary-lightgrey)](https://github.com/SkyWalkerAMD/sckoc-dist/releases/latest)
![platform](https://img.shields.io/badge/platform-linux%20x86__64-blue)
![deps](https://img.shields.io/badge/runtime%20deps-none-brightgreen)

[English](README.en.md) | 中文

**sckoc 的分发仓库。** 源码不在此处；本仓库仅提供编译产物与软件仓库。

</div>

面向 Intel 与 AMD 服务器和工作站的**只读**硬件监控软件。数据取自 MSR、SMBIOS、sysfs、AMD HSMP 邮箱、Intel TPMI MMIO 与 BMC/IPMI 侧带。`sckoc mon` 在单个采样窗口内给出每 Socket 与每核心两层实时视图（电压、温度、频率、功耗、C-state 驻留）；`sckoc info` 给出不随时间变化的平台配置报告。不写入任何寄存器，Secure Boot 与 kernel lockdown (integrity) 下可用。

## 安装

**软件仓库**（一次配置，之后随包管理器更新）

```bash
curl -fsSL https://skywalkeramd.github.io/sckoc-dist/setup.sh | sudo bash
sudo dnf install -y sckoc      # 或 Debian/Ubuntu: sudo apt update && sudo apt install -y sckoc
```

`setup.sh` 自动识别 dnf/yum/apt 并写入对应的仓库配置。

**直接安装软件包**（见 [Releases](https://github.com/SkyWalkerAMD/sckoc-dist/releases/latest)）

```bash
sudo dnf install -y ./sckoc-<版本>-1.x86_64.rpm     # el7 / el8 / el9 / Fedora 同一个包
sudo apt install -y ./sckoc_<版本>-1_amd64.deb      # 任意 amd64 Debian/Ubuntu
```

**裸二进制**（不进包管理器）

```bash
chmod +x sckoc-<版本>-static-x86_64
sudo install -m755 sckoc-<版本>-static-x86_64 /usr/local/bin/sckoc
sudo modprobe msr                                   # Intel 平台需要
```

## 运行环境

需要 root。Intel 平台需内核 `msr` 模块——rpm/deb 安装时自动加载并配置开机自启；裸二进制方式需自行 `modprobe msr`（`sckoc uncore` 与 `sckoc info` 无此模块亦可运行）。

二进制静态链接 musl，**无运行时库依赖**；所用系统调用最新的一个是 Linux 2.6 时代的 `set_tid_address`，因此同一个文件从 el7（内核 3.10）到 rawhide 通用，无需按发行版分别取包。

`ipmitool` 为可选：装有该工具且平台具备 BMC 时，补齐 DIMM/CPU 温度与 DRAM 轨电压，缺失时相应字段留空。`dmidecode` 非必需（SMBIOS 直接读 `/sys/firmware/dmi/tables/DMI`）。

## 使用

```
sckoc [mon] [--json]      每 Socket 与每核心实时视图（默认命令）
sckoc info                静态平台报告
sckoc vid                 逐核 VID / 逐 rail 电压
sckoc uncore [--json]     uncore/mesh 频率限值与 BIOS 开机值（Intel）
sckoc dump <reg> [hi:lo]  逐 Socket 读单个 MSR，可选位域
sckoc uninstall [-y]      卸载
sckoc version | -V
sckoc help | -h
```

环境变量：`INT=<秒>` 采样窗口（默认 1）、`DMI=<路径>`、`IPMITOOL=<路径>`。

```bash
sudo sckoc                 # 一次性总览
sudo INT=2 sckoc           # 2 秒采样窗口
sudo watch -n 3 sckoc      # 每 3 秒刷新
sudo sckoc dump 0x198 47:32
```

`--json` 输出机器可读文档（schema `sckoc-mon-v1`），字段为面板核心子集。完整字段说明见 `man sckoc`。

## 支持平台

- **Intel** family 6：Xeon W890/W790 平台、HEDT（X299）及更早支持 MSR 的型号
- **AMD** family 19h/1Ah（Zen3/4/5）：EPYC、Threadripper、消费级 Ryzen

部分字段依赖平台驱动，缺失时该字段单独降级、不影响其余输出：

| 字段 | 依赖 |
|---|---|
| Intel uncore/mesh 频率 | `intel-uncore-frequency(-tpmi)`（内核 5.6+/6.5+，RHEL 9 已回移）；无驱动时回退 uncore MSR 或 TPMI MMIO |
| AMD 温度 | `k10temp`；内核不支持该型号 per-CCD 传感器时回退 socket 级 Tctl，以 `*` 标记 |
| AMD FCLK/PPT/带宽 | `/dev/hsmp`（`amd_hsmp` 或 `hsmp_acpi`，另需 BIOS 开启 HSMP Support）。消费级 Ryzen 无 HSMP |
| DIMM/CPU 温度、DRAM 轨电压 | BMC + `ipmitool` |
| 板载电压 rails | Super I/O 驱动（`nct6775` 等） |

AMD 平台的驱动配置（k10temp、HSMP、Super I/O）可由 Releases 中的 `install.sh` 自动完成。

## 卸载

```bash
sudo dnf remove sckoc          # 或 sudo apt remove sckoc
sudo sckoc uninstall -y        # 包管理器之外的安装方式
```

## License

专有软件。Copyright (C) 2026 SkyWalkerAMD. All rights reserved.

授权内部使用（含商用），禁止再分发与逆向。完整条款见软件包内 `/usr/share/doc/sckoc/` 或 Releases 附带的 LICENSE。

分发的二进制静态链接 musl C 库（MIT）。

再分发授权或其他许可问题：scka7t@gmail.com
