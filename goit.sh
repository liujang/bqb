#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"

echo -e "
----------------------------------特别声明----------------------------------
--本脚本采用 GRE OVER IPSEC TUNNEL的方式来加密流量数据，加密方式为AES-128-GCM--
----------本脚本只支持debian，在debian10/debian11/debian12上测试通过----------
-----------------------------write by tg:@ljfxz-----------------------------
"

gre_open(){
modprobe ip_gre
echo -e "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
}

iptables_install(){
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
cat > /root/goitzq.sh << EOF
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
ip tunnel add gre1 mode gre local ${LOCAL_IP} remote ${REMOTE_IP} ttl 255
ip addr add ${LOCAL_VIRTUAL_IP} dev gre1 peer ${REMOTE_VIRTUAL_IP}
ip link set gre1 up
ip xfrm state add src ${LOCAL_IP} dst ${REMOTE_IP} proto esp spi 0x28f39549 reqid 0x28f39549 mode transport aead 'rfc4106(gcm(aes))' 0x492e8ffe718a95a00c1893ea61afc64997f4732848ccfe6ea07db483175cb18de9ae411a 128 offload dev gre1 dir out sel src ${LOCAL_IP} dst ${REMOTE_IP}
ip xfrm state add src ${REMOTE_IP} dst ${LOCAL_IP} proto esp spi 0x622a73b4 reqid 0x622a73b4 mode transport aead 'rfc4106(gcm(aes))' 0x093bfee2212802d626716815f862da31bcc7d9c44cfe3ab8049e7604b2feb1254869d25b 128 offload dev gre1 dir in sel src ${REMOTE_IP} dst ${LOCAL_IP}
ip xfrm policy add src ${LOCAL_IP} dst ${REMOTE_IP} dir out tmpl src ${LOCAL_IP} dst ${REMOTE_IP} proto esp reqid 0x28f39549 mode transport
ip xfrm policy add src ${REMOTE_IP} dst ${LOCAL_IP} dir in tmpl src ${REMOTE_IP} dst ${LOCAL_IP} proto esp reqid 0x622a73b4 mode transport
ip xfrm policy add src ${REMOTE_IP} dst ${LOCAL_IP} dir fwd tmpl src ${REMOTE_IP} dst ${LOCAL_IP} proto esp reqid 0x622a73b4 mode transport
iptables-restore < /etc/iptables.up.rules
EOF
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
cat > /root/goitzq.sh << EOF
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
ip tunnel add gre1 mode gre local ${LOCAL_IP} remote ${REMOTE_IP} ttl 255
ip addr add ${LOCAL_VIRTUAL_IP} dev gre1 peer ${REMOTE_VIRTUAL_IP}
ip link set gre1 up
ip xfrm state add src ${REMOTE_IP} dst ${LOCAL_IP} proto esp spi 0x28f39549 reqid 0x28f39549 mode transport aead 'rfc4106(gcm(aes))' 0x492e8ffe718a95a00c1893ea61afc64997f4732848ccfe6ea07db483175cb18de9ae411a 128 offload dev gre1 dir in sel src ${REMOTE_IP} dst ${LOCAL_IP}
ip xfrm state add src ${LOCAL_IP} dst ${REMOTE_IP} proto esp spi 0x622a73b4 reqid 0x622a73b4 mode transport aead 'rfc4106(gcm(aes))' 0x093bfee2212802d626716815f862da31bcc7d9c44cfe3ab8049e7604b2feb1254869d25b 128 offload dev gre1 dir out sel src ${LOCAL_IP} dst ${REMOTE_IP}
ip xfrm policy add src ${LOCAL_IP} dst ${REMOTE_IP} dir out tmpl src ${LOCAL_IP} dst ${REMOTE_IP} proto esp reqid 0x622a73b4 mode transport 
ip xfrm policy add src ${REMOTE_IP} dst ${LOCAL_IP} dir in tmpl src ${REMOTE_IP} dst ${LOCAL_IP} proto esp reqid 0x28f39549 mode transport 
ip xfrm policy add src ${REMOTE_IP} dst ${LOCAL_IP} dir fwd tmpl src ${REMOTE_IP} dst ${LOCAL_IP} proto esp reqid 0x28f39549 mode transport 
iptables-restore < /etc/iptables.up.rules
EOF
}

iptables_set1(){
read -p "输入要监听的ip:" LISTEN_IP
read -p "输入要监听的端口:" LISTEN_PORT
read -p "输入对端虚拟ip:" REMOTE_VIRTUAL_IP
read -p "输入要转发的端口" REMOTE_PORT
read -p "输入本机虚拟ip" LOCAL_VIRTUAL_IP
iptables -t nat -A PREROUTING -d ${LISTEN_IP}/32 -p tcp -m tcp --dport ${LISTEN_PORT} -j DNAT --to-destination ${REMOTE_VIRTUAL_IP}:${REMOTE_PORT}
iptables -t nat -A PREROUTING -d ${LISTEN_IP}/32 -p udp -m udp --dport ${LISTEN_PORT} -j DNAT --to-destination ${REMOTE_VIRTUAL_IP}:${REMOTE_PORT}
iptables -t nat -A POSTROUTING -d ${REMOTE_VIRTUAL_IP}/32 -p tcp -m tcp --dport ${REMOTE_PORT} -j SNAT --to-source ${LOCAL_VIRTUAL_IP}
iptables -t nat -A POSTROUTING -d ${REMOTE_VIRTUAL_IP}/32 -p udp -m udp --dport ${REMOTE_PORT} -j SNAT --to-source ${LOCAL_VIRTUAL_IP}
iptables-save > /etc/iptables.up.rules
iptables-restore < /etc/iptables.up.rules
read -e -p "是否继续 添加端口转发配置？[Y/n]:" addyn
[[ -z ${addyn} ]] && addyn="y"
if [[ ${addyn} == [Yy] ]]; then
iptables_set1
else
goit_menu
fi
}

