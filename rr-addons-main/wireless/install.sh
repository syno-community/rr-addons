#!/usr/bin/env ash
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

if [ "${1}" = "late" ]; then
  echo "Installing daemon for wireless"

  cp -vf /usr/bin/wireless_supplicant.sh /tmpRoot/usr/bin
  cp -vf /usr/sbin/iw /tmpRoot/usr/sbin

  if [ ! -f /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db ]; then
    echo "copy esynoscheduler.db"
    mkdir -p /tmpRoot/usr/syno/etc/esynoscheduler
    cp -vf /addons/esynoscheduler.db /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db
  fi

  export LD_LIBRARY_PATH=/tmpRoot/bin:/tmpRoot/lib

  if echo "SELECT * FROM task;" | /tmpRoot/bin/sqlite3 /usr/syno/etc/esynoscheduler/esynoscheduler.db | grep -q "Wireless"; then
    echo "wireless task already exists"
  else
    echo "insert wireless task to esynoscheduler.db"
    /tmpRoot/bin/sqlite3 /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
INSERT INTO task VALUES('Wireless', '', 'bootup', '', 0, 0, 0, 0, '', 0, '/usr/bin/wireless_supplicant.sh "wlan0" "SSID" "PASSWD"', 'script', '{}', '', '', '{}', '{}');
EOF
  fi
fi
