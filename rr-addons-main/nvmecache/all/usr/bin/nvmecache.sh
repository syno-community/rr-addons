#!/usr/bin/env bash
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
# 
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
#
# |       models      |     1st      |     2nd      |
# | DS918+            | 0000:00:13.1 | 0000:00:13.2 |
# | RS1619xs+         | 0000:00:03.2 | 0000:00:03.3 |
# | DS419+, DS1019+   | 0000:00:14.1 |              |
# | DS719+, DS1621xs+ | 0000:00:01.1 | 0000:00:01.0 |


models=(DS918+ RS1619xs+ DS419+ DS1019+ DS719+ DS1621xs+)
declare -A PCI1ST
PCI1ST[0]=$(echo -n "0000:00:13.1" | xxd -ps)
PCI1ST[1]=$(echo -n "0000:00:03.2" | xxd -ps)
PCI1ST[2]=$(echo -n "0000:00:14.1" | xxd -ps)
PCI1ST[3]=$(echo -n "0000:00:01.1" | xxd -ps)
declare -A PCI2ND
PCI2ND[0]=$(echo -n "0000:00:13.2" | xxd -ps)
PCI2ND[1]=$(echo -n "0000:00:03.3" | xxd -ps)
PCI2ND[2]=$(echo -n "0000:00:99.9" | xxd -ps)  # dummy
PCI2ND[3]=$(echo -n "0000:00:01.0" | xxd -ps)

model=$(cat /proc/sys/kernel/syno_hw_version)
if ! echo ${models[@]} | grep -q ${model}; then
  echo "${model} is not in models"
  exit 0
fi

[ ! -f /usr/lib/libsynonvme.so.1.bak ] && cp -vfp /usr/lib/libsynonvme.so.1 /usr/lib/libsynonvme.so.1.bak

# cp -vfp /usr/lib/libsynonvme.so.1.bak /usr/lib/libsynonvme.so.1  # TODO: Because so was called, rewriting resulted in coredump, so I need to find another way.

num=1
for N in `ls /sys/class/nvme`; do
  PCISTR=`readlink /sys/class/nvme/${N} | sed 's|^.*\(pci.*\)|\1|' | cut -d'/' -f2`
  LOCHEX=`echo -n "${PCISTR}" | xxd  -c 256 -ps`
  echo "${N} - ${PCISTR} - ${LOCHEX}"
  if [ ${num} -eq 1 ]; then
    KO_SIZE="$(xxd -p /usr/lib/libsynonvme.so.1 | wc -c)"
    xxd -c ${KO_SIZE} -p /usr/lib/libsynonvme.so.1 | sed "s/${PCI1ST[0]}/$LOCHEX/; s/${PCI1ST[1]}/$LOCHEX/; s/${PCI1ST[2]}/$LOCHEX/; s/${PCI1ST[3]}/$LOCHEX/" | xxd -r -p - /usr/lib/libsynonvme.so.1
  elif  [ ${num} -eq 2 ]; then
    KO_SIZE="$(xxd -p /usr/lib/libsynonvme.so.1 | wc -c)"
    xxd -c ${KO_SIZE} -p /usr/lib/libsynonvme.so.1 | sed "s/${PCI2ND[0]}/$LOCHEX/; s/${PCI2ND[1]}/$LOCHEX/; s/${PCI2ND[2]}/$LOCHEX/; s/${PCI2ND[3]}/$LOCHEX/" | xxd -r -p - /usr/lib/libsynonvme.so.1
  else
    break
  fi
  num=$((num +1))
done

exit 0