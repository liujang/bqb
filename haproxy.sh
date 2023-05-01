#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear

RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"

lua_v=lua-5.4.5
haproxy_v=2.8-dev9

install_haproxy(){
apt update -y && apt install vim curl lsof wget -y
apt install build-essential libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev libsystemd-dev -y
wget https://h5ai.xinhuanying66.xyz/hympls/hympls/${lua_v}.tar.gz
wget https://h5ai.xinhuanying66.xyz/hympls/hympls/v${haproxy_v}.tar.gz
tar -xvzf ${lua_v}.tar.gz && tar -xvzf v${haproxy_v}.tar.gz
cd /root/${lua_v}
make linux
make install INSTALL_TOP=/usr/local/lua
cd /root/haproxy-${haproxy_v}
make TARGET=linux-glibc \
USE_OPENSSL=1 \
USE_ZLIB=1 \
USE_SYSTEMD=1 \
USE_CPU_AFFINITY=1 \
USE_PCRE=1 \
USE_THREAD=1 \
USE_GETADDRINFO=1 \
USE_LUA=1 \
LUA_LIB=/usr/local/lua/lib \
LUA_INC=/usr/local/lua/include
make install PREFIX=/usr/local/haproxy
cp /usr/local/haproxy/sbin/haproxy /usr/local/sbin/haproxy
wget -N --no-check-certificate -P /usr/local/haproxy/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/haproxy.cfg"
wget -N --no-check-certificate -P /usr/lib/systemd/system/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/haproxy.service"
systemctl enable haproxy --now
systemctl daemon-reload
cd /root/ && rm -rf ${lua_v}.tar.gz v${haproxy_v}.tar.gz ${lua_v} haproxy-${haproxy_v}
install_realm
install_wireguard
hy_menu
}

install_realm(){
mkdir -p /usr/local/realm
wget -N --no-check-certificate -P /usr/local/sbin/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/realm"
chmod +x /usr/local/sbin/realm
wget -N --no-check-certificate -P /usr/local/realm/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/config.toml"
wget -N --no-check-certificate -P /usr/lib/systemd/system/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/realm.service"
systemctl enable realm --now
systemctl daemon-reload
}

install_wireguard(){
apt install linux-image-amd64 -y && apt install wireguard -y
systemctl enable wg-quick@wg0
}

haproxy_conf(){
echo -e "
 ${GREEN} 1.跳板机
 ${GREEN} 2.中转机
 "
read -p "输入选项:" aNum
echo -e "
 ${GREEN} 1.广港1(gzhkMPLS1)
 ${GREEN} 2.湘日1(hnjpMPLS1)
 ${GREEN} 3.苏德1(zjdeMPLS1)
 "
read -p "请输入括号里的代号:" mplsdh
if [ "$aNum" = "1" ];then
wget -N --no-check-certificate -P /usr/local/haproxy/ "h5ai.xinhuanying66.xyz/hympls/$mplsdh/luodi/haproxy.txt"
rm -rf /usr/local/haproxy/haproxy.cfg
haproxy_rows=`wc -l /usr/local/haproxy/haproxy.txt | awk '{print $1}'`
for((i=1;i<=$haproxy_rows;i++));  
do
listen_ip=`sed -n "$i, 1p" /usr/local/haproxy/haproxy.txt | awk '{print $1}'`
listen_port=`sed -n "$i, 1p" /usr/local/haproxy/haproxy.txt | awk '{print $2}'`
remote_ip=`sed -n "$i, 1p" /usr/local/haproxy/haproxy.txt | awk '{print $3}'`
remote_port=`sed -n "$i, 1p" /usr/local/haproxy/haproxy.txt | awk '{print $4}'`
echo -e "listen $listen_port
   bind $listen_ip:$listen_port ssl crt /usr/local/haproxy/ssl/server.pem verify required ca-file /usr/local/haproxy/ssl/ca1.crt alpn h2
   server s$listen_port $remote_ip:$remote_port
" >> /usr/local/haproxy/haproxy.cfg
done
elif [ "$aNum" = "2" ];then
wget -N --no-check-certificate -P /usr/local/haproxy/ "h5ai.xinhuanying66.xyz/hympls/$mplsdh/zhongzhuan/haproxy.txt"
haproxy_rows=`wc -l /usr/local/haproxy/haproxy.txt | awk '{print $1}'`
for((i=1;i<=$haproxy_rows;i++));  
do
listen_ip=`sed -n "$i, 1p" /usr/local/haproxy/haproxy.txt | awk '{print $1}'`
listen_port=`sed -n "$i, 1p" /usr/local/haproxy/haproxy.txt | awk '{print $2}'`
remote_ip=`sed -n "$i, 1p" /usr/local/haproxy/haproxy.txt | awk '{print $3}'`
remote_port=`sed -n "$i, 1p" /usr/local/haproxy/haproxy.txt | awk '{print $4}'`
echo -e "listen $listen_port
   bind $listen_ip:$listen_port
   server s$listen_port $remote_ip:$remote_port ssl verify required ca-file /usr/local/haproxy/ssl/ca1.crt crt /usr/local/haproxy/ssl/server.pem alpn h2
" >> /usr/local/haproxy/haproxy.cfg
done
fi
systemctl restart haproxy
wireguard_conf
realm_conf
hy_menu
}

wireguard_conf(){
if [ "$aNum" = "1" ];then
wget -N --no-check-certificate -P /etc/wireguard "https://h5ai.xinhuanying66.xyz/hympls/${mplsdh}/luodi/wg0.conf"
elif [ "$aNum" = "2" ];then
wget -N --no-check-certificate -P /etc/wireguard "https://h5ai.xinhuanying66.xyz/hympls/${mplsdh}/zhongzhuan/wg0.conf"
fi
wg-quick down wg0
wg-quick up wg0
}

