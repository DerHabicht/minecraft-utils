if [ "$1" == "install" ]
then
    if [ -d "$HOME/.minecraft" ]
    then
        if [ ! -d "$HOME/minecraft" ]
        then
            mkdir "$HOME/minecraft"
        fi
        if [ -d "$HOME/minecraft/$2" ]
        then
            echo "$2 is already installed"
        else
            cd "$HOME/minecraft"
            git clone "thusmc@mc.the-hawk.us:$2"
            if [ "$?" != 0 ]
            then
                echo ""
                echo "Sorry, it looks like $2 is not a valid modpack."
                echo "$2 could not be installed."
                exit
            fi
            cd "$2"
            source .thusinfo
            java -jar "forge-$FORGE-installer.jar"
        fi
    else
        echo "Minecraft has not run on this system yet."
        echo "You will need to run Minecraft before installing a modpack."
        echo "Do you want to run the Minecraft JAR now?"
        read choice

        if [ "$choice" == "yes" ]
        then
            if [ ! -f "$HOME/lib/Minecraft.jar" ]
            then
                wget -O $HOME/lib/Minecraft.jar http://s3.amazonaws.com/Minecraft.Download/launcher/Minecraft.jar
            fi
            java -jar $HOME/lib/Minecraft.jar
        fi
    fi
elif [ "$1" == "update" ]
then
    if [ -d "$HOME/minecraft/$2" ]
    then
        cd "$HOME/minecraft/$2"
        source .thusinfo
        OLDFORGE=$FORGE
        git reset --hard HEAD
        git pull
        source .thusinfo
        if [ "$OLDFORGE" != "$FORGE" ]
        then
            echo "This pack uses a new version of Minecraft Forge."
            echo "The Forge installer will launch now."
            java -jar "forge-$FORGE-installer.jar"
        fi
    else
        echo "$2 is not an installed modpack"
    fi
elif [ "$1" == "version" ]
then
    if [ -d "$HOME/minecraft/$2" ]
    then
        source "$HOME/minecraft/$2/.thusinfo"
        echo "$VERSION"
    else
        echo "$2 is not an installed modpack"
    fi
else
    java -jar $HOME/lib/Minecraft.jar
fi
