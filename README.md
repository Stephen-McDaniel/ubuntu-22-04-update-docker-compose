##   YakData Ubuntu 22.04 Update, Install Docker and Install Docker Compose

A starting repository for use with YakData projects that rely on Docker and Docker Compose.

<img src="./YakData_Logo_Name_White_Trans.png" alt="YakData_Logo_Name_White_Trans" style="zoom:5%;" />
  
+ [🎶 Features](#-features)
+ [🔦 Highlights](#-highlights)
+ [🧰 Install](#-install)
+ [🔐 LICENSE](#-license)
+ [💥 Is this battle tested? Should I use this?](#-is-this-battle-tested-should-i-use-this)
+ [📫 Issues](#-issues)
+ [📘 Docs](#-docs)
+ [💼 Alternatives](#-alternatives)

## 🎶 Features

* This YakData repository, ***ubuntu_22_04_update_docker_compose***, is a simple cron.d and script based system built for running bash commands from uploaded files ("recipes") in a sequential manner. It was built for and tested on Ubuntu 22.04 (LTS.) 

* By running the shell script "recipes" included in this repository, you will have an updated, upgraded Ubuntu 22.04 server with docker and docker-compose installed. You will also have a system to run future recipe scripts and retains them with the datetime of execution appended to the script name. 

* You can continue using this system for future unattended major and minor updates. Just upload your recipe scripts and then touch **/ydutilities/autorun/001_todo/.start.root** (to run the next script as root).

## 🔦 Highlights

1) Run the setup commands in **setup.sh** as root or sudo su -.
2) Upload the recipes included in this repo to **/ydutilities/autorun/001_todo**.
3) The system auto-runs the recipe scripts, one per minute, when it sees a file at  **/ydutilities/autorun/001_todo/.start.root**.. 
4) As each script starts, the system moves it to **/ydutilities/autorun/002_completed**. The file name is suffixed with a datetime stamp, creating a history of all update/install scripts run on the system.
5) When all the recipes in this repository have finished running, an updated and upgraded Ubuntu 22.04 host with docker and docker-compose are the end product.

## 🧰 Install

1. Setup a Ubuntu 22.04 server as your host system. Our preferred cloud vendors are Vultr (affordability and speed),  AWS (almost any configuration conceivable) and Azure (for clients who are Microsoft oriented.)

2. Login to your new server as root. For example:

```bash
keyfile='/path/to/your/pem/my.pem'
host=my.host.com

ssh -i "$keyfile" "ubuntu@$host"
```

3. Note, if you are not logged in as root, switch to the root user with this command: 

```bash
sudo su -
```

4. Copy the following set of commands and paste them into your server session. 

```bash
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
sudo echo '#
# m h  dom mon dow  user  command

* * * * * root /ydutilities/scripts/autorunscripts990.sh
' > /etc/cron.d/autorunscripts990

sudo chmod 644 /etc/cron.d/autorunscripts990




sudo echo '#!/bin/sh -e

cd /home/admin/test-service
./start-service &

sleep 10

# Always leave this line here

/root/diskimage_mount.sh || exit 1

exit 0
' > /etc/rc.local

exit
```



5. Upload the files from this repository at **/ydutilities/autorun/001_todo** to **/ydutilities/autorun/001_todo** Here is how you could use rsync to do this.
```bash
# from local to server
# rsync must be installed on local and the server
dir_local="/path/to/downloaded/and/unzippped/repo/ydutilities/autorun/001_todo/"
dir_remote=/ydutilities/autorun/001_todo
keyfile='/path/to/your/pem/my.pem'
host=my.host.com

cd "$dir_local"

rsync --progress -h -v -r -P -t -z --no-o --no-g \
      -e "ssh -i $keyfile" \
      $dir_local ubuntu@$host:$dir_remote --delete
```

6. The system checks for a ***.start.root*** file every minute. This is the trigger file for executing the next shell script in the directory. The "next" file is based on a sort of the shell file names found in the directory.
   
7. The next script file is executed as root. If you want the sequence of remaining files to execute sequentially, issue a **<u>/usr/bin/touch /ydutilities/autorun/001_todo/.start.root</u>** command at the end of the script. 
   
8. By running the recipes in this repository, you will have an updated, upgraded Ubuntu 22.04 server with docker and docker-compose installed. Expect 3 reboots before completion.

9. To verify completion of all updates:
```bash
ls -al /ydutilities/autorun/001_todo
```
Should be empty. 

And 
```bash
ls -al /ydutilities/autorun/002_completed
```
Should have all three recipe files.

## 🔐 LICENSE

This repository is licensed under [Apache version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

## 💥 Is this battle tested? Should I use this?

We have used several versions of this repository privately for about 30 server setups over the past year. We will continue using this system and improving it with new releases based on community feedback, client feedback and our own experience.

If you love this project, please consider it a ⭐.

## 📫 Issues

Please share issues here in this repository [Issues](https://github.com/Stephen-McDaniel/ubuntu-22-04-update-docker-compose/issues).

## 📘 Docs

Ubuntu docs: https://ubuntu.com/server/docs/installation

Docker docs: https://docs.docker.com/

Docker Compose docs: https://docs.docker.com/compose/

## 💼 Alternatives

Do it yourself. Some people just like to do it all!

Use YakData AWS AMI images of our projects.
