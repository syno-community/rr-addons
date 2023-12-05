#!/usr/bin/env ash
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

NAME="${1}"
SSID="${2}"
PSK="${3}"

if [ -n "${NAME}" -a -n "${SSID}" -a -n "${PSK}" ]; then
  if [ ! -d "/sys/class/net/${NAME}" ]; then
    echo "Interface ${NAME} not found"
    exit 1
  fi

  if [ -f "/var/run/wpa_supplicant.pid.${NAME}" ]; then
    kill -9 $(cat /var/run/wpa_supplicant.pid.${NAME})
    rm -f /var/run/wpa_supplicant.pid.${NAME}
  fi
  rm -f /etc/sysconfig/network-scripts/ifcfg-wlan* /etc.defaults/sysconfig/network-scripts/ifcfg-wlan*
  #echo -e "DEVICE=${NAME}\nONBOOT=yes\nBOOTPROTO=dhcp\nIPV6INIT=dhcp\nIPV6_ACCEPT_RA=1" >"/etc/sysconfig/network-scripts/ifcfg-${NAME}"
  #cp -f "/etc/sysconfig/network-scripts/ifcfg-${NAME}" "/etc.defaults/sysconfig/network-scripts/ifcfg-${NAME}"
  echo -e "ctrl_interface=/var/run/wpa_supplicant\nupdate_config=1\nnetwork={\n        ssid=\"${SSID}\"\n        priority=1\n        psk=\"${PSK}\"\n}" >/usr/syno/etc/wpa_supplicant.conf.${NAME}
  /usr/sbin/wpa_supplicant -i ${NAME} -c /usr/syno/etc/wpa_supplicant.conf.${NAME} -B -P /var/run/wpa_supplicant.pid.${NAME}
  /usr/syno/sbin/synonet --dhcp ${NAME}
fi
