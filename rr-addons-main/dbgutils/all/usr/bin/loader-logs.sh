#!/usr/bin/env ash
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

[ -z "${1}" ] && echo "Usage: ${0} {early|jrExit|rcExit|late|dsm}" && exit 1

LOADER_DISK_PART1="$(blkid -L RR1 | cut -d':' -f1)"
[ -z "${LOADER_DISK_PART1}" -a -b "/dev/synoboot1" ] && LOADER_DISK_PART1="/dev/synoboot1"
[ -z "${LOADER_DISK_PART1}" ] && echo "Boot disk not found" && exit 1

modprobe vfat
echo 1 >/proc/sys/kernel/syno_install_flag
mkdir -p "/mnt/p1"

mount "${LOADER_DISK_PART1}" "/mnt/p1"
rm -rf "/mnt/p1/logs/${1}"
mkdir -p "/mnt/p1/logs/${1}"
cp -vfR "/var/log/"* "/mnt/p1/logs/${1}"
dmesg >"/mnt/p1/logs/${1}/dmesg.log"
lsmod >"/mnt/p1/logs/${1}/lsmod.log"
lsusb >"/mnt/p1/logs/${1}/lsusb.log"
lspci -Qnnk >"/mnt/p1/logs/${1}/lspci.log" || true
sysctl -a >"/mnt/p1/logs/${1}/sysctl.log" || true
journalctl >"/mnt/p1/logs/${1}/journalctl.log" || true
ls -l /dev/ >"/mnt/p1/logs/${1}/disk-dev.log" || true
ls -l /dev/disk/by-id/ >"/mnt/p1/logs/${1}/disk-by-id.log" || true
ls -l /sys/class/scsi_host >"/mnt/p1/logs/${1}/disk-scsi_host.log" || true
ls -l /sys/class/net/*/device/driver >"/mnt/p1/logs/${1}/net-driver.log" || true
cat /sys/block/s*/device/syno_block_info >"/mnt/p1/logs/${1}/disk-syno_block_info.log" || true
[ -f "/addons/addons.sh" ] && cp -f "/addons/addons.sh" "/mnt/p1/logs/${1}/addons.sh" || true
[ -f "/addons/model.dts" ] && cp -f "/addons/model.dts" "/mnt/p1/logs/${1}/model.dts" || true

umount "/mnt/p1"
