#!/usr/bin/env bash
# SPDX-License-Identifier: LicenseRef-Proprietary
# Adds the sckoc package repository. Detects the distro family.
# Copyright (C) 2026 SkyWalkerAMD. All rights reserved.
#
#   curl -fsSL https://skywalkeramd.github.io/sckoc-dist/setup.sh | sudo bash
set -e
BASEURL="https://skywalkeramd.github.io/sckoc-dist"
GPGCHECK=0

[ "$(id -u)" = 0 ] || { echo "run as root: curl -fsSL $BASEURL/setup.sh | sudo bash"; exit 1; }

fetch(){ if command -v curl >/dev/null 2>&1; then curl -fsSL "$1"; else wget -qO- "$1"; fi; }

if command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
  install -d /etc/yum.repos.d
  fetch "$BASEURL/yum/sckoc.repo" > /etc/yum.repos.d/sckoc.repo
  if [ "$GPGCHECK" = 1 ]; then
    fetch "$BASEURL/RPM-GPG-KEY-sckoc" > /etc/pki/rpm-gpg/RPM-GPG-KEY-sckoc
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-sckoc
  fi
  echo "added /etc/yum.repos.d/sckoc.repo"
  echo "now run: sudo dnf install sckoc   (or yum on el7)"

elif command -v apt-get >/dev/null 2>&1; then
  install -d /etc/apt/sources.list.d
  if [ "$GPGCHECK" = 1 ]; then
    install -d /usr/share/keyrings
    fetch "$BASEURL/RPM-GPG-KEY-sckoc" | gpg --dearmor -o /usr/share/keyrings/sckoc.gpg
  fi
  fetch "$BASEURL/apt/sckoc.list" > /etc/apt/sources.list.d/sckoc.list
  echo "added /etc/apt/sources.list.d/sckoc.list"
  echo "now run: sudo apt update && sudo apt install sckoc"

else
  echo "no dnf/yum/apt-get found."
  echo "download the package directly from $BASEURL"
  exit 1
fi
