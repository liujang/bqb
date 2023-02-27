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

stream {
include /etc/nginx/tunnelconf/*.conf;
}
" > /etc/nginx/nginx.conf
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
}

set_tunnelconf(){
read -p "输入监听地址:" listen_ip
read -p "输入监听端口:" listen_port
read -p "输入转发地址:" remote_ip
read -p "输入转发端口:" remote_port
if [ "${aNum}" = "1" ];then
echo "
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
        proxy_pass $node;
        resolver 1.1.1.1 8.8.8.8 valid=30s;
        resolver_timeout 3s;
        set $node "${remote_ip}:${remote_port}";
	proxy_protocol off;
        access_log off;
}
" > /etc/nginx/tunnelconf/${listen_port}.conf
elif [ "${aNum}" = "2" ];then
echo "
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
        proxy_pass $node;
        resolver 223.5.5.5 119.29.29.29 valid=30s;
        resolver_timeout 3s;
        set $node "${remote_ip}:${remote_port}";
	proxy_protocol off;
        access_log off;
}
" > /etc/nginx/tunnelconf/${listen_port}.conf
fi
}
