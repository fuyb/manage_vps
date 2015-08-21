#!/bin/sh

usage() {
    echo "usage: $0 <add> <username>
       $0 <del> <username>"
    exit 1
}

[ $# -lt 2 ] && usage
[ "$1" != "add" -a "$1" != "del" ] && usage

USER=$2
CHAP_FILE="/etc/ppp/chap-secrets"

cp $CHAP_FILE $CHAP_FILE.old

if [ "$1" = "add" ]; then
    PASSWD="$(< /dev/urandom tr -dC [:alnum:] | head -c 9)"
    echo "$USER pptpd $PASSWD *" >> $CHAP_FILE
    tail -1 $CHAP_FILE
elif [ "$1" = "del" ]; then
    sed -i "/^$USER.*$/d" $CHAP_FILE
fi

exit 0
