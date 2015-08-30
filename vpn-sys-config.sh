#!/bin/sh

if [ $# -lt 1 ]; then
    echo "usage: $0 [wan interface]"
    exit 1
fi

IPTABLES="/sbin/iptables"
if [ $# -ne 1 ]; then
    WAN_INTERFACE="$(route -n | head -3 | tail -1 | awk '{print $8}')"
else
    WAN_INTERFACE="$1"
fi

# iptables config
$IPTABLES -t nat -I POSTROUTING -o $WAN_INTERFACE -j MASQUERADE
echo -n "Enable client talk to each other: [Y/N]?"
read client_talk
if [ "$client_talk" == "Y" -o "$client_talk" == "y" ]; then
    # client talk to each other config
    $IPTABLES -I INPUT -s 10.0.0.0/8 -i ppp0 -j ACCEPT
    $IPTABLES -A FORWARD -o $WAN_INTERFACE -j ACCEPT
fi
/sbin/iptables-save

# system control config
/sbin/sysctl -w net.ipv4.ip_forward=1
