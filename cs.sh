#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear

haproxy_conf(){
haproxy_rows=`wc -l 1.txt | awk '{print $1}'`
for((i=1;i<=$haproxy_rows;i++));  
do
listen_ip=`sed -n "$i, 1p" 1.txt | awk '{print $1}'`
listen_port=`sed -n "$i, 1p" 1.txt | awk '{print $2}'`
remote_ip=`sed -n "$i, 1p" 1.txt | awk '{print $3}'`
remote_port=`sed -n "$i, 1p" 1.txt | awk '{print $4}'`
echo -e "listen $listen_port
   bind $listen_ip:$listen_port ssl crt /etc/nginx/ssl/server.pem verify required ca-file /etc/nginx/ssl/ca1.crt alpn h2
   server s$listen_port $remote_ip:$remote_port
" >> /usr/local/haproxy/haproxy.cfg
done  
}

haproxy_conf
