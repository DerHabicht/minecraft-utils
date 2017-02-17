check_running()
{
    screen -ls | grep $1 &>/dev/null

    return $?
}

send_fail_message()
{
    fail_message+="The $2 server was found to not be running on "
    fail_message+=$(date "+%F at %T").
    if [ "$1" == 0 ]
    then
        fail_message+="\nThe server was successfully restarted.\n"
    else
        fail_message+="\nA restart was attempted, but failed.\n"
    fi

    printf "$fail_message"
}

irc()
{
    source "$HOME/.config/thusmc/ircpass.sh"
    echo "Attempting to connect to IRC on $1..."
    screen -S $1 -X stuff "thump service irc sendraw thus_irc PRIVMSG NickServ IDENTIFY $MCIRCPASS\n"
    sleep 5
    screen -S $1 -X stuff "thump service irc sendraw thus_irc JOIN #Minecraft\n"
}

start()
{
    if [ "$2" == 1 ]
    then
        echo "Starting server $1 with IRC..."
    else
        echo "Starting server $1 without IRC..."
    fi
    screen -d -m -S $1 /home/minecraft/$1/ServerStart.sh

    countdown=5
    while [ $countdown -gt 0 ]
    do
        echo "Waiting for server to finish starting ($countdown min)..."
        echo $((countdown-=1)) > /dev/null
        sleep 60
    done

    check_running $1
    response=$?

    if [ "$response" == 0 ]
    then
        if [ "$2" == 1 ]
        then
            irc $1
        fi
        echo "Server started."
    else
        echo "Server failed to start. Check the logs."
    fi

    return $response
}

stop()
{
    if [ "$2" == 1 ]
    then
        operation="restarting"
    else
        operation="shutting down"
    fi

    countdown=5
    while [ $countdown -gt 1 ]
    do
        echo "Stopping in $countdown minutes..."
        screen -S $1 -X stuff "say Server is $operation in $countdown minutes...\n"
        echo $((countdown-=1)) > /dev/null
        sleep 60
    done

    countdown=60
    while [ $countdown -gt 0 ]
    do
        echo "Stopping in $countdown seconds..."
        screen -S $1 -X stuff "say Server is $operation in $countdown seconds...\n"
        echo $((countdown-=10)) > /dev/null
        sleep 10
    done

    echo "Stopping server $1..."

    screen -S $1 -X stuff ^C
    sleep 10
    check_running $1
    response=$?

    if [ "$response" == 1 ]
    then
        echo "Server stopped."
        repsonse=0
    else
        echo "Server failed to stop. Check the console."
        response=1
    fi

    return $response
}

status()
{
    check_running $1
    response=$?
    if [ "$response" == 0 ]
    then
        echo "Server is running."
    else
        echo "Server is not running."
    fi

    return $response
}

console()
{
    screen -r $1

    return $?
}

restart()
{
    stop $1 1
    start $1 $2
}

if [ "$2" == "start" ]
then
    if [ "$3" == "--irc" ]
    then
        start $1 1
        repsonse=$?
    else
        start $1 0
        repsonse=$?
    fi
elif [ "$2" == "stop" ]
then
    stop $1 0
    repsonse=$?
elif [ "$2" == "status" ]
then
    status $1
    response=$?
elif [ "$2" == "console" ]
then
    console $1
    repsonse=$?
elif [ "$2" == "restart" ]
then
    if [ "$3" == "--irc" ]
    then
        restart $1 1
        response=$?
    else
        restart $1 0
        response=$?
    fi

elif [ "$2" == "checkrun" ]
then
    check_running $1
    if [ "$?" == 1 ]
    then
        if [ "$3" == "--irc" ]
        then
            start $1 1
        else
            start $1 0
        fi

        if [ "$?" == 0 ]
        then
            send_fail_message 0 $1
        else
            send_fail_message 1 $1
        fi
    fi
elif [ "$2" == "irc" ]
then
    irc $1
fi

exit $response
