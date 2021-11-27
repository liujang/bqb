#!/usr/bin/env bash
RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"
echo "export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
echo -e "
 ${GREEN} 1.centos禁用selinux
 ${GREEN} 2.对接ssr
 ${GREEN} 3.安装nginx(debian&ubuntu)
 ${GREEN} 4.安装nginx(centos)
 ${GREEN} 5.申请ssl证书
 ${GREEN} 6.udp伪装加速隧道
 ${GREEN} 7.安装内核
 ${GREEN} 8.删除防火墙
 ${GREEN} 9.增加swap
 ${GREEN} 10.安装udp隧道工具
 ${GREEN} 11.tcp隧道(tls)
 "
 read -p "输入选项:" aNum
 if [ "$aNum" = "1" ];then
 sed -i 's\SELINUX=enforcing\SELINUX=disabled\g' /etc/selinux/config
echo "3s后重启系统"
sleep 3
reboot
elif [ "$aNum" = "2" ] ;then
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
    apt-get update -y
    apt-get install vim curl git wget zip unzip python3 python3-pip git -y
    apt install net-tools -y
    apt-get install -y cron
    service cron start
elif [ $PM = 'yum' ]; then 
    yum update -y
    systemctl stop initial-setup-text
    yum install net-tools -y
    yum install vim curl git wget zip unzip python3 python3-pip git -y
    yum install -y vixie-cron
    yum install -y crontabs
    service cron start
    sed -i '1s/python/'python2'/' /bin/yum
    sed -i '1s/python22/'python2'/' /bin/yum
    sed -i '1s/python/'python2'/' /usr/libexec/urlgrabber-ext-down
    sed -i '1s/python22/'python2'/' /usr/libexec/urlgrabber-ext-down
fi
cd
pip3 install --upgrade pip
echo -e
git clone https://github.com/lizhe0608/GOPIP.git
echo -e
cd GOPIP
pip3 install -r requirements.txt
sleep 5
cp apiconfig.py userapiconfig.py && cp config.json user-config.json
echo -e
read -p "请输入后端多少小时测速一次(默认720小时，一个月):" speedtestnum
 [ -z "${speedtestnum}" ] && speedtestnum=720
    echo
    echo "---------------------------"
    echo "speedtestnum = ${speedtestnum}"
    echo "---------------------------"
    sed -i '5s/6/'${speedtestnum}'/' userapiconfig.py
    echo
echo -e "
 ${GREEN} 1.web
 ${GREEN} 2.db
 "
 read -p "输入你要的对接方式:" aNum
if [ "$aNum" = "1" ];then
read -p "请输入网站域名(末尾不要有/,列如www.baidu.com):" webapi1
sleep 1
sed -i '16s/123456/'${webapi1}'/' userapiconfig.py
read -p "请输入网站mukey:" key
 echo "网站mukey为：${key}"
 sleep 1
 sed -i '17s/123/'${key}'/' userapiconfig.py
 read -p "请输入节点序号:" node
 echo "节点序号为：${node}"
 sleep 1
 sed -i '2s/0/'${node}'/' userapiconfig.py
 elif [ "$aNum" = "2" ] ;then
 sed -i '14s/modwebapi/glzjinmod/' userapiconfig.py
 read -p "请输入数据库地址:" ip
 echo "数据库地址为：${ip}"
 sleep 1
 sed -i '23s/127.0.0.1/'${ip}'/' userapiconfig.py
 read -p "请输入数据库用户名:" user
 echo "数据库用户名为：${user}"
 sleep 1
 sed -i '25s/ss/'${user}'/' userapiconfig.py
 read -p "请输入数据库名:" db
 echo "数据库名为：${db}"
 sleep 1
 sed -i '27s/shadowsocks/'${db}'/' userapiconfig.py
 read -p "请输入数据库密码:" passwd
 echo "数据库密码为：${passwd}"
 sleep 1
 sed -i '26s/ss/'${passwd}'/' userapiconfig.py
 read -p "请输入节点序号:" node
 echo "节点序号为：${node}"
 sleep 1
 sed -i '2s/0/'${node}'/' userapiconfig.py
  else
            echo "你他妈是猪吗，就两个数字给你选，你都选错，滚！！！"
            fi
cd
rm -rf /usr/bin/python
ln -s /usr/bin/python3  /usr/bin/python
cd GOPIP && chmod +x run.sh && ./run.sh
echo "已经对接完成！！!。"
sleep 2
cd
elif [ "$aNum" = "3" ] ;then
apt-get update -y && apt install nginx -y
cd
echo "user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
events {
	worker_connections 768;
	# multi_accept on;
}
stream {
}" > /etc/nginx/nginx.conf
cd
elif [ "$aNum" = "4" ] ;then
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
 yum update -y
 yum install -y nginx
 yum install nginx-mod-stream -y
 cd
echo "
load_module /usr/lib64/nginx/modules/ngx_stream_module.so;
user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;
events {
    worker_connections  1024;
}
stream {
}" > /etc/nginx/nginx.conf
cd
elif [ "$aNum" = "5" ] ;then
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
cd
elif [ "$aNum" = "6" ] ;then
cd
echo -e "
 ${GREEN} 1.落地机
 ${GREEN} 2.中转机
 "
