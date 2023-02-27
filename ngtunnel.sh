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
        nginx -v
    else
        echo "--------nginx未安装---------"
    fi
}

#源安装nginx
install_nginx(){
mv /etc/apt/sources.list /etc/apt/sources.list.backup
echo -e "
 ${GREEN} 1.海外机
 ${GREEN} 2.国内机
 "
read -p "输入选项:" aNum
if [ "$aNum" = "1" ];then
echo "
deb http://deb.debian.org/debian ${codename} main
deb-src http://deb.debian.org/debian ${codename} main
deb http://security.debian.org/debian-security ${codename}-security main
deb-src http://security.debian.org/debian-security ${codename}-security main
deb http://deb.debian.org/debian ${codename}-updates main
deb-src http://deb.debian.org/debian ${codename}-updates main
deb http://deb.debian.org/debian ${codename}-backports main
deb-src http://deb.debian.org/debian ${codename}-backports main
" > /etc/apt/sources.list
elif [ "$aNum" = "2" ];then
echo "
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${codename} main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${codename}-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${codename}-backports main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security ${codename}-security main contrib non-free
" > /etc/apt/sources.list
fi
apt update -y
echo deb http://nginx.org/packages/debian/ ${codename} nginx | tee /etc/apt/sources.list.d/nginx.list
apt install gnupg2 -y
wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
apt update -y && apt install nginx -y
rm -rf etc/nginx/nginx.conf
echo "
worker_priority -20;
worker_processes auto;
worker_cpu_affinity auto;
worker_rlimit_nofile 131072;
error_log /dev/null;

events {
    worker_connections  131072;
    multi_accept on;
    accept_mutex off;
    use epoll;
}

include /etc/nginx/tunnelconf/*.conf;
" > /etc/nginx/nginx.conf
}

#卸载nginx
uninstall_nginx(){

}
