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
wget http://www.lua.org/ftp/${lua_v}.tar.gz
wget https://github.com/haproxy/haproxy/archive/refs/tags/v${haproxy_v}.tar.gz
tar -xvzf ${lua_v}.tar.gz && tar -xvzf v${haproxy_v}.tar.gz
cd /root/${lua_v}
make linux
make install INSTALL_TOP=/usr/local/lua
cd /root/haproxy-${haproxy_v}
make TARGET=linux-glibc USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_SYSTEMD=1 USE_CPU_AFFINITY=1 USE_LUA=1 LUA_INC=/usr/local/lua/include LUA_LIB=/usr/local/lua/lib
make install PREFIX=/usr/local/haproxy
cp /usr/local/haproxy/sbin/haproxy /usr/local/sbin/haproxy
wget -N --no-check-certificate -P /usr/lib/systemd/system/ "https://raw.githubusercontent.com/liujang/bqb/main/haproxy.service"
systemctl enable haproxy --now
systemctl daemon-reload
cd /root/ && rm -rf ${lua_v}.tar.gz v${haproxy_v}.tar.gz ${lua_v} haproxy-${haproxy_v}
}

install_haproxy
