#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing daemon for ACPI button"
  mkdir -p /tmpRoot/etc/acpi/events/
  cp -vf /etc/acpi/events/power /tmpRoot/etc/acpi/events/power
  cp -vf /etc/acpi/power.sh /tmpRoot/etc/acpi/power.sh
  cp -vf /usr/sbin/acpid /tmpRoot/usr/sbin/acpid

  if [ "6" = "$(/bin/get_key_value /etc.defaults/VERSION majorversion)" ]; then
    mkdir -p /tmpRoot/etc/init
    DEST=/tmpRoot/etc/init/acpid.conf
    echo 'description "ACPI daemon"'              >${DEST}
    echo 'author "Virtualization Team"'          >>${DEST}
    echo 'start on runlevel 1'                   >>${DEST}
    echo 'stop on runlevel [06]'                 >>${DEST}
    echo 'expect fork'                           >>${DEST}
    echo 'respawn'                               >>${DEST}
    echo 'respawn limit 5 10'                    >>${DEST}
    echo 'console log'                           >>${DEST}
    echo 'pre-start script'                      >>${DEST}
    echo '    date'                              >>${DEST}
    echo '    insmod /lib/modules/button.ko'     >>${DEST}
    echo 'end script'                            >>${DEST}
    echo 'post-stop script'                      >>${DEST}
    echo '    rmmod button'                      >>${DEST}
    echo 'end script'                            >>${DEST}
    echo 'exec /usr/sbin/acpid'                  >>${DEST}
  else
    DEST=/tmpRoot/usr/lib/systemd/system/acpid.service
    echo "[Unit]"                                 >${DEST}
    echo "Description=ACPI Daemon"               >>${DEST}
    echo "DefaultDependencies=no"                >>${DEST}
    echo "IgnoreOnIsolate=true"                  >>${DEST}
    echo "After=multi-user.target"               >>${DEST}
    echo                                         >>${DEST}
    echo "[Service]"                             >>${DEST}
    echo "Restart=always"                        >>${DEST}
    echo "RestartSec=30"                         >>${DEST}
    echo "ExecStartPre=-/sbin/modprobe button"   >>${DEST}
    echo "ExecStart=/usr/sbin/acpid -f"          >>${DEST}
    echo "ExecStopPost=-/sbin/modprobe -r button" >>${DEST}
    echo                                         >>${DEST}
    echo "[X-Synology]"                          >>${DEST}
    echo "Author=Virtualization Team"            >>${DEST}

    mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
    ln -vsf /usr/lib/systemd/system/acpid.service /tmpRoot/lib/systemd/system/multi-user.target.wants/acpid.service
  fi
fi
