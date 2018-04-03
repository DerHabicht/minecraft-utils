if [ "$1" == "install" ]
then
    if [ -d "$HOME/minecraft/$2" ]
    then
        echo "$2 is already installed"
    else
        cd "$HOME/minecraft"
        git clone "thusmc@mc.the-hawk.us:$2"
    fi
elif [ "$1" == "update" ]
then
    if [ -d "$HOME/minecraft/$2" ]
    then
        cd "$HOME/minecraft/$2"
        git pull
    else
        echo "$2 is not an installed modpack"
    fi
elif [ "$1" == "version" ]
then
    if [ -d "$HOME/minecraft/$2" ]
    then
        cat "$HOME/minecraft/$2/.thusinfo"
    else
        echo "$2 is not an installed modpack"
    fi
else
    java -jar $HOME/lib/Minecraft.jar
fi
