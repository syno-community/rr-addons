#!/usr/bin/env ash

if [ "${1}" = "jrExit" ]; then
  for N in $(ls /sys/class/net/ | grep eth); do
    /usr/bin/ethtool -s ${N} wol g 2>/dev/null
  done
elif [ "${1}" = "late" ]; then
  echo "Creating service to exec ethtool"
  cp -vf /usr/bin/ethtool /tmpRoot/usr/bin/ethtool
  cp -vf /usr/bin/wol.sh /tmpRoot/usr/bin/wol.sh

  DEST="/tmpRoot/lib/systemd/system/ethtool.service"
  echo "[Unit]"                                                               > ${DEST}
  echo "Description=ARPL force WoL on ethN"                                   >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Service]"                                                            >>${DEST}
  echo "Type=oneshot"                                                         >>${DEST}
  echo "RemainAfterExit=true"                                                 >>${DEST}
  echo "ExecStart=/usr/bin/wol.sh"                                            >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Install]"                                                            >>${DEST}
  echo "WantedBy=multi-user.target"                                           >>${DEST}

  mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /lib/systemd/system/ethtool.service /tmpRoot/lib/systemd/system/multi-user.target.wants/ethtool.service
fi
