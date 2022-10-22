#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
gateway=`route -n | grep UG | awk '{print $2}'`
genmask=`ifconfig eth0 | grep broadcast | awk '{print $4}'`
read -p "添加的ip(不可重复):" ip
read -p "输入网卡序号(不可重复):" Num
echo "
auto eth0:$Num
iface eth0:$Num inet static
address $ip
netmask $genmask
gateway $gateway
" >> /etc/network/interfaces
service networking restart
echo "已完成添加"
