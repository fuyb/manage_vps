#!/bin/sh

SS_SERVER_BIN="/usr/bin/ss-server"
CONFIG_FILE_PATH="/etc/shadowsocks-libev"

for entry in "$CONFIG_FILE_PATH"/*
do
    if [ -f "$entry" ]; then
        filename="$(basename $entry)"
        suffix="${filename##*.}"
        if [ "$suffix" = "json" ]; then
            username="$(basename "$filename" ".json")"
            running=$(ps aux | grep "$CONFIG_FILE_PATH" | grep -c "$username")
            if [ "$running" -eq "0" ]; then
                $SS_SERVER_BIN -c "$entry" -a shadowsocks \
                    -u -f /var/run/shadowsocks-libev/"$username"".pid"
            fi
        fi
    fi
done


