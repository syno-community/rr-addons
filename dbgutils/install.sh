#!/usr/bin/env ash

if [ "${1}" = "early" ]; then
  loader-logs.sh early
  echo "Starting ttyd..."
  /usr/sbin/ttyd /usr/bin/ash -l &
elif [ "${1}" = "jrExit" ]; then
  loader-logs.sh jrExit
elif [ "${1}" = "rcExit" ]; then
  loader-logs.sh rcExit
elif [ "${1}" = "late" ]; then
  echo "Installing addon dbgutils"
  echo "Killing ttyd..."
  /usr/bin/killall ttyd
  echo "Copying utils"
  cp -vf /usr/bin/bc /tmpRoot/usr/bin/
  cp -vf /usr/bin/dtc /tmpRoot/usr/bin/
  cp -vf /usr/bin/lsscsi /tmpRoot/usr/bin/
  cp -vf /usr/bin/nano /tmpRoot/usr/bin/
  cp -vf /usr/bin/strace /tmpRoot/usr/bin/
  cp -vf /usr/bin/lsof /tmpRoot/usr/bin/
  cp -vf /usr/bin/loader-logs.sh /tmpRoot/usr/bin/
  cp -vf /usr/sbin/ttyd /tmpRoot/usr/sbin/
  ln -vsf /usr/bin/kmod /tmpRoot/usr/sbin/modinfo
  loader-logs.sh late

  DEST="/tmpRoot/lib/systemd/system/savelogs.service"
  echo "[Unit]"                                                       >${DEST}
  echo "Description=RR save logs for debug"                          >>${DEST}
  echo                                                               >>${DEST}
  echo "[Service]"                                                   >>${DEST}
  echo "Type=oneshot"                                                >>${DEST}
  echo "RemainAfterExit=true"                                        >>${DEST}
  echo "ExecStop=/bin/loader-logs.sh dsm"                            >>${DEST}
  echo                                                               >>${DEST}
  echo "[Install]"                                                   >>${DEST}
  echo "WantedBy=multi-user.target"                                  >>${DEST}

  mkdir -p /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /lib/systemd/system/savelogs.service /tmpRoot/lib/systemd/system/multi-user.target.wants/savelogs.service
fi
