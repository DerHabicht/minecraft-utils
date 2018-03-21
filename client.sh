if [ "$1" == "update" ]
then
    cd "$2"
    git pull
else
    java -jar $HOME/lib/Minecraft.jar
fi
