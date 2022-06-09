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