realm_conf(){
if [ "$aNum" = "1" ];then
wget -N --no-check-certificate -P /usr/local/realm/ "h5ai.xinhuanying66.xyz/hympls/$mplsdh/luodi/config.txt"
rm -rf /usr/local/realm/config.toml
realm_rows=`wc -l /usr/local/realm/config.txt | awk '{print $1}'`
for((i=1;i<=$realm_rows;i++));  
do
listen_ip=`sed -n "$i, 1p" /usr/local/realm/config.txt | awk '{print $1}'`
listen_port=`sed -n "$i, 1p" /usr/local/realm/config.txt | awk '{print $2}'`
remote_ip=`sed -n "$i, 1p" /usr/local/realm/config.txt | awk '{print $3}'`
remote_port=`sed -n "$i, 1p" /usr/local/realm/config.txt | awk '{print $4}'`
echo -e "
[[endpoints]]
listen = "$listen_ip:$listen_port"
remote = "$remote_ip:$remote_port"" >> /usr/local/realm/config.toml
done
elif [ "$aNum" = "2" ];then
wget -N --no-check-certificate -P /usr/local/realm/ "h5ai.xinhuanying66.xyz/hympls/$mplsdh/zhongzhuan/config.txt"
rm -rf /usr/local/realm/config.toml
realm_rows=`wc -l /usr/local/realm/config.txt | awk '{print $1}'`
for((i=1;i<=$realm_rows;i++));  
do
listen_ip=`sed -n "$i, 1p" /usr/local/realm/config.txt | awk '{print $1}'`
listen_port=`sed -n "$i, 1p" /usr/local/realm/config.txt | awk '{print $2}'`
remote_ip=`sed -n "$i, 1p" /usr/local/realm/config.txt | awk '{print $3}'`
remote_port=`sed -n "$i, 1p" /usr/local/realm/config.txt | awk '{print $4}'`
echo -e "
[[endpoints]]
listen = "$listen_ip:$listen_port"
remote = "$remote_ip:$remote_port"" >> /usr/local/realm/config.toml
done
fi
systemctl restart realm
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
  hy_menu
}

create_ssl(){
mkdir -p /usr/local/haproxy/ssl
cd /usr/local/haproxy/ssl
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
cat server.crt server.key | tee server.pem
hy_menu
}

install_kernel(){
wget -N --no-check-certificate "https://h5ai.xinhuanying66.xyz/hympls/hympls/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
}

install_ss(){
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
rm -rf /etc/soga/soga.conf
read -p "输入对接域名(例如www.baidu.com):" ym
read -p "输入节点id:" nodeid
read -p "输入mukey:" mukey
read -p "输入soga授权码:" sogakey
echo "
# 基础配置
type=sspanel-uim
server_type=ss
node_id=${nodeid}
soga_key=${sogakey}

# webapi 或 db 对接任选一个
api=webapi

# webapi 对接信息
webapi_url=https://${ym}
webapi_key=${mukey}

# db 对接信息
db_host=
db_port=
db_name=
db_user=
db_password=

# 手动证书配置
cert_file=
key_file=

# 自动证书配置
cert_mode=
cert_domain=
cert_key_length=ec-256
dns_provider=

# dns 配置
default_dns=
dns_cache_time=10
dns_strategy=ipv4_first

# v2ray 特殊配置
v2ray_reduce_memory=false
vless=false
vless_flow=

# proxy protocol 中转配置
proxy_protocol=false

# 全局限制用户 IP 数配置
redis_enable=false
redis_addr=
redis_password=
redis_db=0
conn_limit_expiry=60

# 其它杂项
user_conn_limit=0
user_speed_limit=0
node_speed_limit=0
check_interval=60
force_close_ssl=false
forbidden_bit_torrent=true
log_level=info

# 更多配置项如有需要自行添加
" > /etc/soga/soga.conf
soga restart
}

manage_haproxy(){
echo -e "
 ${GREEN} 1.停止隧道
 ${GREEN} 2.启动隧道
 ${GREEN} 3.重启隧道
"
read -p "请输入选项:" bNum
if [ "$bNum" = "1" ];then
systemctl stop haproxy
wg-quick down wg0
systemctl stop realm
elif [ "$bNum" = "2" ];then
systemctl start haproxy
wg-quick up wg0
systemctl start realm
elif [ "$bNum" = "3" ];then
systemctl restart haproxy
wg-quick down wg0
wg-quick up wg0
systemctl restart realm
fi
hy_menu
}

hy_menu(){
clear
echo -e " 
 ${GREEN} 1.安装隧道工具
 ${GREEN} 2.获取隧道配置
 ${GREEN} 3.对接ss
 ${GREEN} 4.删除防火墙
 ${GREEN} 5.管理隧道
 ${GREEN} 6.自签ssl
 ${GREEN} 7.安装内核
 ${GREEN} 0.退出脚本"
read -p " 请输入数字后[0-7] 按回车键:" num
case "$num" in
	1)
	install_haproxy
	;;
	2)
	haproxy_conf
	;;
	3)
	install_ss
	;;
	4)
	delete_firewall
	;;
	5)
	manage_haproxy
	;;
	6)
	create_ssl
	;;
	7)
	install_kernel
	;;
	0)
	exit 1
	;;
	*)	
	clear
	echo "请输入正确数字 [0-7] 按回车键"
	sleep 1s
	hy_menu
	;;
esac
}
hy_menu
