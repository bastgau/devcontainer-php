#!/bin/bash

echo -e ""

# VARIABLE DECLARATION

CONFIG_DIRECTORY="/workspaces/app/.config"

echo -e "🚩 Prepare ENVIRONMENT :\n"

if [ ! -d "$CONFIG_DIRECTORY" ]; then
    echo "ℹ️  Directory : $CONFIG_DIRECTORY will be created"
    mkdir $CONFIG_DIRECTORY
else
    echo "ℹ️  Nothing to prepare"
fi

echo -e "\n🎉 ENVIRONMENT preparation is finished !"
echo -e "\n-----------------------------\n"

echo -e "🚩 Configure PHP :\n"
sudo chmod +x "$(pwd)"/.devcontainer/configure-php.sh
"$(pwd)"/.devcontainer/configure-php.sh $CONFIG_DIRECTORY

echo -e "\n-----------------------------\n"

echo -e "🚩 Configure XDEBUG :\n"
sudo chmod +x "$(pwd)"/.devcontainer/configure-xdebug.sh
"$(pwd)"/.devcontainer/configure-xdebug.sh $CONFIG_DIRECTORY

echo -e "\n"
