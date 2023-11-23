#!/bin/bash
# setup.sh

echo 50000 | sudo tee /proc/sys/fs/inotify/max_user_watches

sudo chattr -i /etc/sysctl.conf
echo 'fs.inotify.max_user_watches=54000' | sudo tee -a /etc/sysctl.conf
sudo chattr +i /etc/sysctl.conf
sysctl -p

mkdir /ydutilities
mkdir /ydutilities/autorun
mkdir /ydutilities/autorun/000_logs
mkdir /ydutilities/autorun/001_todo
mkdir /ydutilities/autorun/002_completed
mkdir /ydutilities/yinstaller
mkdir /ydutilities/scripts

chmod -R 700 /ydutilities

chown -R ubuntu:ubuntu /ydutilities

# create auto run system shell script
# /ydutilities/scripts/autorunscripts990.sh
echo '#!/bin/bash

# preserve errors
set -e

LOGPATH="/ydutilities/autorun/000_logs"
SCRIPTPATH="/ydutilities/autorun/001_todo"
DATEVAR=$(date +20%y-%m-%d_%H-%M-%S)
COMPLETEDPATH="/ydutilities/autorun/002_completed"

sudo touch "$LOGPATH/autorunscripts990.touch"
' > /ydutilities/scripts/autorunscripts990.sh


echo '
file_num=$(/bin/ls -1 --file-type $SCRIPTPATH/*.sh | /bin/grep -v \' >> /ydutilities/scripts/autorunscripts990.sh

echo "'/$' | /usr/bin/wc -l)" >> /ydutilities/scripts/autorunscripts990.sh

echo '
file_num_start_ubuntu=$(/bin/ls -1 --file-type $SCRIPTPATH/.start | /bin/grep \' >> /ydutilities/scripts/autorunscripts990.sh

echo " -v '/$' | /usr/bin/wc -l)
" >> /ydutilities/scripts/autorunscripts990.sh

echo '
file_num_start_root=$(/bin/ls -1 --file-type $SCRIPTPATH/.start.root | /bin/grep \' >> /ydutilities/scripts/autorunscripts990.sh

echo " -v '/$' | /usr/bin/wc -l)
" >> /ydutilities/scripts/autorunscripts990.sh

echo '

NOW=$(date +%Y%m%d-%H%M%S)

if [ $file_num -gt 0 ] && [ $file_num_start_root -gt 0 ]; then
  sudo chmod 555 $SCRIPTPATH/*.sh
  sudo touch "$LOGPATH/autorunscripts990.start.touch"
  sudo rm $SCRIPTPATH/.start.root
  (
    for f in `ls -v $SCRIPTPATH/*.sh`; do
      # execute successfully or break
      sudo touch "$LOGPATH/try.touch.$DATEVAR"
      ( source "$f" || break 2>&1 ) |& tee "$f.$NOW"
      mv "$f" "$COMPLETEDPATH"
      mv "$f.$NOW" "$LOGPATH"
      break
    done
  ) |& tee "$LOGPATH/autorunscripts990_$DATEVAR.log"
fi
' >> /ydutilities/scripts/autorunscripts990.sh

chmod 500 /ydutilities/scripts/autorunscripts990.sh



# setup /etc/cron.d job for autorun every minute
#  > /ydutilities/autorun/000_logs/autorunscripts990.log 2>&1;
echo '#
# m h  dom mon dow  user  command

* * * * * root /ydutilities/scripts/autorunscripts990.sh
' > /etc/cron.d/autorunscripts990

chmod 644 /etc/cron.d/autorunscripts990




echo '#!/bin/sh -e

cd /home/admin/test-service
./start-service &

sleep 10

# Always leave this line here

/root/diskimage_mount.sh || exit 1

exit 0
' > /etc/rc.local


##########
# UPLOAD
# repo recipes from ./001_todo
# to
# /ydutilities/autorun/001_todo
# on the server
