#!/bin/bash

CONFIG_DIRECTORY=$1
MODULE_NAME="no-debug-non-zts-20190902"

if [ -z $CONFIG_DIRECTORY ]; then
    echo "😵 Config directory must be specified as parameter. It cannot be empty."
    echo "😵 Usage: configure-xdebug <config_directory>"    
    exit 1
fi

if [ ! -d "$CONFIG_DIRECTORY" ]; then
    echo -e "ℹ️  Directory : $CONFIG_DIRECTORY will be created\n"
    mkdir $CONFIG_DIRECTORY
    NOTHING=0
fi

## PREPARE FILE XDEBUG_INI

ZEND_EXTENSION_PATH=/usr/local/lib/php/extensions/$MODULE_NAME/xdebug.so

if [ ! -f "$ZEND_EXTENSION_PATH" ]; then
    echo "😵 Xdebug extension was not found : $ZEND_EXTENSION_PATH"
    echo "😵 Please check if the xdebug installation is complete !"
    exit 1
fi

cd $CONFIG_DIRECTORY

FILE_XDEBUG_INI="$CONFIG_DIRECTORY/xdebug.ini"
FILE_XDEBUG_INI_ORIGINAL="/usr/local/etc/php/conf.d/xdebug.ini"

if [ -f "$FILE_XDEBUG_INI_ORIGINAL" ] && [ ! -h "$FILE_XDEBUG_INI_ORIGINAL" ]; then
    echo "ℹ️  Original xdebug.ini was found here : $FILE_XDEBUG_INI_ORIGINAL"
    echo "ℹ️  It will be backuped here : $FILE_XDEBUG_INI_ORIGINAL-bkp"
    sudo mv $FILE_XDEBUG_INI_ORIGINAL $FILE_XDEBUG_INI_ORIGINAL-bkp
else
    if [ -f "$FILE_XDEBUG_INI_ORIGINAL-bkp" ]; then
        echo "ℹ️  A xdebug.ini file is already backuped here : $FILE_XDEBUG_INI_ORIGINAL-bkp"
    fi
fi

if [ -f "$FILE_XDEBUG_INI" ]; then
    echo "ℹ️  User xdebug.ini file was found here : $FILE_XDEBUG_INI"
else

    echo "ℹ️  No User xdebug.ini file was found"

    # if [ -f "$FILE_XDEBUG_INI_ORIGINAL-bkp" ]; then
    #     echo "ℹ️  We will use the backuped php.ini file as template"
    #     sudo cp $FILE_XDEBUG_INI_ORIGINAL-bkp $FILE_XDEBUG_INI
    # else
    #     echo "😵 We cannot continue because no php.ini file was found as template."
    #     echo "😵 A file should be existing here : $FILE_XDEBUG_INI_ORIGINAL-bkp"
    #     exit 1
    # fi

    echo "ℹ️  We will create a new config xdebug.ini file"

    cat << EOF > $FILE_XDEBUG_INI
zend_extension=$ZEND_EXTENSION_PATH
xdebug.mode=develop,debug
xdebug.start_with_request=yes
xdebug.client_port=9000
EOF

    echo -e "\n; File created automatically at : $(date)" >> $FILE_XDEBUG_INI

fi

if [ ! -f "$FILE_XDEBUG_INI" ]; then
    echo "😵 User xdebug.ini file should be exiting at this stage"
    exit 1
fi

if [ -f "$FILE_XDEBUG_INI_ORIGINAL" ]; then
    sudo rm $FILE_XDEBUG_INI_ORIGINAL
fi

echo "ℹ️  Symbolic link is now created between $FILE_XDEBUG_INI and $FILE_XDEBUG_INI_ORIGINAL"
sudo ln -s $FILE_XDEBUG_INI $FILE_XDEBUG_INI_ORIGINAL

echo -e "\n🎉 XDEBUG configuration is finished !"