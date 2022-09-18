#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
echo -e "
 ${GREEN} 1.安装frp
 ${GREEN} 2.对接ss
 ${GREEN} 3.安装内核
 ${GREEN} 4.删除防火墙
 ${GREEN} 5.管理frp
 ${GREEN} 6.升级frp
 "
 cd
 read -p "输入选项:" aNum
 if [ "$aNum" = "1" ];then
 cd
 mkdir -p /etc/frp
echo -e "
 ${GREEN} 1.客户端(节点)
 ${GREEN} 2.服务端
 ${GREEN} 3.客户端(中转)
 "
 read -p "输入选项:" bNum
if [ "$bNum" = "1" ];then
 wget -N --no-check-certificate -P /usr/bin/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/frpc"
 chmod +x /usr/bin/frpc
 wget -N --no-check-certificate -P /etc/systemd/system/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/frpc.service"
systemctl enable frpc --now
 elif [ "$bNum" = "2" ];then
 wget -N --no-check-certificate -P /usr/bin/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/frps"
 chmod +x /usr/bin/frps
 wget -N --no-check-certificate -P /etc/systemd/system/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/frps.service"
 echo "
[common]
bind_port = 35781
tcp_mux = false
tls_only = true" > /etc/frp/frps.ini
 systemctl enable frps --now
 elif [ "$bNum" = "3" ];then
read -p "输入输入服务端ip:" serverip
read -p "输入节点id:" id
read -p "输入中转机ip:" ip
read -p "输入中转端口(不可重复):" zzport
 echo -e "
 ${GREEN} 1.未安装frp
 ${GREEN} 2.已安装frp
 "
 read -p "输入选项:" cNum
 if [ "$cNum" = "1" ];then
 wget -N --no-check-certificate -P /usr/bin/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/frpc"
 chmod +x /usr/bin/frpc
 wget -N --no-check-certificate -P /etc/systemd/system/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/frpc.service"
  echo "
[common]
server_addr = ${serverip}
server_port = 35781
tcp_mux = false
tls_enable = true

[secret_tcp${id}_visitor]
type = stcp
role = visitor
server_name = secret_tcp${id}
sk = SAD213sadijdi1
bind_addr = ${ip}
bind_port = ${zzport}
[secret_udp${id}_visitor]
type = sudp
role = visitor
server_name = secret_udp${id}
sk = SAD213sadijdi1
bind_addr = ${ip}
bind_port = ${zzport}
" >> /etc/frp/frpc.ini
 elif [ "$cNum" = "2" ];then
 echo "不做安装，进行下一步"
[secret_tcp${id}_visitor]
type = stcp
role = visitor
server_name = secret_tcp${id}
sk = SAD213sadijdi1
bind_addr = ${ip}
bind_port = ${zzport}
[secret_udp${id}_visitor]
type = sudp
role = visitor
server_name = secret_udp${id}
sk = SAD213sadijdi1
bind_addr = ${ip}
bind_port = ${zzport}
" >> /etc/frp/frpc.ini
 fi
 systemctl enable frpc --now
 fi
 elif [ "$aNum" = "2" ];then
