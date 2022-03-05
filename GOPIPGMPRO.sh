#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export frp_v=0.39.1
export oldfrp_v=0.39.0
echo -e "
 ${GREEN} 1.部署frp
 ${GREEN} 2.落地机添加新代理
 ${GREEN} 3.安装frp
 ${GREEN} 4.安装内核
 ${GREEN} 5.删除防火墙
 ${GREEN} 6.管理frp
 ${GREEN} 7.升级frp
 ${GREEN} 8.对接ss
 "
 cd
 read -p "输入选项:" aNum
 if [ "$aNum" = "1" ];then
 cd
echo -e "
 ${GREEN} 1.落地机
 ${GREEN} 2.中转机
 "
 read -p "输入选项:" bNum
if [ "$bNum" = "1" ];then
echo -e "
 ${GREEN} 1.广德1(gzdeMPLS1) 
 ${GREEN} 2.广港1(gzhkMPLS1)
 ${GREEN} 3.广港2(gzhkMPLS2)
 ${GREEN} 4.沪美1(shusMPLS1)
 ${GREEN} 5.苏日1(jsjpMPLS1)
 "
 read -p "请输入括号里的代号:" mplsdh
 cd
 wget -N --no-check-certificate "https://h5ai.ljfxz.net/bqbmpls/${mplsdh}/luodi/client.crt"
 wget -N --no-check-certificate "https://h5ai.ljfxz.net/bqbmpls/${mplsdh}/luodi/client.key"
 wget -N --no-check-certificate "https://h5ai.ljfxz.net/bqbmpls/${mplsdh}/luodi/ca.crt"
 cd frp_${frp_v}_linux_amd64 && rm -rf frpc.ini && wget -N --no-check-certificate "https://h5ai.ljfxz.net/bqbmpls/${mplsdh}/luodi/frpc.ini"
 systemctl restart frpc
 elif [ "$bNum" = "2" ];then
echo -e "
 ${GREEN} 1.广德1(gzdeMPLS1) 
 ${GREEN} 2.广港1(gzhkMPLS1)
 ${GREEN} 3.广港2(gzhkMPLS2)
 ${GREEN} 4.沪美1(shusMPLS1)
 ${GREEN} 5.苏日1(jsjpMPLS1)
 "
 read -p "请输入括号里的代号:" mplsdh
 cd
 wget -N --no-check-certificate "https://h5ai.ljfxz.net/bqbmpls/${mplsdh}/zhongzhuan/server.crt"
 wget -N --no-check-certificate "https://h5ai.ljfxz.net/bqbmpls/${mplsdh}/zhongzhuan/server.key"
 wget -N --no-check-certificate "https://h5ai.ljfxz.net/bqbmpls/${mplsdh}/zhongzhuan/ca.crt"
 cd frp_${frp_v}_linux_amd64 && rm -rf frps.ini && wget -N --no-check-certificate "https://h5ai.ljfxz.net/bqbmpls/${mplsdh}/zhongzhuan/frps.ini"
 systemctl restart frps
 fi
 elif [ "$aNum" = "2" ];then
 cd
 echo -e "
 ${GREEN} 1.tcp代理
 ${GREEN} 2.udp代理
 "
 read -p "请输入选项:" bNum
 if [ "$bNum" = "1" ];then
 read -p "请输入代理名称(不可重复):" dlname
 read -p "输入ss节点ip:" ssip
 read -p "输入ss节点端口:" ssport
 read -p "输入中转监听端口:" zzport
echo "
[${dlname}]
type = tcp
local_ip = ${ssip}
local_port = ${ssport}
remote_port = ${zzport}
" >> /root/frp_${frp_v}_linux_amd64/frpc.ini
 elif [ "$bNum" = "2" ];then
echo "
[${dlname}]
type = udp
local_ip = ${ssip}
local_port = ${ssport}
remote_port = ${zzport}
" >> /root/frp_${frp_v}_linux_amd64/frpc.ini
 fi
 systemctl restart frpc
 elif [ "$aNum" = "3" ];then
 cd
 wget https://github.91chi.fun//https://github.com//fatedier/frp/releases/download/v${frp_v}/frp_${frp_v}_linux_amd64.tar.gz
 tar -xvzf frp_${frp_v}_linux_amd64.tar.gz
 echo -e "
 ${GREEN} 1.落地机
 ${GREEN} 2.中转机
 "
read -p "输入选项:" bNum
if [ "$bNum" = "1" ] ;then
echo "
[Unit]
Description=frpc service
After=network.target network-online.target syslog.target
Wants=network.target network-online.target
[Service]
Type=simple
#启动服务的命令（此处写你的frpc的实际安装目录）
ExecStart=/root/frp_${frp_v}_linux_amd64/frpc -c /root/frp_${frp_v}_linux_amd64/frpc.ini
[Install]
WantedBy=multi-user.target
" > /lib/systemd/system/frpc.service
systemctl enable frpc
elif [ "$bNum" = "2" ] ;then
echo "
[Unit]
Description=frps service
After=network.target network-online.target syslog.target
Wants=network.target network-online.target
[Service]
Type=simple
#启动服务的命令（此处写你的frps的实际安装目录）
ExecStart=/root/frp_${frp_v}_linux_amd64/frps -c /root/frp_${frp_v}_linux_amd64/frps.ini
[Install]
WantedBy=multi-user.target
" > /lib/systemd/system/frps.service
systemctl enable frps
fi
 elif [ "$aNum" = "4" ];then
 wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
 elif [ "$aNum" = "5" ];then
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
  elif [ "$aNum" = "6" ];then
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
 systemctl enable frpc
 elif [ "$bNum" = "8" ];then
 systemctl enable frps
 fi
 elif [ "$aNum" = "7" ];then
 cd frp_${oldfrp_v}_linux_amd64 && mv frps.ini /root/ && mv frpc.ini /root/
cd /root/
rm -rf frp_${oldfrp_v}_linux_amd64 frp_${oldfrp_v}_linux_amd64.tar.gz
wget github.91chi.fun//https://github.com/fatedier/frp/releases/download/v${frp_v}/frp_${frp_v}_linux_amd64.tar.gz && tar -xvzf frp_${frp_v}_linux_amd64.tar.gz
cd frp_${frp_v}_linux_amd64 && rm -rf frps.ini frpc.ini
cd /root/
mv frps.ini /root/frp_${frp_v}_linux_amd64/ && mv frpc.ini /root/frp_${frp_v}_linux_amd64/
rm -rf frp_${frp_v}_linux_amd64.tar.gz
cd
echo -e "
 ${GREEN} 1.落地机
 ${GREEN} 2.中转机
 "
 read -p "请输入选项:" bNum
 if [ "$bNum" = "1" ];then
 sed -i '9s/'${oldfrp_v}'/'${frp_v}'/g' /lib/systemd/system/frpc.service
 systemctl daemon-reload
 sleep 1
 systemctl restart frpc
 elif [ "$bNum" = "2" ];then
 sed -i '9s/'${oldfrp_v}'/'${frp_v}'/g' /lib/systemd/system/frps.service
 systemctl daemon-reload
 sleep 1
 systemctl restart frps
 fi
 elif [ "$aNum" = "8" ] ;then
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
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
  fi
