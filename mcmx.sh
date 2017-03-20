registry="$HOME/.config/thusmc/active_servers"

register_server() {
    grep -q -F "$1" $registry || echo "$1" >> $registry
}

unregister_server() {
    sed -i "s:$1::g" $registry
    sed -i "/^$/d" $registry
}

if [ "$1" == "enable" ]
then
    register_server "$2"
    /home/minecraft/bin/mc "$2" start
elif [ "$1" == "disable" ]
then
    /home/minecraft/bin/mc "$2" stop
    unregister_server "$2"
elif [ "$1" == "checkrun" ]
then
    while IFS= read -r line
    do
        /home/minecraft/bin/mc "$line" checkrun --silent
    done < $registry
elif [ "$1" == "restart" ]
then
    while IFS= read -r line
    do
        /home/minecraft/bin/mc "$line" restart --silent
    done < $registry
elif [ "$1" == "active" ]
then
    cat $registry
elif [ "status" ]
then
    while IFS= read -r line
    do
        /home/minecraft/bin/mc "$line" status
    done < $registry
fi

