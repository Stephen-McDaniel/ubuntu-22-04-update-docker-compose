#!/bin/bash

# prevent accidental run before reboot
sleep 7

curl -fsSL https://get.docker.com -o /home/ubuntu/get-docker.sh
sh /home/ubuntu/get-docker.sh

apt-get update


/usr/sbin/usermod -aG docker ubuntu


curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

apt-get install -y inotify-tools

/usr/sbin/reboot