bash <(curl -Ls https://raw.githubusercontents.com/csdfsdffese/xrayrsh/master/install.sh)
cd
rm -rf /etc/XrayR/config.yml
read -p "输入对接域名(例如www.baidu.com):" ym
read -p "输入节点id:" nodeid
read -p "输入mukey:" mukey
echo "
Log:
  Level: none # Log level: none, error, warning, info, debug 
  AccessPath: # /etc/XrayR/access.Log
  ErrorPath: # /etc/XrayR/error.log
DnsConfigPath: # /etc/XrayR/dns.json # Path to dns config, check https://xtls.github.io/config/base/dns/ for help
RouteConfigPath: # /etc/XrayR/route.json # Path to route config, check https://xtls.github.io/config/base/route/ for help
OutboundConfigPath: # /etc/XrayR/custom_outbound.json # Path to custom outbound config, check https://xtls.github.io/config/base/outbound/ for help
ConnetionConfig:
  Handshake: 4 # Handshake time limit, Second
  ConnIdle: 30 # Connection idle time limit, Second
  UplinkOnly: 2 # Time limit when the connection downstream is closed, Second
  DownlinkOnly: 4 # Time limit when the connection is closed after the uplink is closed, Second
  BufferSize: 64 # The internal cache size of each connection, kB 
Nodes:
  -
    PanelType: "V2board" # Panel type: SSpanel, V2board, PMpanel, , Proxypanel
    ApiConfig:
      ApiHost: "https://${ym}"
      ApiKey: "${mukey}"
      NodeID: ${nodeid}
      NodeType: Shadowsocks # Node type: V2ray, Shadowsocks, Trojan, Shadowsocks-Plugin
      Timeout: 30 # Timeout for the api request
      EnableVless: false # Enable Vless for V2ray Type
      EnableXTLS: false # Enable XTLS for V2ray and Trojan
      SpeedLimit: 0 # Mbps, Local settings will replace remote settings, 0 means disable
      DeviceLimit: 0 # Local settings will replace remote settings, 0 means disable
      RuleListPath: # ./rulelist Path to local rulelist file
    ControllerConfig:
      ListenIP: 0.0.0.0 # IP address you want to listen
      SendIP: 0.0.0.0 # IP address you want to send pacakage
      UpdatePeriodic: 60 # Time to update the nodeinfo, how many sec.
      EnableDNS: false # Use custom DNS config, Please ensure that you set the dns.json well
      DNSType: AsIs # AsIs, UseIP, UseIPv4, UseIPv6, DNS strategy
      EnableProxyProtocol: false # Only works for WebSocket and TCP
      EnableFallback: false # Only support for Trojan and Vless
      FallBackConfigs:  # Support multiple fallbacks
        -
          SNI: # TLS SNI(Server Name Indication), Empty for any
          Path: # HTTP PATH, Empty for any
          Dest: 80 # Required, Destination of fallback, check https://xtls.github.io/config/fallback/ for details.
          ProxyProtocolVer: 0 # Send PROXY protocol version, 0 for dsable
      CertConfig:
        CertMode: none # Option about how to get certificate: none, file, http, dns. Choose "none" will forcedly disable the tls config.
        CertDomain: "node1.test.com" # Domain to cert
        CertFile: ./cert/node1.test.com.cert # Provided if the CertMode is file
        KeyFile: ./cert/node1.test.com.key
        Provider: alidns # DNS cert provider, Get the full support list here: https://go-acme.github.io/lego/dns/
        Email: test@me.com
        DNSEnv: # DNS ENV option used by DNS provider
          ALICLOUD_ACCESS_KEY: aaa
          ALICLOUD_SECRET_KEY: bbb
  # -
  #   PanelType: "V2board" # Panel type: SSpanel, V2board
  #   ApiConfig:
  #     ApiHost: "http://127.0.0.1:668"
  #     ApiKey: "123"
  #     NodeID: 4
  #     NodeType: Shadowsocks # Node type: V2ray, Shadowsocks, Trojan
  #     Timeout: 30 # Timeout for the api request
  #     EnableVless: false # Enable Vless for V2ray Type
  #     EnableXTLS: false # Enable XTLS for V2ray and Trojan
  #     SpeedLimit: 0 # Mbps, Local settings will replace remote settings
  #     DeviceLimit: 0 # Local settings will replace remote settings
  #   ControllerConfig:
  #     ListenIP: 0.0.0.0 # IP address you want to listen
  #     UpdatePeriodic: 10 # Time to update the nodeinfo, how many sec.
  #     EnableDNS: false # Use custom DNS config, Please ensure that you set the dns.json well
  #     CertConfig:
  #       CertMode: dns # Option about how to get certificate: none, file, http, dns
  #       CertDomain: "node1.test.com" # Domain to cert
  #       CertFile: ./cert/node1.test.com.cert # Provided if the CertMode is file
  #       KeyFile: ./cert/node1.test.com.pem
  #       Provider: alidns # DNS cert provider, Get the full support list here: https://go-acme.github.io/lego/dns/
  #       Email: test@me.com
  #       DNSEnv: # DNS ENV option used by DNS provider
  #         ALICLOUD_ACCESS_KEY: aaa
  #         ALICLOUD_SECRET_KEY: bbb
" > /etc/XrayR/config.yml
cd
XrayR restart
read -p "输入服务端ip:" zzip
 echo "
[common]
server_addr = ${zzip}
server_port = 35781
tcp_mux = false
tls_enable = true

[secret_tcp${nodeid}]
type = stcp
sk = SAD213sadijdi1
local_ip = 127.0.0.1
local_port = 30001
[secret_udp${nodeid}]
type = sudp
sk = SAD213sadijdi1
local_ip = 127.0.0.1
local_port = 30001
" > /etc/frp/frpc.ini
systemctl restart frpc
elif [ "$aNum" = "3" ];then
wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
elif [ "$aNum" = "4" ];then
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
 elif [ "$aNum" = "5" ];then
 echo -e "
 ${GREEN} 1.停止frpc
 ${GREEN} 2.启动frpc
 ${GREEN} 3.重启frpc
 ${GREEN} 4.停止frps
 ${GREEN} 5.启动frps
 ${GREEN} 6.重启frps
 ${GREEN} 7.查看frpc状态
 ${GREEN} 8.查看frps状态
 "
 read -p "请输入选项:" bNum
 if [ "$bNum" = "1" ];then
 systemctl stop frpc
 elif [ "$bNum" = "2" ];then
 systemctl start frpc
 elif [ "$bNum" = "3" ];then
 systemctl restart frpc
 elif [ "$bNum" = "4" ];then
 systemctl stop frps
 elif [ "$bNum" = "5" ];then
 systemctl start frps
 elif [ "$bNum" = "6" ];then
 systemctl restart frps
 elif [ "$bNum" = "7" ];then
 systemctl status frpc
 elif [ "$bNum" = "8" ];then
 systemctl status frps
 fi
  elif [ "$aNum" = "6" ];then
  echo -e "
 ${GREEN} 1.落地机
 ${GREEN} 2.中转机
 "
 read -p "输入选项:" bNum
if [ "$bNum" = "1" ];then
 rm -rf /usr/bin/frpc
 wget -N --no-check-certificate -P /usr/bin/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/frpc"
 chmod +x /usr/bin/frpc
 systemctl start frpc
 elif [ "$bNum" = "2" ];then
 rm -rf /usr/bin/frps
 wget -N --no-check-certificate -P /usr/bin/ "https://h5ai.xinhuanying66.xyz/hympls/hympls/frps"
 chmod +x /usr/bin/frpcs
 systemctl start frps
 fi
 fi
