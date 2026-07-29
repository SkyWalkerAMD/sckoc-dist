<div align="center">

# sckoc

[![license](https://img.shields.io/badge/license-Proprietary-lightgrey)](https://github.com/SkyWalkerAMD/sckoc-dist/releases/latest)
![platform](https://img.shields.io/badge/platform-linux%20x86__64-blue)
![deps](https://img.shields.io/badge/runtime%20deps-none-brightgreen)

English | [中文](README.md)

**Distribution repository for sckoc.** No source here — this repository carries
the built artifacts and the package repository only.

</div>

A **read-only** hardware monitor for Intel and AMD servers and workstations.
Data comes from MSRs, SMBIOS, sysfs, the AMD HSMP mailbox, Intel TPMI MMIO and
the BMC over IPMI. `sckoc mon` gives a two-level live view, per socket and per
core, from a single sampling window: voltage, temperature, frequency, power and
C-state residency. `sckoc info` reports the platform configuration that does
not change at runtime. No register is ever written, so it runs under Secure
Boot and kernel lockdown (integrity).

## Installation

**Package repository** (configure once, then update through the package manager)

```bash
curl -fsSL https://skywalkeramd.github.io/sckoc-dist/setup.sh | sudo bash
sudo dnf install -y sckoc      # or on Debian/Ubuntu: sudo apt update && sudo apt install -y sckoc
```

`setup.sh` detects dnf/yum/apt and writes the matching repository configuration.

**Install a package directly** (see [Releases](https://github.com/SkyWalkerAMD/sckoc-dist/releases/latest))

```bash
sudo dnf install -y ./sckoc-<version>-1.x86_64.rpm     # one package for el7 / el8 / el9 / Fedora
sudo apt install -y ./sckoc_<version>-1_amd64.deb      # any amd64 Debian/Ubuntu
```

**Bare binary** (outside the package manager)

```bash
chmod +x sckoc-<version>-static-x86_64
sudo install -m755 sckoc-<version>-static-x86_64 /usr/local/bin/sckoc
sudo modprobe msr                                      # needed on Intel
```

## Runtime requirements

Root is required. Intel needs the kernel `msr` module — the rpm and deb load it
and set it to autoload; with the bare binary, run `modprobe msr` yourself
(`sckoc uncore` and `sckoc info` work without it).

The binary is statically linked against musl and has **no runtime library
dependencies**. The newest syscall it uses is `set_tid_address` (Linux 2.6), so
one file covers el7 (kernel 3.10) through rawhide — there is no per-distribution
build to pick.

`ipmitool` is optional: where it is installed and the platform has a BMC, it
supplies DIMM and CPU temperatures and the DRAM rail voltage; without it those
fields stay blank. `dmidecode` is not required — SMBIOS is read directly from
`/sys/firmware/dmi/tables/DMI`.

## Usage

```
sckoc [mon] [--json]      live per-socket and per-core view (default command)
sckoc info                static platform report
sckoc vid                 per-core VID / per-rail voltage
sckoc uncore [--json]     uncore/mesh frequency limits and BIOS boot values (Intel)
sckoc dump <reg> [hi:lo]  read one MSR per socket, optional bitfield
sckoc uninstall [-y]      remove sckoc
sckoc version | -V
sckoc help | -h
```

Environment: `INT=<sec>` sampling window (default 1), `DMI=<path>`,
`IPMITOOL=<path>`.

```bash
sudo sckoc                 # one-shot overview
sudo INT=2 sckoc           # 2-second sampling window
sudo watch -n 3 sckoc      # refresh every 3 s
sudo sckoc dump 0x198 47:32
```

`--json` emits a machine-readable document (schema `sckoc-mon-v1`) carrying the
core subset of the panel. Full field documentation is in `man sckoc`.

## Supported platforms

- **Intel** family 6: Xeon W890/W790 platforms, HEDT (X299) and earlier models with MSR support
- **AMD** family 19h/1Ah (Zen3/4/5): EPYC, Threadripper, consumer Ryzen

Some fields depend on platform drivers. A missing one degrades that field alone
and leaves the rest of the output intact:

| Field | Depends on |
|---|---|
| Intel uncore/mesh frequency | `intel-uncore-frequency(-tpmi)` (kernel 5.6+/6.5+, backported in RHEL 9); falls back to the uncore MSRs or TPMI MMIO |
| AMD temperature | `k10temp`; where the kernel lacks per-CCD sensors for the model, falls back to socket Tctl marked with `*` |
| AMD FCLK/PPT/bandwidth | `/dev/hsmp` (`amd_hsmp` or `hsmp_acpi`, plus HSMP Support enabled in the BIOS). Consumer Ryzen has no HSMP |
| DIMM/CPU temperature, DRAM rail voltage | BMC + `ipmitool` |
| Board voltage rails | a Super I/O driver such as `nct6775` |

On AMD, the driver setup (k10temp, HSMP, Super I/O) can be handled by the
`install.sh` shipped in Releases.

## Uninstall

```bash
sudo dnf remove sckoc          # or sudo apt remove sckoc
sudo sckoc uninstall -y        # for installs outside a package manager
```

## License

Proprietary. Copyright (C) 2026 SkyWalkerAMD. All rights reserved.

Licensed for internal use including commercial use; redistribution and reverse
engineering are not permitted. Full terms ship with the package under
`/usr/share/doc/sckoc/` and alongside the Releases.

The distributed binary is statically linked against the musl C library (MIT).

For redistribution rights or any other licensing question: scka7t@gmail.com
