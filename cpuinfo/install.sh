#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing daemon for CPU Info"
  cp -vf /usr/bin/cpuinfo.sh /tmpRoot/usr/bin/cpuinfo.sh

  DEST="/tmpRoot/usr/lib/systemd/system/cpuinfo.service"
  echo "[Unit]"                               >${DEST}
  echo "Description=Adds correct CPU Info"   >>${DEST}
  echo "After=multi-user.target"             >>${DEST}
  echo                                       >>${DEST}
  echo "[Service]"                           >>${DEST}
  echo "Type=oneshot"                        >>${DEST}
  echo "RemainAfterExit=true"                >>${DEST}
  echo "ExecStart=/usr/bin/cpuinfo.sh"       >>${DEST}
  echo                                       >>${DEST}
  echo "[Install]"                           >>${DEST}
  echo "WantedBy=multi-user.target"          >>${DEST}

  mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /usr/lib/systemd/system/cpuinfo.service /tmpRoot/lib/systemd/system/multi-user.target.wants/cpuinfo.service
fi
