#!/usr/bin/env ash
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

if [ "${1}" = "late" ]; then
  echo "Installing daemon for revert"

  if [ -f /tmpRoot/usr/sbin/revert.sh ]; then
    echo "exec revert.sh"
    chmod +x /tmpRoot/usr/sbin/revert.sh
    /tmpRoot/usr/sbin/revert.sh
    rm -f /tmpRoot/usr/sbin/revert.sh
  fi
  echo "touch revert.sh"
  touch /tmpRoot/usr/sbin/revert.sh
fi