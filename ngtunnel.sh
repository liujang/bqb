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
echo -e "
 ${GREEN} 1.海外机
 ${GREEN} 2.国内机
 "
read -p "输入选项:" aNum
if [[ $aNum -eq 1 || $aNum -eq 2 ]];then

#检测nginx安装情况
check_install(){
if test -a /usr/sbin/nginx -a /etc/nginx/nginx.conf;then
        echo "--------nginx已安装--------"
	nginx -v
    else
        echo "--------nginx未安装---------"
    fi
} 
#源安装nginx
install_nginx(){
mv /etc/apt/sources.list /etc/apt/sources.list.backup
rm -rf /etc/apt/sources.list
if [ "${aNum}" = "1" ];then
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
elif [ "${aNum}" = "2" ];then
echo "
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${codename} main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${codename}-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ ${codename}-backports main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security ${codename}-security main contrib non-free
" > /etc/apt/sources.list
fi
apt update -y && apt install vim -y
echo deb http://nginx.org/packages/debian/ ${codename} nginx | tee /etc/apt/sources.list.d/nginx.list
apt install gnupg2 -y
wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
apt update -y && apt install nginx -y
rm -rf etc/nginx/nginx.conf
mkdir -p /etc/nginx/tunnelconf
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

stream {
include /etc/nginx/tunnelconf/*.conf;
}
" > /etc/nginx/nginx.conf
clear
systemctl start nginx
ngtunnel_menu
}

#卸载nginx
uninstall_nginx(){
service nginx stop
rm -rf /etc/nginx
apt-get remove nginx -y
apt-get purge nginx -y
apt-get autoremove nginx -y
rm -rf /etc/apt/sources.list
mv /etc/apt/sources.list.backup /etc/apt/sources.list
ngtunnel_menu
}

#生成自签ssl证书
create_ssl(){
mkdir -p /etc/nginx/ssl
cd /etc/nginx/ssl
servername=`curl -s http://ipv4.icanhazip.com`
cat > my-openssl.cnf << EOF
[ ca ]
default_ca = CA_default
[ CA_default ]
x509_extensions = usr_cert
[ req ]
default_bits        = 2048
default_md          = sha256
default_keyfile     = privkey.pem
distinguished_name  = req_distinguished_name
attributes          = req_attributes
x509_extensions     = v3_ca
string_mask         = utf8only
[ req_distinguished_name ]
[ req_attributes ]
[ usr_cert ]
basicConstraints       = CA:FALSE
nsComment              = "OpenSSL Generated Certificate"
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
[ v3_ca ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = CA:true
EOF
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${servername}" -days 5000 -out ca.crt
openssl genrsa -out server.key 2048
openssl req -new -sha256 -key server.key \
    -subj "/C=CN/ST=lj/L=lj/O=ljfxz/CN=${servername}" \
    -reqexts SAN \
    -config <(cat my-openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:${servername},IP:${servername}")) \
    -out server.csr
openssl x509 -req -days 365 -sha256 \
	-in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
	-extfile <(printf "subjectAltName=DNS:${servername},IP:${servername}") \
	-out server.crt
if [ "${aNum}" = "1" ];then
echo "请复制国内机ca证书并粘贴，3秒后进入vim编辑器" && sleep 3 
vim /etc/nginx/ssl/clientca.crt
elif [ "${aNum}" = "2" ];then
clear
echo "国内机ca证书为:"
cat /etc/nginx/ssl/ca.crt
fi
}

#设置nginx规则
set_tunnelconf(){
node="$node"
if [ "${aNum}" = "1" ];then
echo -e "
server {
        listen ${listen_ip}:${listen_port} ssl;
        listen ${listen_ip}:${listen_port} udp;
        ssl_protocols TLSv1.3;
        ssl_certificate /etc/nginx/ssl/server.crt; # 证书地址
        ssl_certificate_key /etc/nginx/ssl/server.key; # 秘钥地址
        ssl_client_certificate /etc/nginx/ssl/clientca.crt;
        ssl_verify_client on;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 2h;
        ssl_session_tickets off;
        tcp_nodelay on;
        proxy_pass \$node;
        resolver 1.1.1.1 8.8.8.8 valid=30s;
        resolver_timeout 3s;
        set \$node \"${remote_ip}:${remote_port}\";
	proxy_protocol off;
        access_log off;
}
" > /etc/nginx/tunnelconf/${listen_port}.conf
elif [ "${aNum}" = "2" ];then
echo -e "
server {
        listen ${listen_ip}:${listen_port};
        listen ${listen_ip}:${listen_port} udp;
        proxy_ssl_certificate /etc/nginx/ssl/server.crt;
        proxy_ssl_certificate_key /etc/nginx/ssl/server.key;
        proxy_ssl on;
        proxy_ssl_protocols TLSv1.3;
        proxy_ssl_server_name on;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 2h;
        ssl_session_tickets off;
        tcp_nodelay on;
        proxy_ssl_name ${remote_ip};
        proxy_pass \$node;
        resolver 223.5.5.5 119.29.29.29 valid=30s;
        resolver_timeout 3s;
        set \$node \"${remote_ip}:${remote_port}\";
	proxy_protocol off;
        access_log off;
}
" > /etc/nginx/tunnelconf/${listen_port}.conf
fi
}

#添加nginx规则
add_tunnelconf(){
read -p "输入监听地址:" listen_ip
read -p "输入监听端口:" listen_port
if test -a /etc/nginx/tunnelconf/${listen_port}.conf;then
echo "已检测到监听端口重复，即将退出" && exit 1
else
read -p "输入转发地址:" remote_ip
read -p "输入转发端口:" remote_port
echo "${listen_ip}   ${listen_port}   ${remote_ip}   ${remote_port}" >> /etc/nginx/tunnelconf/allconf.txt
set_tunnelconf
read -e -p "是否继续 添加端口转发配置？[Y/n]:" addyn
            [[ -z ${addyn} ]] && addyn="y"
            if [[ ${addyn} == [Nn] ]]; then
	        systemctl restart nginx
            else
                echo -e "${Info} 继续 添加端口转发配置..."
		systemctl reload nginx
                add_tunnelconf
            fi
fi
ngtunnel_menu
}

#删除nginx规则
delete_tunnelconf(){
read -p "输入要删除的端口:" delete_port
rm -rf /etc/nginx/tunnelconf/${delete_port}.conf
sed -i -e "/${delete_port}/d" /etc/nginx/tunnelconf/allconf.txt
systemctl reload nginx
ngtunnel_menu
}

#管理nginx
manage_ng(){
echo -e "
 ${GREEN} 1.停止nginx
 ${GREEN} 2.启动nginx
 ${GREEN} 3.重启nginx
 ${GREEN} 4.重载nginx
 ${GREEN} 5.查看nginx状态
"
read -p "请输入选项:" bNum
if [ "$bNum" = "1" ];then
systemctl stop nginx
elif [ "$bNum" = "2" ];then
systemctl start nginx
elif [ "$bNum" = "3" ];then
systemctl restart nginx
elif [ "$bNum" = "4" ];then
systemctl reload nginx
elif [ "$bNum" = "5" ];then
systemctl status nginx
fi
ngtunnel_menu
}

#查看nginx规则
check_tunnelconf(){
echo "监听地址:   监听端口:   转发地址:   转发端口:"
while read rows
do
  echo "$rows"
done < /etc/nginx/tunnelconf/allconf.txt
}

xrayr_ss(){
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
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
    PanelType: "V2board" # Panel type: SSpanel, V2board, PMpanel, , Proxypanel
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
" > /etc/XrayR/config.yml
XrayR restart
}

delete_firewall(){
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
}

#ngtunnel菜单
ngtunnel_menu(){
check_install
echo -e "
 ${GREEN} 1.安装nginx
 ${GREEN} 2.卸载nginx
 ${GREEN} 3.自签ssl
 ${GREEN} 4.添加nginx规则
 ${GREEN} 5.删除nginx规则
 ${GREEN} 6.查看nginx规则
 ${GREEN} 7.管理nginx
 ${GREEN} 8.对接ss
 ${GREEN} 9.删除防火墙
 ${GREEN} 0.退出脚本
 "
read -p " 请输入数字后[0-9] 按回车键:" num
case "$num" in
	1)
	install_nginx
	;;
	2)
	uninstall_nginx
	;;
	3)
	create_ssl
	;;
	4)
	add_tunnelconf
	;;
	5)
	delete_tunnelconf
	;;
	6)
	check_tunnelconf
	;;
	7)
	manage_ng
	;;
	8)
	xrayr_ss
	;;
	9)
	delete_firewall
	;;
	0)
	exit 1
	;;
	*)	
	clear
	echo "请输入正确数字 [0-9] 按回车键"
	sleep 1s
	ngtunnel_menu
	;;
esac
}
ngtunnel_menu
else
echo "输入错误" && exit 1
fi
