#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "------------------tg:@ljfxz------------------"

gre_open(){
modprobe ip_gre
}

iptablse_install(){
if [[ ${iptables_exist} != "" ]]; then
echo -e "已经安装iptables"
else
apt-get update && apt-get install -y iptables
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore < /etc/iptables.up.rules
}

