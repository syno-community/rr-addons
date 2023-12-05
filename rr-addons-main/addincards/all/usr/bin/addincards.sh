#!/usr/bin/env bash
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
# 
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.


model="$(cat /proc/sys/kernel/syno_hw_version)"

# adapter_cards.conf
FILE="/usr/syno/etc.defaults/adapter_cards.conf"
[ ! -f "${FILE}.bak" ] && cp -f "${FILE}" "${FILE}.bak"
rm -f ${FILE}
for N in `cat "${FILE}.bak" | grep '\['`; do
  echo "${N}" >> "${FILE}"
  echo "${model}=yes" >> "${FILE}"
done
chmod a+rx "${FILE}"
cp -f "${FILE}" "${FILE/\.defaults/}"

# usb.map
FILE="/usr/syno/etc.defaults/usb.map"
STATUS=$(curl -kL -w "%{http_code}" "http://www.linux-usb.org/usb.ids" -o "${FILE}.ids")
if [ $? -ne 0 -o ${STATUS} -ne 200 ]; then
  echo "usb.ids download error!"
else
  [ ! -f "${FILE}.bak" ] && cp -f "${FILE}" "${FILE}.bak"
  mv -f "${FILE}.ids" "${FILE}"
  chmod a+rx "${FILE}"
fi
cp -f "${FILE}" "${FILE/\.defaults/}"

exit 0