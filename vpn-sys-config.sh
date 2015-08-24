#!/bin/sh

if [ $# -gt 1 ]; then
    echo "usage: $0 [wan interface]"
    exit 1
fi

# iptables config
IPTABLES="/sbin/iptables -t nat -I POSTROUTING"
if [ $# -ne 1 ]; then
    WAN_INTERFACE="$(route -n | head -3 | tail -1 | awk '{print $8}')"
else
    WAN_INTERFACE="$1"
fi
$IPTABLES -o $WAN_INTERFACE -j MASQUERADE
/sbin/iptables-save

# system control config
/sbin/sysctl -w net.ipv4.ip_forward=1
