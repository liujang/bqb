#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear

RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"
codename=`grep -Po 'VERSION="[0-9]+ \(\K[^)]+' /etc/os-release`

#检测nginx安装情况
check_nginx(){
if test -a /usr/sbin -a /etc/nginx/nginx.conf;then
        echo "--------nginx已安装--------"
    else
        echo "--------nginx未安装---------"
    fi
}


#源安装nginx
install_nginx(){
apt update -y
echo deb http://nginx.org/packages/debian/ $codename nginx | tee /etc/apt/sources.list.d/nginx.list
apt install gnupg2 -y
wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
apt update -y && apt install nginx -y
}