iptables_set2(){
read -p "输入本机ip:" LOCAL_IP
read -p "输入要监听的端口:" LISTEN_PORT
read -p "输入本机虚拟ip:" LOCAL_VIRTUAL_IP
read -p "输入要转发的ip:" REMOTE_IP
read -p "输入要转发的端口:" REMOTE_PORT
iptables -t nat -A PREROUTING -d ${LOCAL_VIRTUAL_IP}/32 -p tcp -m tcp --dport ${LISTEN_PORT} -j DNAT --to-destination ${REMOTE_IP}:${REMOTE_PORT}
iptables -t nat -A PREROUTING -d ${LOCAL_VIRTUAL_IP}/32 -p udp -m udp --dport ${LISTEN_PORT} -j DNAT --to-destination ${REMOTE_IP}:${REMOTE_PORT}
iptables -t nat -A POSTROUTING -d ${REMOTE_IP}/32 -p tcp -m tcp --dport ${REMOTE_PORT} -j SNAT --to-source ${LOCAL_IP}
iptables -t nat -A POSTROUTING -d ${REMOTE_IP}/32 -p udp -m udp --dport ${REMOTE_PORT} -j SNAT --to-source ${LOCAL_IP}
iptables-save > /etc/iptables.up.rules
iptables-restore < /etc/iptables.up.rules
read -e -p "是否继续 添加端口转发配置？[Y/n]:" addyn
[[ -z ${addyn} ]] && addyn="y"
if [[ ${addyn} == [Yy] ]]; then
iptables_set2
else
goit_menu
fi
}

view_iptables_list(){
iptables_list_rows=$(iptables -t nat -nL PREROUTING --line-number | tail -n +3 | wc -l)
for((i=1;i<=$iptables_list_rows;i++));
do
num=`iptables -t nat -nL PREROUTING --line-number | grep "$i    DNAT" | awk '{print $1}'`
type=`iptables -t nat -nL PREROUTING --line-number | grep "$i    DNAT" | awk '{print $3}'`
listen_ip=`iptables -t nat -nL PREROUTING --line-number | grep "$i    DNAT" | awk '{print $6}'`
listen_port=`iptables -t nat -nL PREROUTING --line-number | grep "$i    DNAT" | awk '{print $8}' | awk -F "dpt:" '{print $2}'`
remote_ipandport=`iptables -t nat -nL PREROUTING --line-number | grep "$i    DNAT" | awk '{print $9}' | awk -F "to:" '{print $2}'`
echo "序号:${num}   类型:${type}   监听>${listen_ip}:${listen_port}   转发>${remote_ipandport}"
done
}

delete_iptables(){
view_iptables_list
read -p "输入要删除的序号:" Num
iptables -t nat -D PREROUTING ${Num}
iptables -t nat -D POSTROUTING ${Num}
read -e -p "是否继续 删除转发配置？[Y/n]:" addyn
[[ -z ${addyn} ]] && addyn="y"
if [[ ${addyn} == [Yy] ]]; then
delete_iptables
else
goit_menu
fi
}

add_gre_over_ipsec(){
gre_open
echo -e "
 ${GREEN} 1.中转机(入口)
 ${GREEN} 2.对端机(出口)
 "
read -p "输入选项:" aNum
if [ "${aNum}" = "1" ];then
gre_over_ipsec_set1
elif [ "${aNum}" = "2" ];then
gre_over_ipsec_set2
fi
chmod +x /root/goitzq.sh
cat > /usr/lib/systemd/system/goitzq.service << EOF
[Unit]
Description=goitzq server

[Service]
Type=simple
ExecStart=/usr/bin/bash /root/goitzq.sh

[Install]
WantedBy=multi-user.target
EOF
systemctl enable goitzq --now
systemctl daemon-reload
goit_menu
}

add_iptables(){
echo -e "
 ${GREEN} 1.中转机(入口)
 ${GREEN} 2.对端机(出口)
 "
read -p "输入选项:" aNum
if [ "${aNum}" = "1" ];then
iptables_set1
elif [ "${aNum}" = "2" ];then
iptables_set2
fi
}

goit_menu(){
echo -e " 
 ${GREEN} 1.配置gre over ipsec
 ${GREEN} 2.安装iptables
 ${GREEN} 3.添加转发规则
 ${GREEN} 4.删除转发规则
 ${GREEN} 5.查看转发规则
 ${GREEN} 0.退出脚本
 "
read -p " 请输入数字后[0-5p] 按回车键:" num
case "$num" in
	1)
	add_gre_over_ipsec
	;;
	2)
	iptables_install
	;;
	3)
	add_iptables
	;;
	4)
	delete_iptables
	;;
        5)
	view_iptables_list
	;;
	0)
	exit 1
	;;
	*)	
	echo "请输入正确数字 [0-5] 按回车键"
	goit_menu
	;;
esac
}
goit_menu
