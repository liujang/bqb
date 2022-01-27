#!/usr/bin/env bash
RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"
echo "export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
cd frp_0.38.0_linux_amd64 && mv frps /root/ && mv frpc /root/
cd /root/
wget https://github.com/fatedier/frp/releases/download/v0.39.0/frp_0.39.0_linux_amd64.tar.gz && tar -xvzf frp_0.39.0_linux_amd64.tar.gz
cd frp_0.39.0_linux_amd64 && rm -rf frps frpc
cd /root/
mv frps /root/frp_0.39.0_linux_amd64/ && mv frpc /root/frp_0.39.0_linux_amd64/
