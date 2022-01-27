#!/usr/bin/env bash
RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"
echo "export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
cd frp_0.38.0_linux_amd64 && mv frps.ini /root/ && mv frpc.ini /root/
cd /root/
rm -rf frp_0.38.0_linux_amd64 frp_0.39.0_linux_amd64.tar.gz frp_0.38.0_linux_amd64.tar.gz
wget https://github.com/fatedier/frp/releases/download/v0.39.0/frp_0.39.0_linux_amd64.tar.gz && tar -xvzf frp_0.39.0_linux_amd64.tar.gz
cd frp_0.39.0_linux_amd64 && rm -rf frps.ini frpc.ini
cd /root/
mv frps.ini /root/frp_0.39.0_linux_amd64/ && mv frpc.ini /root/frp_0.39.0_linux_amd64/
