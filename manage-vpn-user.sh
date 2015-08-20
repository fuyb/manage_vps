#!/bin/sh

usage() {
    echo "usage: $0 <add> <username> <passwd>
                 $0 <del> <username>"
    exit 1
}

[ $# -lt 2 ] && usage
[ "$1" != "add" -a "$1" != "del" ] && usage
[ "$1" = "add" -a "$#" -ne 3 ] && usage
[ "$1" = "del" -a "$#" -ne 2 ] && usage

USER=$2
CHAP_FILE="/etc/ppp/chap-secrets"

cp $CHAP_FILE $CHAP_FILE.old

if [ "$1" = "add" ]; then
    PASSWD=$3
    echo "$USER pptpd $PASSWD *" >> $CHAP_FILE
    tail -1 $CHAP_FILE
elif [ "$1" = "del" ]; then
    sed -i "/^$USER.*$/d" $CHAP_FILE
fi

exit 0
