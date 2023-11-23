#!/bin/bash

/usr/bin/apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
/usr/bin/apt-get -y autoremove
/usr/bin/apt-get -y autoclean
/usr/bin/apt-get -y install curl software-properties-common apt-transport-https

/usr/bin/touch /ydutilities/autorun/001_todo/.start.root

/usr/sbin/reboot
