#!/bin/sh

usage() {
    echo "usage: $0 <add> <username>
       $0 <del> <username>"
    exit 1
}

[ $# -lt 2 ] && usage
[ "$1" != "add" -a "$1" != "del" ] && usage

CHAP_FILE="/etc/ppp/chap-secrets"

cp $CHAP_FILE $CHAP_FILE.old
add_user() {
    local user=$1
    local passwd="$(< /dev/urandom tr -dC [:alnum:] | head -c 9)"
    echo "$user pptpd $passwd *" >> $CHAP_FILE
    tail -1 $CHAP_FILE
}

del_user() {
    local user=$1
    sed -i "/$user/d" $CHAP_FILE
}

case $1 in
    "add")
        add_user $2
        ;;
    "del")
        del_user $2
        ;;
    *)
        usage
        ;;
esac

exit 0
