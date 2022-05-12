#!/usr/bin/env bash
RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"
echo "export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
wget -N --no-check-certificate -P /etc "https://h5ai.ljfxz.net/bqbdns/area/resolv.conf.1"
rm -rf /etc/resolv.conf
cp /etc/resolv.conf.1 /etc/resolv.conf
rm -rf /etc/resolv.conf.1
systemctl restart NetworkManager.service
systemctl restart systemd-resolved.service
