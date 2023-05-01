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
wget -N --no-check-certificate -P /usr/lib/systemd/system/ "https://raw.githubusercontent.com/liujang/bqb/main/haproxy.service"
systemctl enable haproxy --now
systemctl daemon-reload
cd /root/ && rm -rf ${lua_v}.tar.gz v${haproxy_v}.tar.gz ${lua_v} haproxy-${haproxy_v}
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
haproxy_rows=`wc -l /usr/local/haproxy/haproxy.txt | awk '{print $1}'`
for((i=1;i<=$haproxy_rows;i++));  
do
listen_ip=`sed -n "$i, 1p" /usr/local/haproxy/haproxy.txt | awk '{print $1}'`
listen_port=`sed -n "$i, 1p" /usr/local/haproxy/haproxy.txt | awk '{print $2}'`
remote_ip=`sed -n "$i, 1p" /usr/local/haproxy/haproxy.txt | awk '{print $3}'`
remote_port=`sed -n "$i, 1p" /usr/local/haproxy/haproxy.txt | awk '{print $4}'`
echo -e "listen $listen_port
   bind $listen_ip:$listen_port ssl crt /etc/nginx/ssl/server.pem verify required ca-file /etc/nginx/ssl/ca1.crt alpn h2
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
   server s$listen_port $remote_ip:$remote_port ssl verify required ca-file /etc/nginx/ssl/ca1.crt crt /etc/nginx/ssl/server.pem alpn h2
" >> /usr/local/haproxy/haproxy.cfg
done
systemctl restart haproxy
fi
}
