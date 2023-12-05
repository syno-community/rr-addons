#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing daemon for nvmevolume"
  cp -vf /usr/bin/bc /tmpRoot/usr/bin/bc
  cp -vf /usr/bin/nvmevolume.sh /tmpRoot/usr/bin/nvmevolume.sh

  DEST="/tmpRoot/usr/lib/systemd/system/nvmevolume.service"
  echo "[Unit]"                                    >${DEST}
  echo "Description=Enable M2 volume"             >>${DEST}
  echo "After=multi-user.target"                  >>${DEST}
  echo                                            >>${DEST}
  echo "[Service]"                                >>${DEST}
  echo "Type=oneshot"                             >>${DEST}
  echo "RemainAfterExit=true"                     >>${DEST}
  echo "ExecStart=/usr/bin/nvmevolume.sh -ne"     >>${DEST}
  echo                                            >>${DEST}
  echo "[Install]"                                >>${DEST}
  echo "WantedBy=multi-user.target"               >>${DEST}

  mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /usr/lib/systemd/system/nvmevolume.service /tmpRoot/lib/systemd/system/multi-user.target.wants/nvmevolume.service
fi
