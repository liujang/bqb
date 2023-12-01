#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear

RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"

public_ip=`curl -s http://ipv4.icanhazip.com`

show_ip(){
echo "公共IPV4为 $public_ip"
}
XrayR_install(){
echo -e "
 ${GREEN} 1.SSpanel
 ${GREEN} 2.NewV2board
 ${GREEN} 3.V2board
"
read -p "请输入选项:" aNum
if [ "$aNum" = "1" ];then
panel="SSpanel"
elif [ "$aNum" = "2" ];then
panel="NewV2board"
elif [ "$aNum" = "3" ];then
panel="V2board"
else
echo "输入错误"
fi
read -p "输入对接域名:" api
echo -e "
 ${GREEN} 1.https
 ${GREEN} 2.http
"
read -p "请输入选项:" bNum
if [ "$bNum" = "1" ];then
hhh="https"
elif [ "$bNum" = "2" ];then
hhh="http"
else
echo "输入错误"
fi
read -p "输入mukey:" mukey
read -p "输入节点id:" nodeid
echo -e "
 ${GREEN} 1.Shadowsocks
 ${GREEN} 2.V2ray
"
read -p "输入节点类型:" bNum
if [ "$bNum" = "1" ];then
node_type="Shadowsocks"
elif [ "$bNum" = "2" ];then
node_type="V2ray"
else
echo "输入错误"
fi
echo "
Log:
  Level: none # Log level: none, error, warning, info, debug 
  AccessPath: # /etc/XrayR/access.Log
  ErrorPath: # /etc/XrayR/error.log
DnsConfigPath: # /etc/XrayR/dns.json # Path to dns config, check https://xtls.github.io/config/dns.html for help
RouteConfigPath: # /etc/XrayR/route.json # Path to route config, check https://xtls.github.io/config/routing.html for help
InboundConfigPath: # /etc/XrayR/custom_inbound.json # Path to custom inbound config, check https://xtls.github.io/config/inbound.html for help
OutboundConfigPath: # /etc/XrayR/custom_outbound.json # Path to custom outbound config, check https://xtls.github.io/config/outbound.html for help
ConnectionConfig:
  Handshake: 4 # Handshake time limit, Second
  ConnIdle: 10 # Connection idle time limit, Second
  UplinkOnly: 2 # Time limit when the connection downstream is closed, Second
  DownlinkOnly: 4 # Time limit when the connection is closed after the uplink is closed, Second
  BufferSize: 64 # The internal cache size of each connection, kB 
Nodes:
  -
    PanelType: "\"$panel\"" # Panel type: SSpanel, NewV2board, V2board, PMpanel, Proxypanel
    ApiConfig:
      ApiHost: "\"$hhh://$api\""
      ApiKey: "\"$mukey\""
      NodeID: $nodeid
      NodeType: $node_type # Node type: V2ray, Trojan, Shadowsocks, Shadowsocks-Plugin
      Timeout: 30 # Timeout for the api request
      EnableVless: false # Enable Vless for V2ray Type
      EnableXTLS: false # Enable XTLS for V2ray and Trojan
      SpeedLimit: 0 # Mbps, Local settings will replace remote settings, 0 means disable
      DeviceLimit: 0 # Local settings will replace remote settings, 0 means disable
      RuleListPath: # /etc/XrayR/rulelist Path to local rulelist file
    ControllerConfig:
      ListenIP: 0.0.0.0 # IP address you want to listen
      SendIP: 0.0.0.0 # IP address you want to send pacakage
      UpdatePeriodic: 60 # Time to update the nodeinfo, how many sec.
      EnableDNS: false # Use custom DNS config, Please ensure that you set the dns.json well
      DNSType: AsIs # AsIs, UseIP, UseIPv4, UseIPv6, DNS strategy
      DisableUploadTraffic: false # Disable Upload Traffic to the panel
      DisableGetRule: false # Disable Get Rule from the panel
      DisableIVCheck: false # Disable the anti-reply protection for Shadowsocks
      DisableSniffing: false # Disable domain sniffing 
      EnableProxyProtocol: false
      AutoSpeedLimitConfig:
        Limit: 0 # Warned speed. Set to 0 to disable AutoSpeedLimit (mbps)
        WarnTimes: 0 # After (WarnTimes) consecutive warnings, the user will be limited. Set to 0 to punish overspeed user immediately.
        LimitSpeed: 0 # The speedlimit of a limited user (unit: mbps)
        LimitDuration: 0 # How many minutes will the limiting last (unit: minute)
      GlobalDeviceLimitConfig:
        Enable: false # Enable the global device limit of a user
        RedisAddr: 127.0.0.1:6379 # The redis server address
        RedisPassword: YOUR PASSWORD # Redis password
        RedisDB: 0 # Redis DB
        Timeout: 5 # Timeout for redis request
        Expiry: 60 # Expiry time (second)
      EnableFallback: false # Only support for Trojan and Vless
      FallBackConfigs:  # Support multiple fallbacks
        -
          SNI: # TLS SNI(Server Name Indication), Empty for any
          Alpn: # Alpn, Empty for any
          Path: # HTTP PATH, Empty for any
          Dest: 80 # Required, Destination of fallback, check https://xtls.github.io/config/fallback/ for details.
          ProxyProtocolVer: 0 # Send PROXY protocol version, 0 for dsable
      CertConfig:
        CertMode: dns # Option about how to get certificate: none, file, http, dns. Choose "none" will forcedly disable the tls config.
        RejectUnknownSni: false # Reject unknown SNI
        CertDomain: "node1.test.com" # Domain to cert
        CertFile: /etc/XrayR/cert/node1.test.com.cert # Provided if the CertMode is file
        KeyFile: /etc/XrayR/cert/node1.test.com.key
        Provider: alidns # DNS cert provider, Get the full support list here: https://go-acme.github.io/lego/dns/
        Email: test@me.com
        DNSEnv: # DNS ENV option used by DNS provider
          ALICLOUD_ACCESS_KEY: aaa
          ALICLOUD_SECRET_KEY: bbb
" > ./$api$nodeid.yml
docker pull ghcr.io/xrayr-project/xrayr:v0.9.0 && docker run --restart=always --name $api$nodeid -d -v $(pwd)/$api$nodeid.yml:/etc/XrayR/config.yml --network=host ghcr.io/xrayr-project/xrayr:v0.9.0
}
socks5_install(){
read -p "输入端口:" sk_port
read -p "输入用户名:" sk_user
read -p "输入密码:" sk_passwd
docker run -d --name socks5$sk_port -p $sk_port:$sk_port -e PROXY_USER=$sk_user -e PROXY_PASSWORD=$sk_passwd  serjs/go-socks5-proxy
echo "
IP：    $public_ip
PORT:   $sk_port
USER:   $sk_user
PASSWD: $sk_passwd
"
}
ss_install(){
read -p "输入端口:" ss_port
read -p "输入密码:" ss_passwd
mkdir -p shadowsocks-libev$ss_port
cd shadowsocks-libev$ss_port
read -p "输入端口:" ss_port
read -p "输入密码:" ss_passwd
echo "
{
    "\"server\"":"\"0.0.0.0\"",
    "\"server_port\"":$ss_port,
    "\"password\"":"\"$ss_passwd\"",
    "\"timeout\"":300,
    "\"method\"":"\"aes-256-gcm\"",
    "\"fast_open\"":false,
    "\"mode\"":"\"tcp_and_udp\""
}
" > config.json
docker run -d -p $ss_port:$ss_port -p $ss_port:$ss_port/udp --name $ss_port -v $(pwd)/shadowsocks-libev$ss_port:$(pwd)/shadowsocks-libev$ss_port appso/shadowsocks-libev
echo "
IP：    $public_ip
PORT:   $ss_port
PASSWD: $ss_passwd
METHOD: aes-256-gcm
"
}
menu(){
show_ip
echo -e " 
 ${GREEN} 1.搭建XrayR
 ${GREEN} 2.搭建socks5
 ${GREEN} 3.搭建ss
 "
read -p " 请输入数字后[0-3] 按回车键:" num
case "$num" in
	1)
	XrayR_install
        clear
	menu
	;;
	2)
	socks5_install
        menu
	;;
	3)
	ss_install
        menu
	;;
	*)	
	echo "请输入正确数字 [0-3] 按回车键"
	sleep 1s
 menu
	;;
esac
}
menu
