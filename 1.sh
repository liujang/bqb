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
#编译安装nginx
install_nginx(){
apt update -y && apt install vim curl lsof wget -y
apt install build-essential libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev -y
wget http://nginx.org/download/nginx-1.23.3.tar.gz && tar -xvzf nginx-1.23.3.tar.gz
cd nginx-1.23.3
./configure \
--prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--with-file-aio \
--with-threads \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_random_index_module \
--with-http_realip_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_v2_module \
--with-mail \
--with-mail_ssl_module \
--with-stream \
--with-stream_realip_module \
--with-stream_ssl_module \
--with-stream_ssl_preread_module
make && make install 
echo '
[Unit]
Description=nginx - high performance web server
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/sh -c "/bin/kill -s HUP $(/bin/cat /var/run/nginx.pid)"
ExecStop=/bin/sh -c "/bin/kill -s TERM $(/bin/cat /var/run/nginx.pid)"

[Install]
WantedBy=multi-user.target ' > /usr/lib/systemd/system/nginx.service
systemctl enable nginx --now
systemctl daemon-reload
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
apt-get install iptables-persistent -y
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
netfilter-persistent save
netfilter-persistent reload
ngtunnel_menu
}

#卸载nginx
uninstall_nginx(){
service nginx stop
rm -rf /etc/nginx
rm -rf /usr/sbin/nginx
rm -rf /usr/lib/systemd/system/nginx.service
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
 ${GREEN} 8.删除防火墙
 ${GREEN} 0.退出脚本
 "
read -p " 请输入数字后[0-8] 按回车键:" num
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
	delete_firewall
	;;
	0)
	exit 1
	;;
	*)	
	clear
	echo "请输入正确数字 [0-8] 按回车键"
	sleep 1s
	ngtunnel_menu
	;;
esac
}
ngtunnel_menu
else
echo "输入错误" && exit 1
fi
