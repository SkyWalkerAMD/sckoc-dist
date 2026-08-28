<div align="center">

# sckoc

[![license](https://img.shields.io/badge/license-Proprietary-lightgrey)](https://github.com/SkyWalkerAMD/sckoc-dist/releases/latest)
![platform](https://img.shields.io/badge/platform-linux%20x86__64-blue)
![deps](https://img.shields.io/badge/runtime%20deps-none-brightgreen)

English | [中文](README.md)

A **read-only** hardware monitor for Intel and AMD servers and workstations

</div>

One command shows what the CPU is doing right now: per-core frequency,
temperature, voltage, power and load, plus memory, cache and power limits.

**Read-only** — it writes no register and changes no setting, so it is safe to
run on a machine that is busy doing real work.

## Install

The repository is the easiest route; set it up once and updates come with the
rest of the system:

```bash
curl -fsSL https://skywalkeramd.github.io/sckoc-dist/setup.sh | sudo bash
```

Or install a package from [Releases](https://github.com/SkyWalkerAMD/sckoc-dist/releases/latest) directly:

```bash
sudo dnf install -y ./sckoc-<version>-1.x86_64.rpm    # one package for el7 / el8 / el9 / Fedora
sudo apt install -y ./sckoc_<version>-1_amd64.deb     # any amd64 Debian / Ubuntu
```

Or just take the binary and skip the package manager:

```bash
chmod +x sckoc-<version>-static-x86_64
sudo install -m755 sckoc-<version>-static-x86_64 /usr/local/bin/sckoc
sudo modprobe msr                                     # needed on Intel
```

## Getting started

```bash
sudo sckoc            # live overview
sudo sckoc info       # platform report
sudo sckoc --watch    # refresh every 2 seconds
```

That is most of it. On a many-core machine the table splits into columns by
itself — only when the window is too short for one list, and back to a single
list when you make the window taller.

## Commands you will use

| Command | What it does |
|---|---|
| `sckoc` | live overview, per socket and per core |
| `sckoc info` | platform report: security state, ratio ceilings, power limits, memory, cache |
| `sckoc vid` | per-core requested voltage |
| `sckoc uncore` | uncore / mesh frequency limits (Intel) |
| `sckoc --watch=3` | redraw in place every 3 seconds |
| `sckoc --json` | machine-readable output, for feeding a monitoring system |
| `sckoc help` | full help |

`man sckoc` has the details.

## What it needs

Root. On Intel the kernel `msr` module is required — the rpm and deb set that
up for you; with the bare binary run `sudo modprobe msr` once.

The binary is statically linked and has **no runtime library dependencies**, so
one file runs from el7 (kernel 3.10) to the newest distribution. There is no
version to pick.

If `ipmitool` is installed, BMC DIMM and CPU temperatures and the DRAM rail
voltage appear as well; without it those fields stay blank and nothing else
changes.

## Why is something showing N/A?

That is by design — when a value cannot be read, sckoc says `N/A` and explains
why rather than inventing a number. The usual causes:

| Shown | Cause |
|---|---|
| Intel uncore/mesh is N/A | no `intel-uncore-frequency` driver (in-kernel since 5.6) |
| AMD temperature is N/A | no `k10temp`, or a kernel too old to know this CPU |
| AMD FCLK / PPT is N/A | the kernel has no HSMP driver. EPYC / Threadripper PRO need 5.18 or newer, desktop-socket Threadripper needs 6.10 or newer; consumer Ryzen goes through `ryzen_smu`. Only if the kernel is new enough does the BIOS HSMP Support setting come into it |
| memory temperature, DRAM voltage blank | no BMC on this machine, or `ipmitool` not installed |

On AMD those drivers are set up in the background when the package installs.
Progress:

```bash
journalctl -u sckoc-setup.service
```

Where the machine cannot reach GitHub, a line of `GH_PROXY=auto` in
`/etc/sckoc/setup.conf` picks a working mirror; `GH_PROXY=off` pins the direct
route. On a kernel too old none of this helps — a newer kernel is the only
thing that fills those fields in.

## Uninstall

```bash
sudo dnf remove sckoc      # or sudo apt remove sckoc
sudo sckoc uninstall -y    # if it was not installed by a package manager
```

## License

Proprietary. Copyright (C) 2026 SkyWalkerAMD. All rights reserved.

Licensed for internal use including commercial use; redistribution and reverse
engineering are not permitted. Full terms ship with the package under
`/usr/share/doc/sckoc/`. The distributed binary is statically linked against
the musl C library (MIT).

For redistribution rights or any other licensing question: scka7t@gmail.com
