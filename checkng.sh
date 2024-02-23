#!/usr/bin/env bash
if pgrep "nginx" >/dev/null 2>&1 ; then
    echo "nginx is running" >/dev/null 2>&1 ;
else
    systemctl restart nginx
fi
