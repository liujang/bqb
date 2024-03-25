#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "------------------tg:@ljfxz------------------"

gre_open(){
modprobe ip_gre
}

iptablse_install(){
if [[ ${iptables_exist} != "" ]]; then
echo -e "已经安装iptables"
else
apt-get update && apt-get install -y iptables
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore < /etc/iptables.up.rules
}

gre_over_ipsec_set1(){
read -p "输入本机ip:" LOCAL_IP
read -p "输入对端ip:" REMOTE_IP
read -p "自定义本机虚拟ip:" LOCAL_VIRTUAL_IP
read -p "自定义对端虚拟ip:" REMOTE_VIRTUAL_IP
ip tunnel add gre1 mode gre local ${LOCAL_IP} remote ${REMOTE_IP} ttl 255
ip addr add ${LOCAL_VIRTUAL_IP} dev gre1 peer ${REMOTE_VIRTUAL_IP}
ip link set gre1 up
ip xfrm state add src ${LOCAL_IP} dst ${REMOTE_IP} proto esp spi 0x28f39549 reqid 0x28f39549 mode transport aead 'rfc4106(gcm(aes))' 0x492e8ffe718a95a00c1893ea61afc64997f4732848ccfe6ea07db483175cb18de9ae411a 128 offload dev gre1 dir out sel src ${LOCAL_IP} dst ${REMOTE_IP}
ip xfrm state add src ${REMOTE_IP} dst ${LOCAL_IP} proto esp spi 0x622a73b4 reqid 0x622a73b4 mode transport aead 'rfc4106(gcm(aes))' 0x093bfee2212802d626716815f862da31bcc7d9c44cfe3ab8049e7604b2feb1254869d25b 128 offload dev gre1 dir in sel src ${REMOTE_IP} dst ${LOCAL_IP}
ip xfrm policy add src ${LOCAL_IP} dst ${REMOTE_IP} dir out tmpl src ${LOCAL_IP} dst ${REMOTE_IP} proto esp reqid 0x28f39549 mode transport
ip xfrm policy add src ${REMOTE_IP} dst ${LOCAL_IP} dir in tmpl src ${REMOTE_IP} dst ${LOCAL_IP} proto esp reqid 0x622a73b4 mode transport
ip xfrm policy add src ${REMOTE_IP} dst ${LOCAL_IP} dir fwd tmpl src ${REMOTE_IP} dst ${LOCAL_IP} proto esp reqid 0x622a73b4 mode transport
}

gre_over_ipsec_set2(){
read -p "输入本机ip:" LOCAL_IP
read -p "输入对端ip:" REMOTE_IP
read -p "自定义本机虚拟ip:" LOCAL_VIRTUAL_IP
read -p "自定义对端虚拟ip:" REMOTE_VIRTUAL_IP
ip tunnel add gre1 mode gre local ${LOCAL_IP} remote ${REMOTE_IP} ttl 255
ip addr add ${LOCAL_VIRTUAL_IP} dev gre1 peer ${REMOTE_VIRTUAL_IP}
ip link set gre1 up
ip xfrm state add src ${REMOTE_IP} dst ${LOCAL_IP} proto esp spi 0x28f39549 reqid 0x28f39549 mode transport aead 'rfc4106(gcm(aes))' 0x492e8ffe718a95a00c1893ea61afc64997f4732848ccfe6ea07db483175cb18de9ae411a 128 offload dev gre1 dir in sel src ${REMOTE_IP} dst ${LOCAL_IP}
ip xfrm state add src ${LOCAL_IP} dst ${REMOTE_IP} proto esp spi 0x622a73b4 reqid 0x622a73b4 mode transport aead 'rfc4106(gcm(aes))' 0x093bfee2212802d626716815f862da31bcc7d9c44cfe3ab8049e7604b2feb1254869d25b 128 offload dev gre1 dir out sel src ${LOCAL_IP} dst ${REMOTE_IP}
ip xfrm policy add src ${LOCAL_IP} dst ${REMOTE_IP} dir out tmpl src ${LOCAL_IP} dst ${REMOTE_IP} proto esp reqid 0x622a73b4 mode transport 
ip xfrm policy add src ${REMOTE_IP} dst ${LOCAL_IP} dir in tmpl src ${REMOTE_IP} dst ${LOCAL_IP} proto esp reqid 0x28f39549 mode transport 
ip xfrm policy add src ${REMOTE_IP} dst ${LOCAL_IP} dir fwd tmpl src ${REMOTE_IP} dst ${LOCAL_IP} proto esp reqid 0x28f39549 mode transport 
}
