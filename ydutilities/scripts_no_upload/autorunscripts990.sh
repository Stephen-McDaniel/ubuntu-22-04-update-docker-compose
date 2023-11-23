#!/bin/bash

# preserve errors
set -e

LOGPATH="/ydutilities/autorun/000_logs"
SCRIPTPATH="/ydutilities/autorun/001_todo"
DATEVAR=$(date +20%y-%m-%d_%H-%M-%S)
COMPLETEDPATH="/ydutilities/autorun/002_completed"

sudo touch "$LOGPATH/autorunscripts990.touch"


file_num=$(/bin/ls -1 --file-type $SCRIPTPATH/*.sh | /bin/grep -v \
'/$' | /usr/bin/wc -l)

file_num_start_ubuntu=$(/bin/ls -1 --file-type $SCRIPTPATH/.start | /bin/grep \
 -v '/$' | /usr/bin/wc -l)


file_num_start_root=$(/bin/ls -1 --file-type $SCRIPTPATH/.start.root | /bin/grep \
 -v '/$' | /usr/bin/wc -l)



NOW=$(date +%Y%m%d-%H%M%S)

if [ $file_num -gt 0 ] && [ $file_num_start_root -gt 0 ]; then
  sudo chmod 555 $SCRIPTPATH/*.sh
  sudo touch "$LOGPATH/autorunscripts990.start.touch"
  sudo rm $SCRIPTPATH/.start.root
  (
    for f in `ls -v $SCRIPTPATH/*.sh`; do
      # execute successfully or break
      sudo touch "$LOGPATH/try.touch.$DATEVAR"
      sudo ( source "$f" || break 2>&1 ) |& tee "$f.$NOW"
      mv "$f" "$COMPLETEDPATH"
      mv "$f.$NOW" "$LOGPATH"
      break
    done
  ) |& tee "$LOGPATH/autorunscripts990_$DATEVAR.log"
fi

