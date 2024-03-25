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
ip tunnel add gre1 mode gre local 120.241.46.59 remote 156.251.248.196 ttl 255
ip addr add 10.10.10.1 dev gre1 peer 10.10.10.2
ip link set gre1 up
ip xfrm state add src 120.241.46.59 dst 156.251.248.196 proto esp spi 0x28f39549 reqid 0x28f39549 mode transport aead 'rfc4106(gcm(aes))' 0x492e8ffe718a95a00c1893ea61afc64997f4732848ccfe6ea07db483175cb18de9ae411a 128 offload dev gre1 dir out sel src 120.241.46.59 dst 156.251.248.196
ip xfrm state add src 156.251.248.196 dst 120.241.46.59 proto esp spi 0x622a73b4 reqid 0x622a73b4 mode transport aead 'rfc4106(gcm(aes))' 0x093bfee2212802d626716815f862da31bcc7d9c44cfe3ab8049e7604b2feb1254869d25b 128 offload dev gre1 dir in sel src 156.251.248.196 dst 120.241.46.59
ip xfrm policy add src 120.241.46.59 dst 156.251.248.196 dir out tmpl src 120.241.46.59 dst 156.251.248.196 proto esp reqid 0x28f39549 mode transport
ip xfrm policy add src 156.251.248.196 dst 120.241.46.59 dir in tmpl src 156.251.248.196 dst 120.241.46.59 proto esp reqid 0x622a73b4 mode transport
ip xfrm policy add src 156.251.248.196 dst 120.241.46.59 dir fwd tmpl src 156.251.248.196 dst 120.241.46.59 proto esp reqid 0x622a73b4 mode transport
}

gre_over_ipsec_set2(){
ip tunnel add gre1 mode gre local 156.251.248.196 remote 120.241.46.59 ttl 255
ip addr add 10.10.10.2 dev gre1 peer 10.10.10.1
ip link set gre1 up
ip xfrm state add src 120.241.46.59 dst 156.251.248.196 proto esp spi 0x28f39549 reqid 0x28f39549 mode transport aead 'rfc4106(gcm(aes))' 0x492e8ffe718a95a00c1893ea61afc64997f4732848ccfe6ea07db483175cb18de9ae411a 128 offload dev gre1 dir in sel src 120.241.46.59 dst 156.251.248.196
ip xfrm state add src 156.251.248.196 dst 120.241.46.59 proto esp spi 0x622a73b4 reqid 0x622a73b4 mode transport aead 'rfc4106(gcm(aes))' 0x093bfee2212802d626716815f862da31bcc7d9c44cfe3ab8049e7604b2feb1254869d25b 128 offload dev gre1 dir out sel src 156.251.248.196 dst 120.241.46.59
ip xfrm policy add src 156.251.248.196 dst 120.241.46.59 dir out tmpl src 156.251.248.196 dst 120.241.46.59 proto esp reqid 0x622a73b4 mode transport 
ip xfrm policy add src 120.241.46.59 dst 156.251.248.196 dir in tmpl src 120.241.46.59 dst 156.251.248.196 proto esp reqid 0x28f39549 mode transport 
ip xfrm policy add src 120.241.46.59 dst 156.251.248.196 dir fwd tmpl src 120.241.46.59 dst 156.251.248.196 proto esp reqid 0x28f39549 mode transport 
}
