check_running()
{
    screen -ls | grep $1 &>/dev/null

    return $?
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
        if [ "$3" != "false" ]
        then
            echo "Starting server $1 with IRC..."
        fi
    else
        if [ "$3" != "false" ]
        then
            echo "Starting server $1 without IRC..."
        fi
    fi
    screen -d -m -S $1 /home/minecraft/$1/ServerStart.sh

    countdown=5
    while [ $countdown -gt 0 ]
    do
        if [ "$3" != "false" ]
        then
            echo "Waiting for server to finish starting ($countdown min)..."
        fi

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

        if [ "$3" != "false" ]
        then
            echo "Server started."
        fi
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
        if [ "$3" != "false" ]
        then
            echo "Stopping in $countdown minutes..."
        fi
        screen -S $1 -X stuff "say Server is $operation in $countdown minutes...\n"
        echo $((countdown-=1)) > /dev/null
        sleep 60
    done

    countdown=60
    while [ $countdown -gt 0 ]
    do
        if [ "$3" != "false" ]
        then
            echo "Stopping in $countdown seconds..."
        fi
        screen -S $1 -X stuff "say Server is $operation in $countdown seconds...\n"
        echo $((countdown-=10)) > /dev/null
        sleep 10
    done

    if [ "$3" != "false" ]
    then
        echo "Stopping server $1..."
    fi

    screen -S $1 -X stuff ^C
    sleep 10
    check_running $1
    response=$?

    if [ "$response" == 1 ]
    then
        if [ "$3" != "false" ]
        then
            echo "Server stopped."
        fi
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
    if [ "$3" == "--silent" ]
    then
        start $1 1 "false"
        repsonse=$?
    else
        start $1 1 "true"
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
    if [ "$3" == "--silent" ]
    then
        restart $1 1 "false"
        response=$?
    else
        restart $1 1 "true"
        response=$?
    fi

elif [ "$2" == "checkrun" ]
then
    check_running $1
    if [ "$?" == 1 ]
    then
        fail="The $1 server was found to not be running on "
        fail+=$(date "+%F at %T")
        printf "$fail"
        printf ".\nThe latest log follows."
        printf "\n\n-------------------------------------------------------------------------------\n\n"
        cat /home/minecraft/$1/logs/latest.log
        printf "\n\n-------------------------------------------------------------------------------\n\n"

        if [ "$3" == "--silent" ]
        then
            start $1 1 "false"
        else
            start $1 1 "true"
        fi

        if [ "$?" == 0 ]
        then
            printf "The server was successfully restarted."
        else
            printf "A restart was attempted, but failed."
        fi
    fi
elif [ "$2" == "irc" ]
then
    irc $1
fi

exit $response
