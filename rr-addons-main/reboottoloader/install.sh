#!/usr/bin/env ash
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

if [ "${1}" = "late" ]; then
  echo "Installing addon reboottoloader - late"

  cp -vf /usr/bin/loader-reboot.sh /tmpRoot/usr/bin
  cp -vf /usr/bin/grub-editenv /tmpRoot/usr/bin

  if [ ! -f /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db ]; then
    echo "copy esynoscheduler.db"
    mkdir -p /tmpRoot/usr/syno/etc/esynoscheduler
    cp -vf /addons/esynoscheduler.db /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db
  fi
  echo "insert reboottoloader task to esynoscheduler.db"
  export LD_LIBRARY_PATH=/tmpRoot/bin:/tmpRoot/lib
  /tmpRoot/bin/sqlite3 /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
DELETE FROM task WHERE task_name LIKE 'RebootToLoader';
INSERT INTO task VALUES('RebootToLoader', '', 'shutdown', '', 0, 0, 0, 0, '', 0, '/usr/bin/loader-reboot.sh "config"', 'script', '{}', '', '', '{}', '{}');
EOF
fi
