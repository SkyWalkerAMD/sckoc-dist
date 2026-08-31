# sckoc

Read-only hardware monitor for Intel and AMD servers and workstations.
A single statically linked binary with no runtime dependencies.

This repository holds the built packages and the software repository only.
Source, full documentation and the engineering log live at
[SkyWalkerAMD/sckoc](https://github.com/SkyWalkerAMD/sckoc).

[中文](README.md)

## Install

**Package repository** (recommended - add once, updates follow)

```bash
curl -fsSL https://skywalkeramd.github.io/sckoc-dist/setup.sh | sudo bash
sudo dnf install sckoc          # RHEL / Rocky / CentOS
sudo apt install sckoc          # Debian / Ubuntu
```

`setup.sh` detects the distribution and writes the matching yum or apt
source.

**A single package** (downloaded from this repository's Releases)

```bash
sudo dnf install ./sckoc-*.rpm
sudo apt install ./sckoc_*.deb
```

## Uninstall

```bash
sudo dnf remove sckoc           # or sudo apt remove sckoc
```

Removal also clears the `modules-load.d` drop-in, the cached BMC probe
results under `/run/sckoc-*`, `/etc/sckoc/mode`, and any DKMS modules the
install built.

To drop the repository as well:

```bash
sudo rm -f /etc/yum.repos.d/sckoc.repo                             # RHEL family
sudo rm -f /etc/apt/sources.list.d/sckoc.list && sudo apt update    # Debian family
```

## Usage

```bash
sckoc                # overview panel
sckoc info           # static hardware report
sckoc mon            # live monitor
sckoc help           # every command
```

Most readings need no root. The MSR, SMN and PM table paths do, and say so
when they are reached.
