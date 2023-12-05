#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing daemon for addincards"
  cp -vf /usr/bin/addincards.sh /tmpRoot/usr/bin/addincards.sh

  DEST="/tmpRoot/usr/lib/systemd/system/addincards.service"
  echo "[Unit]"                                        >${DEST}
  echo "Description=update Add-in cards and usb.map"  >>${DEST}
  echo "After=multi-user.target"                      >>${DEST}
  echo                                                >>${DEST}
  echo "[Service]"                                    >>${DEST}
  echo "Type=oneshot"                                 >>${DEST}
  echo "RemainAfterExit=true"                         >>${DEST}
  echo "ExecStart=/usr/bin/addincards.sh"             >>${DEST}
  echo                                                >>${DEST}
  echo "[Install]"                                    >>${DEST}
  echo "WantedBy=multi-user.target"                   >>${DEST}

  mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /usr/lib/systemd/system/addincards.service /tmpRoot/lib/systemd/system/multi-user.target.wants/addincards.service
fi
