# sckoc

Intel / AMD 服务器与工作站的只读硬件监控工具。单个静态链接二进制，无运行时依赖。

本仓库只存放编译产物与软件源。源码、完整文档和开发日志在
[SkyWalkerAMD/sckoc](https://github.com/SkyWalkerAMD/sckoc)。

[English](README.en.md)

## 安装

**软件仓库**（推荐，添加一次即可自动更新）

```bash
curl -fsSL https://skywalkeramd.github.io/sckoc-dist/setup.sh | sudo bash
sudo dnf install sckoc          # RHEL / Rocky / CentOS
sudo apt install sckoc          # Debian / Ubuntu
```

`setup.sh` 会识别发行版并写入对应的 yum 或 apt 源。

**单个包**（从本仓库 Releases 下载后本地安装）

```bash
sudo dnf install ./sckoc-*.rpm
sudo apt install ./sckoc_*.deb
```

## 卸载

```bash
sudo dnf remove sckoc           # 或 sudo apt remove sckoc
```

卸载会一并清除 `modules-load.d` drop-in、`/run/sckoc-*` 下的 BMC 探测缓存、
`/etc/sckoc/mode`，以及安装过程自行编译的 DKMS 模块。

移除软件源：

```bash
sudo rm -f /etc/yum.repos.d/sckoc.repo                             # RHEL 系
sudo rm -f /etc/apt/sources.list.d/sckoc.list && sudo apt update    # Debian 系
```

## 用法

```bash
sckoc                # 概览面板
sckoc info           # 静态硬件报告
sckoc mon            # 实时监控
sckoc help           # 全部命令
```

多数读数不需要 root。MSR、SMN 与 PM table 相关的部分需要，届时会明确提示。
