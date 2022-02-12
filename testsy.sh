#!/usr/bin/env bash
RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"
echo "export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
echo -e "
 ${GREEN} 1.落地机
 ${GREEN} 2.中转机
 "
read -p "输入选项:" bNum
if [ "$bNum" = "1" ] ;then
echo "
[Unit]
Description=frpc service
After=network.target network-online.target syslog.target
Wants=network.target network-online.target
[Service]
Type=simple
#启动服务的命令（此处写你的frpc的实际安装目录）
ExecStart=/root/frp_0.39.0_linux_amd64/frpc -c /root/frp_0.39.0_linux_amd64/frpc.ini
[Install]
WantedBy=multi-user.target
" > /lib/systemd/system/frpc.service
systemctl enable frpc
elif [ "$bNum" = "2" ] ;then
echo "
[Unit]
Description=frps service
After=network.target network-online.target syslog.target
Wants=network.target network-online.target
[Service]
Type=simple
#启动服务的命令（此处写你的frps的实际安装目录）
ExecStart=/root/frp_0.39.0_linux_amd64/frps -c /root/frp_0.39.0_linux_amd64/frps.ini
[Install]
WantedBy=multi-user.target
" > /lib/systemd/system/frps.service
systemctl enable frps
fi
