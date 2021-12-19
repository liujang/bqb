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
 ${GREEN} 1.centos禁用selinux
 ${GREEN} 2.对接ss
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
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
cd
rm -rf /etc/XrayR/config.yml
read -p "输入对接域名(例如www.baidu.com):" ym
read -p "输入节点id:" nodeid
read -p "输入mukey:" mukey
echo "
Log:
  Level: none # Log level: none, error, warning, info, debug 
  AccessPath: # /etc/XrayR/access.Log
  ErrorPath: # /etc/XrayR/error.log
DnsConfigPath: # /etc/XrayR/dns.json # Path to dns config, check https://xtls.github.io/config/base/dns/ for help
RouteConfigPath: # /etc/XrayR/route.json # Path to route config, check https://xtls.github.io/config/base/route/ for help
OutboundConfigPath: # /etc/XrayR/custom_outbound.json # Path to custom outbound config, check https://xtls.github.io/config/base/outbound/ for help
ConnetionConfig:
  Handshake: 4 # Handshake time limit, Second
  ConnIdle: 30 # Connection idle time limit, Second
  UplinkOnly: 2 # Time limit when the connection downstream is closed, Second
  DownlinkOnly: 4 # Time limit when the connection is closed after the uplink is closed, Second
  BufferSize: 64 # The internal cache size of each connection, kB 
Nodes:
  -
    PanelType: "SSpanel" # Panel type: SSpanel, V2board, PMpanel, , Proxypanel
    ApiConfig:
      ApiHost: "https://${ym}"
      ApiKey: "${mukey}"
      NodeID: ${nodeid}
      NodeType: Shadowsocks # Node type: V2ray, Shadowsocks, Trojan, Shadowsocks-Plugin
      Timeout: 30 # Timeout for the api request
      EnableVless: false # Enable Vless for V2ray Type
      EnableXTLS: false # Enable XTLS for V2ray and Trojan
      SpeedLimit: 0 # Mbps, Local settings will replace remote settings, 0 means disable
      DeviceLimit: 0 # Local settings will replace remote settings, 0 means disable
      RuleListPath: # ./rulelist Path to local rulelist file
    ControllerConfig:
      ListenIP: 0.0.0.0 # IP address you want to listen
      SendIP: 0.0.0.0 # IP address you want to send pacakage
      UpdatePeriodic: 60 # Time to update the nodeinfo, how many sec.
      EnableDNS: false # Use custom DNS config, Please ensure that you set the dns.json well
      DNSType: AsIs # AsIs, UseIP, UseIPv4, UseIPv6, DNS strategy
      EnableProxyProtocol: false # Only works for WebSocket and TCP
      EnableFallback: false # Only support for Trojan and Vless
      FallBackConfigs:  # Support multiple fallbacks
        -
          SNI: # TLS SNI(Server Name Indication), Empty for any
          Path: # HTTP PATH, Empty for any
          Dest: 80 # Required, Destination of fallback, check https://xtls.github.io/config/fallback/ for details.
          ProxyProtocolVer: 0 # Send PROXY protocol version, 0 for dsable
      CertConfig:
        CertMode: none # Option about how to get certificate: none, file, http, dns. Choose "none" will forcedly disable the tls config.
        CertDomain: "node1.test.com" # Domain to cert
        CertFile: ./cert/node1.test.com.cert # Provided if the CertMode is file
        KeyFile: ./cert/node1.test.com.key
        Provider: alidns # DNS cert provider, Get the full support list here: https://go-acme.github.io/lego/dns/
        Email: test@me.com
        DNSEnv: # DNS ENV option used by DNS provider
          ALICLOUD_ACCESS_KEY: aaa
          ALICLOUD_SECRET_KEY: bbb
  # -
  #   PanelType: "V2board" # Panel type: SSpanel, V2board
  #   ApiConfig:
  #     ApiHost: "http://127.0.0.1:668"
  #     ApiKey: "123"
  #     NodeID: 4
  #     NodeType: Shadowsocks # Node type: V2ray, Shadowsocks, Trojan
  #     Timeout: 30 # Timeout for the api request
  #     EnableVless: false # Enable Vless for V2ray Type
  #     EnableXTLS: false # Enable XTLS for V2ray and Trojan
  #     SpeedLimit: 0 # Mbps, Local settings will replace remote settings
  #     DeviceLimit: 0 # Local settings will replace remote settings
  #   ControllerConfig:
  #     ListenIP: 0.0.0.0 # IP address you want to listen
  #     UpdatePeriodic: 10 # Time to update the nodeinfo, how many sec.
  #     EnableDNS: false # Use custom DNS config, Please ensure that you set the dns.json well
  #     CertConfig:
  #       CertMode: dns # Option about how to get certificate: none, file, http, dns
  #       CertDomain: "node1.test.com" # Domain to cert
  #       CertFile: ./cert/node1.test.com.cert # Provided if the CertMode is file
  #       KeyFile: ./cert/node1.test.com.pem
  #       Provider: alidns # DNS cert provider, Get the full support list here: https://go-acme.github.io/lego/dns/
  #       Email: test@me.com
  #       DNSEnv: # DNS ENV option used by DNS provider
  #         ALICLOUD_ACCESS_KEY: aaa
  #         ALICLOUD_SECRET_KEY: bbb
" > /etc/XrayR/config.yml
cd
XrayR restart
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
bash <(curl -s -L git.io/dmSSL)
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
read -p "输入域名:" nodeym1
read -p "输入被转发的端口:" nodeport
read -p "输入监听端口(外网)1:" ngport1
sed -i '$d' /etc/nginx/nginx.conf
echo "
server {
        listen ${ngport1} ssl;
        ssl_protocols TLSv1.3;
        ssl_certificate /home/ssl/${nodeym1}/1.pem; # 证书地址
	ssl_certificate_key /home/ssl/${nodeym1}/1.key; # 秘钥地址
        ssl_session_tickets off;
        ssl_prefer_server_ciphers on;  # prefer a list of ciphers to prevent old and slow ciphers
        ssl_ciphers 'NULL';
        proxy_pass 127.0.0.1:${nodeport};
    }
    } " >> /etc/nginx/nginx.conf
    echo "落地nginx tcp端口为:${ngport1}"
    elif [ "$cNum" = "2" ] ;then
    read -p "输入落地nginx ip:" ngip1
    read -p "输入落地nginx 域名:" nodeym2
    read -p "输入落地nginx tcp端口2:" ngport2
    read -p "输入中转监听 tcp端口:" zzport
    sed -i '$d' /etc/nginx/nginx.conf
    echo "
    server {
        listen ${zzport};
        proxy_ssl on;
        proxy_ssl_protocols TLSv1.3;
        proxy_ssl_server_name on;
        proxy_ssl_name ${nodeym2};
	ssl_session_tickets off;
        ssl_prefer_server_ciphers on;  # prefer a list of ciphers to prevent old and slow ciphers
        ssl_ciphers 'NULL';
        proxy_pass ${ngip1}:${ngport2};
    }
    } " >> /etc/nginx/nginx.conf
    echo "中转监听的tcp端口为:${zzport}"
fi
sleep 1
systemctl restart nginx
cd
fi
