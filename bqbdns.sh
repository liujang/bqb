#!/usr/bin/env bash
RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"
echo "export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
if [[ "$EUID" -ne 0 ]]; then
    echo "false"
  else
    echo "true"
  fi
if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
    
     if [[ $release = "ubuntu" || $release = "debian" ]]; then
    PM='apt'
  elif [[ $release = "centos" ]]; then
    PM='yum'
  else
    exit 1
  fi
  # PM='apt'
  if [ $PM = 'apt' ] ; then
    apt-get install -y cron
    service cron start
elif [ $PM = 'yum' ]; then 
    yum install -y vixie-cron
    yum install -y crontabs
    service cron start
fi
if [ $1 != 'restore' ];then
    DNS1=$1
    DNS2=$2
fi

function Get_OSName(){
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
    else
        DISTRO='unknow'
    fi
    if [ $DISTRO != 'unknow' ]; then
        echo -e '检测到您的系统为: '$DISTRO''
    else
        echo -e '不支持的操作系统，请更换为 CentOS / Debian / Ubuntu 后重试。'
        exit 1;
    fi
}
function get_char(){
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty $SAVEDSTTY
}
function Welcome(){
    echo -e '正在检测您的操作系统...'
    Get_OSName
    echo -e '您确定要使用下面的DNS地址吗？'
    echo -e '主DNS: '$DNS1''
    if [ "$DNS2" != '' ]; then
        echo -e '备DNS: '$DNS2''
    fi
    echo
    echo -e '请按任意键继续，如有配置错误请使用 Ctrl+C 退出。'
    char=`get_char`
}
function ChangeDNS(){
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        echo
        echo -e '正在备份当前DNS配置文件...'
        cp /etc/resolv.conf /etc/resolv.conf.backup
        echo
        echo -e '备份完成，正在修改DNS配置文件...'
        if [ `cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'` == 7 ]; then
            sed -i '/\[main\]/a dns=none' /etc/NetworkManager/NetworkManager.conf
            systemctl restart NetworkManager.service
        fi
        echo -e 'nameserver '$DNS1'' > /etc/resolv.conf
        if [ "$DNS2" != '' ]; then
            echo -e 'nameserver '$DNS2'' >> /etc/resolv.conf
        fi
        echo
        echo -e 'DNS配置文件修改完成。'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        echo
        echo -e '正在备份当前DNS配置文件...'
        cp /etc/resolv.conf /etc/resolv.conf.backup
        echo
        echo -e '备份完成，正在修改DNS配置文件...'
        echo -e 'nameserver '$DNS1'' > /etc/resolv.conf
        if [ "$DNS2" != '' ]; then
            echo -e 'nameserver '$DNS2'' >> /etc/resolv.conf
        fi
        echo
        echo -e 'DNS配置文件修改完成。'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        echo
        echo -e '正在修改DNS配置文件...'
        if [ `cat /etc/issue|awk '{print $2}'|awk -F'.' '{print $1}'` -le 17 ]; then
            echo -e 'nameserver '$DNS1'' > /etc/resolvconf/resolv.conf.d/base
            if [ "$DNS2" != '' ]; then
                echo -e 'nameserver '$DNS2'' >> /etc/resolvconf/resolv.conf.d/base
            fi
            resolvconf -u
        else
            echo -e 'nameserver '$DNS1'' >> /etc/systemd/resolved.conf
            if [ "$DNS2" != '' ]; then
                echo -e 'nameserver '$DNS2'' >> /etc/systemd/resolved.conf
            fi
            systemctl restart systemd-resolved.service
        fi
        echo
        echo -e 'DNS配置文件修改完成。'
    fi
    echo
    echo -e '感谢您的使用, 如果您想恢复备份，请在执行脚本文件时使用参数 restore 。'
}
function RestoreDNS(){
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        echo -e '正在恢复默认DNS配置文件...'
        rm -rf /etc/resolv.conf
        mv /etc/resolv.conf.backup /etc/resolv.conf
        if [ `cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'` == 7 ]; then
            sed -i 's/dns=none//g' /etc/NetworkManager/NetworkManager.conf
            systemctl restart NetworkManager.service
        fi
        echo
        echo -e 'DNS配置文件恢复完成。'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        echo -e '正在恢复默认DNS配置文件...'
        rm -rf /etc/resolv.conf
        mv /etc/resolv.conf.backup /etc/resolv.conf
        echo
        echo -e 'DNS配置文件恢复完成。'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        echo -e '正在恢复默认DNS配置文件...'
        if [ `cat /etc/issue|awk '{print $2}'|awk -F'.' '{print $1}'` -le 17 ]; then
            echo -e '' > /etc/resolvconf/resolv.conf.d/base
            resolvconf -u
        else
            sed -i '/nameserver/d' /etc/systemd/resolved.conf
            systemctl restart systemd-resolved.service
        fi
        echo
        echo -e 'DNS配置文件恢复完成。'
    fi
}
function addDNS(){
    Welcome
    ChangeDNS
}
if [ $1 != 'restore' ];then
    addDNS
elif [ $1 == 'restore' ];then
    RestoreDNS
else
    echo '用法错误！'
fi
echo -e "
 ${GREEN} hk
 ${GREEN} jp
 ${GREEN} sgp
 ${GREEN} us
 "
  read -p "输入地区代号(例如hk):" area
num=`curl -I -m 10 -o /dev/null -s -w %{http_code} h5ai.ljfxz.net`
if [ $num -eq 200 ]
then 
echo "网站访问状态为${num},可以执行脚本"
cd /root/ && wget -N --no-check-certificate "https://raw.githubusercontent.com/liujang/bqb/main/changedns.sh" && chmod +x changedns.sh
sed -i '9s/area/'${area}'/' /root/changedns.sh
 cp /etc/resolv.conf /etc/resolv.conf.backup
 ./changedns.sh
 echo "已更换dns"
read -p "多少小时重新获取dns:" dnstime
crontab -l > conf
echo "0 */${dnstime} * * * /root/changedns.sh" >> conf
crontab conf
rm -f conf
echo "已设置每${dnstime}小时重新获取dns"
else
echo "网站访问状态为${num},不可以执行脚本，已自动退出"
exit 1
fi
