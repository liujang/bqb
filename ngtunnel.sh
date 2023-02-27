#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear

RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"

check_nginx(){
if test -a /usr/sbin -a /etc/nginx/nginx.conf;then
        echo -e "--------nginx已安装--------"
    else
        echo -e "--------nginx未安装---------"
    fi
}
