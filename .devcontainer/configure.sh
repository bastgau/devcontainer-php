#!/bin/bash

echo -e ""

# VARIABLE DECLARATION

CONFIG_DIRECTORY="/workspaces/app/.config"
ERROR_DIRECTORY="/workspaces/app/logs"

NOTHING=1

echo -e "š© Prepare ENVIRONMENT :\n"

if [ ! -d "$CONFIG_DIRECTORY" ]; then
    echo "ā¹ļø  Directory : $CONFIG_DIRECTORY will be created"
    mkdir $CONFIG_DIRECTORY
    NOTHING=0
fi

if [ ! -d "$ERROR_DIRECTORY" ]; then
    echo "ā¹ļø  Directory : $ERROR_DIRECTORY will be created"
    mkdir $ERROR_DIRECTORY
    NOTHING=0
fi

if [ $NOTHING == 1 ]; then
    echo "ā¹ļø  Nothing to prepare"
fi

echo -e "\nš ENVIRONMENT preparation is finished !"
echo -e "\n-----------------------------\n"

echo -e "š© Configure PHP :\n"
sudo chmod +x "$(pwd)"/.devcontainer/configure-php.sh
"$(pwd)"/.devcontainer/configure-php.sh $CONFIG_DIRECTORY

echo -e "\n-----------------------------\n"

echo -e "š© Configure XDEBUG :\n"
sudo chmod +x "$(pwd)"/.devcontainer/configure-xdebug.sh
"$(pwd)"/.devcontainer/configure-xdebug.sh $CONFIG_DIRECTORY

echo -e "\n-----------------------------\n"

echo -e "š© Configure APACHE :\n"
sudo chmod +x "$(pwd)"/.devcontainer/configure-apache.sh
"$(pwd)"/.devcontainer/configure-apache.sh $CONFIG_DIRECTORY

echo -e ""