read -p "输入选项:" bNum
if [ "$bNum" = "1" ];then
read -p "输入被加速的udp端口1:" udpport1
read -p "输入监听的udp端口2:" udpport2
read -p "输入监听的伪装tcp端口(外网端口):" tcpport1
nohup speederv2_amd64 -s -l127.0.0.1:${udpport2}  -r127.0.0.1:${udpport1} --mode 0 -f2:4 --timeout 1 >> /dev/null 2>&1 &
nohup udp2raw_amd64 -s -l0.0.0.0:${tcpport1} -r127.0.0.1:${udpport2} -k "passwd" --raw-mode faketcp -a >> /dev/null 2>&1 &
echo "
nohup speederv2_amd64 -s -l127.0.0.1:${udpport2}  -r127.0.0.1:${udpport1} --mode 0 -f2:4 --timeout 1 >> /dev/null 2>&1 &
nohup udp2raw_amd64 -s -l0.0.0.0:${tcpport1} -r127.0.0.1:${udpport2} -k "passwd" --raw-mode faketcp -a >> /dev/null 2>&1 &
" >> ./ziqi.sh
echo "落地机udp伪装加速的外网端口为:${tcpport1}"
elif [ "$bNum" = "2" ] ;then
read -p "输入落地机的外网ip:" ip1
read -p "输入落地机udp伪装加速的外网端口:" tcpport2
read -p "输入中转机监听的udp端口3(内外网都行):" udpport3
read -p "输入中转机监听的udp端口4（外网）:" udpport4
nohup udp2raw_amd64  -c -l127.0.0.1:${udpport3} -r${ip1}:${tcpport2} -k "passwd" --raw-mode faketcp>> /dev/null 2>&1 &
nohup speederv2_amd64 -c -l0.0.0.0:${udpport4} -r127.0.0.1:${udpport3} --mode 0 -f2:4 --timeout 1 >> /dev/null 2>&1 &
echo "
nohup udp2raw_amd64  -c -l127.0.0.1:${udpport3} -r${ip1}:${tcpport2} -k "passwd" --raw-mode faketcp>> /dev/null 2>&1 &
nohup speederv2_amd64 -c -l0.0.0.0:${udpport4} -r127.0.0.1:${udpport3} --mode 0 -f2:4 --timeout 1 >> /dev/null 2>&1 &
" >> ./ziqi.sh
echo "最终的外网udp端口为:${udpport4}"
fi
elif [ "$aNum" = "7" ] ;then
wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
elif [ "$aNum" = "8" ] ;then
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
ufw disable
apt-get remove ufw
apt-get purge ufw
  elif [[ $release = "centos" ]]; then
  systemctl stop firewalld.service
  systemctl disable firewalld.service 
  else
    exit 1
  fi
  elif [ "$aNum" = "9" ] ;then
  echo "
       Creat-SWAP by yanglc
       本脚本仅在Debian系系统下进行过测试
       "
get_char()
{
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty $SAVEDSTTY
}
echo "按任意键添加2G大小的SWAP分区："
char=`get_char`
echo "###########开始添加SWAP分区##########"
dd if=/dev/zero of=/mnt/swap bs=1M count=2048
echo -e
echo " ###########设置交换分区文件##########"
mkswap /mnt/swap
echo -e
echo " ###########启动SWAP分区中...#########"
swapon /mnt/swap
echo -e
echo " ###########设置开机自启动############"
echo '/mnt/swap swap swap defaults 0 0' >> /etc/fstab
echo "All done！Thanks for using this shell script"
elif [ "$aNum" = "10" ] ;then
wget -N --no-check-certificate "https://github.91chi.fun//https://raw.githubusercontent.com/liujang/bqb/main/ziqi.sh" && chmod +x ziqi.sh && ./ziqi.sh
mkdir udp && cd udp
wget https://github.91chi.fun//https://github.com/wangyu-/udp2raw/releases/download/20200818.0/udp2raw_binaries.tar.gz
wget https://github.91chi.fun//https://github.com/wangyu-/UDPspeeder/releases/download/20210116.0/speederv2_binaries.tar.gz
tar -xzvf udp2raw_binaries.tar.gz
tar -xzvf speederv2_binaries.tar.gz
mv udp2raw_amd64 /usr/bin/ && chmod +x /usr/bin/udp2raw_amd64
mv speederv2_amd64 /usr/bin/ && chmod +x /usr/bin/speederv2_amd64
export PATH="$PATH:/usr/bin"
cd
crontab -l > conf
echo "@reboot ./ziqi.sh" >> conf
crontab conf
rm -f conf
echo "已设置开机自动运行udp隧道"
elif [ "$aNum" = "11" ] ;then
echo -e "
 ${GREEN} 1.落地机
 ${GREEN} 2.中转机
 "
read -p "输入选项:" cNum
if [ "$cNum" = "1" ] ;then
sed -i '$d' /etc/nginx/nginx.conf
read -p "输入域名:" nodeym1
read -p "输入被转发的端口:" nodeport
read -p "输入监听端口(外网)1:" ngport1
echo "
server {
        listen ${ngport1} ssl;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_certificate /home/ssl/${nodeym1}/1.pem; # 证书地址
	ssl_certificate_key /home/ssl/${nodeym1}/1.key; # 秘钥地址
        ssl_session_cache off;  # 可选，我把TLS会话缓存关闭了。
        proxy_pass 127.0.0.1:${nodeport};
    }
    } " >> /etc/nginx/nginx.conf
    ehco "落地nginx tcp端口为:${ngport1}"
    elif [ "$aNum" = "2" ] ;then
    sed -i '$d' /etc/nginx/nginx.conf
    read -p "输入落地nginx ip:" ngip1
    read -p "输入落地nginx 域名:" nodeym2
    read -p "输入落地nginx tcp端口2:" ngport2
    read -p "输入中转监听 tcp端口:" zzport
    echo "
    server {
        listen ${zzport};
        proxy_ssl on;
        proxy_ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        proxy_ssl_server_name on;
        proxy_ssl_name ${nodeym2};
        proxy_pass ${ngip1}:${ngport2};
    }
    } " >> /etc/nginx/nginx.conf
    ehco "中转监听的tcp端口为:${zzport}"
fi
