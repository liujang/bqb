#!/usr/bin/env bash
RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"
echo "export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
cd /usr/bin/ && rm -rf realm
cd /root/
wget https://h5ai.ljfxz.net/bqbmpls/bqbmpls/realm
mv realm /usr/bin/ && chmod +x /usr/bin/realm
export PATH="$PATH:/usr/bin"
systemctl restart realm
