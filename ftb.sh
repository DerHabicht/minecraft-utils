check_running()
{
    screen -ls | grep $1 &>/dev/null

    return $?
}

send_fail_message()
{
    fail_message="Subject: Server failure $2\n\n"
    fail_message+="The $2 server was found to not be running on "
    fail_message+=$(date "+%F at %T").
    if [ "$1" == 0 ]
    then
        fail_message+="\n\nThe server was successfully restarted."
    else
        fail_message+="\n\nA restart was attempted, but failed."
    fi

    echo "$fail_message"
}

start()
{
    echo "Starting server $1."
    screen -d -m -S $1 /home/minecraft/$1/ServerStart.sh
    sleep 10
    check_running $1
    response=$?

    if [ "$response" == 0 ]
    then
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
        echo "Stopping in $countdown minutes.."
        screen -S $1 -X stuff "say Server is $operation in $countdown minutes..\n"
        echo $((countdown-=1)) > /dev/null
        sleep 60
    done

    countdown=60
    while [ $countdown -gt 0 ]
    do
        echo "Stopping in $countdown seconds..."
        screen -S $1 -X stuff "say Server is $operation in $countdown seconds...\n"
        echo $((countdown-=1)) > /dev/null
        sleep 60
    done

    echo "Stopping server $1"

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
    start $1
}

if [ "$2" == "start" ]
then
    start $1
    repsonse=$?
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
    restart $1
    response=$?
elif [ "$2" == "checkrun" ]
then
    check_running $1
    if [ "$?" == 1 ]
    then
        start $1
        if [ "$?" == 0 ]
        then
            send_fail_message 0 $1
        else
            send_fail_message 1 $1
        fi
    fi
fi

exit $response
