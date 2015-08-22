#!/bin/sh

usage() {
    echo "usage: $0 -a -d -u <username>"
    exit 1
}

[ $# -lt 2 ] && usage

CHAP_FILE="/etc/ppp/chap-secrets"
cp $CHAP_FILE $CHAP_FILE.old

add_user() {
    local user=$1
    local n=$(grep -c "$user" $CHAP_FILE)
    if [ $n -eq 0 ]; then
        local passwd="$(< /dev/urandom tr -dC [:alnum:] | head -c 9)"
        echo "$user pptpd $passwd *" >> $CHAP_FILE
        tail -1 $CHAP_FILE
    else
        echo "User already exist!"
    fi
}

del_user() {
    local user=$1
    local n=$(grep -c "$user" $CHAP_FILE)
    if [ $n -gt 0 ]; then
        echo -n "Delete user [Y/N]?: "
        read option
        if [ "$option" == "y" -o "$option" == "Y" ]; then
            sed -i "/$user/d" $CHAP_FILE
        fi
    else
        echo "No user: '$user'"
    fi
}

update_user() {
    local user=$1
    local n=$(grep -c "$user" $CHAP_FILE)
    if [ $n -gt 0 ]; then
        echo -n "Update user [Y/N]?: "
        read option
        if [ "$option" == "y" -o "$option" == "Y" ]; then
            local passwd="$(< /dev/urandom tr -dC [:alnum:] | head -c 9)"
            local info="$user pptpd $passwd *"
            sed -i "s/^$user.*$/$info/g" $CHAP_FILE
            grep "$user" $CHAP_FILE
        fi
    else
        echo -n "User does not exist, would you want add user [Y/N]?: "
        read option
        [ "$option" == "y" -o "$option" == "Y" ] && add_user $user
    fi
}

case $1 in
    "-a")
        add_user $2
        ;;
    "-d")
        del_user $2
        ;;
    "-u")
        update_user $2
        ;;
    *)
        usage
        ;;
esac

exit 0
