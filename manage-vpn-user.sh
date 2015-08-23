#!/bin/sh

usage() {
    echo "usage: $0 -A -a|-d|-u|-l <username> [secrets file path]"
    exit 1
}

[ $# -lt 1 ] && usage

CHAP_FILE="/etc/ppp/chap-secrets"
[ $# -eq 3 ] && CHAP_FILE="$3"
cp $CHAP_FILE{,.old} 

add_user() {
    local user=$1
    local n=$(grep -w -c "$user" $CHAP_FILE)
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
    local n=$(grep -w -c "$user" $CHAP_FILE)
    if [ $n -gt 0 ]; then
        echo -n "Delete user [Y/N]?: "
        read option
        if [ "$option" == "y" -o "$option" == "Y" ]; then
            sed -i "/^$user .*$/d" $CHAP_FILE
        fi
    else
        echo "No user: '$user'"
    fi
}

update_user() {
    local user=$1
    local n=$(grep -w -c "$user" $CHAP_FILE)
    if [ $n -gt 0 ]; then
        echo -n "Update user [Y/N]?: "
        read option
        if [ "$option" == "y" -o "$option" == "Y" ]; then
            local passwd="$(< /dev/urandom tr -dC [:alnum:] | head -c 9)"
            local info="$user pptpd $passwd *"
            sed -i "s/^$user.*$/$info/g" $CHAP_FILE
            grep -w "$user" $CHAP_FILE
        fi
    else
        echo -n "User does not exist, would you want add user [Y/N]?: "
        read option
        [ "$option" == "y" -o "$option" == "Y" ] && add_user $user
    fi
}

list_user() {
    local user=$1
    local info="$(grep -w "$user" $CHAP_FILE)"
    if [ -n "$info" ]; then
        echo "$info"
    else
        echo "User does not exist!!"
    fi
}

list_all_user() {
    cat $CHAP_FILE | egrep -v "^#"
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
    "-l")
        list_user $2
        ;;
    "-A")
        list_all_user
        ;;
    *)
        usage
        ;;
esac

exit 0
