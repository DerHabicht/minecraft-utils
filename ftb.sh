start()
{
    echo "Starting server $1."
    screen -d -m -S $1 /home/minecraft/$1/start.sh
    status $1
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
    echo "Stopping server $1"
    screen -S $1 -X stuff ^C
    status $1
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
    screen -ls | grep $1 &>/dev/null

    return $?
}

console()
{
    screen -r $1

    return $?
}

if [ "$2" == "start" ]
then
    start $1
    repsonse=$?
elif [ "$2" == "stop" ]
then
    stop $1
    repsonse=$?
elif [ "$2" == "status" ]
then
    status $1
    response=$?
    if [ "$response" == 0 ]
    then
        echo "Server is running."
    else
        echo "Server is not running."
    fi
elif [ "$2" == "console" ]
then
    console $1
    repsonse=$?
fi

exit $response
