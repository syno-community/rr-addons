#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing daemon for hdddb"
  cp -vf /usr/bin/hdddb.sh /tmpRoot/usr/bin/hdddb.sh

  DEST="/tmpRoot/usr/lib/systemd/system/hdddb.service"
  echo "[Unit]"                                    >${DEST}
  echo "Description=HDDs/SSDs drives databases"   >>${DEST}
  echo "After=multi-user.target"                  >>${DEST}
  echo                                            >>${DEST}
  echo "[Service]"                                >>${DEST}
  echo "Type=oneshot"                             >>${DEST}
  echo "RemainAfterExit=true"                     >>${DEST}
  echo "ExecStart=/usr/bin/hdddb.sh -nfre"        >>${DEST}
  echo                                            >>${DEST}
  echo "[Install]"                                >>${DEST}
  echo "WantedBy=multi-user.target"               >>${DEST}

  mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /usr/lib/systemd/system/hdddb.service /tmpRoot/lib/systemd/system/multi-user.target.wants/hdddb.service
fi
