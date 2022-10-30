
#!/bin/bash

CONFIG_DIRECTORY=$1

if [ -z $CONFIG_DIRECTORY ]; then
    echo "😵 Config directory must be specified as parameter. It cannot be empty."
    echo "😵 Usage: configure-xdebug <config_directory>"    
    exit 1
fi

## PREPARE FILE PHP.INI

cd $CONFIG_DIRECTORY

FILE_PHP_INI="$CONFIG_DIRECTORY/php.ini-development"
FILE_PHP_INI_ORIGINAL="/usr/local/etc/php/php.ini-development"

if [ -f "$FILE_PHP_INI_ORIGINAL" ] && [ ! -h "$FILE_PHP_INI_ORIGINAL" ]; then
    echo "ℹ️  Original php.ini was found here : $FILE_PHP_INI_ORIGINAL"
    echo "ℹ️  It will be backuped here : $FILE_PHP_INI_ORIGINAL-bkp"
    sudo mv $FILE_PHP_INI_ORIGINAL $FILE_PHP_INI_ORIGINAL-bkp
else
    if [ -f "$FILE_PHP_INI_ORIGINAL-bkp" ]; then
        echo "ℹ️  A php.ini file is already backuped here : $FILE_PHP_INI_ORIGINAL-bkp"
    fi
fi

if [ -f "$FILE_PHP_INI" ]; then
    echo "ℹ️  User php.ini file was found here : $FILE_PHP_INI"
else 
    echo "ℹ️  No user php.ini file was found"

    if [ -f "$FILE_PHP_INI_ORIGINAL-bkp" ]; then
        echo "ℹ️  We will use the backuped php.ini file as template"
        sudo cp $FILE_PHP_INI_ORIGINAL-bkp $FILE_PHP_INI
    else
        echo "😵 We cannot continue because no php.ini file was found as template."
        echo "😵 A file should be existing here : $FILE_PHP_INI_ORIGINAL-bkp"
        exit 1
    fi

    echo "ℹ️  We add a few attributes to the new php.ini file"

    cat << EOF >> $FILE_PHP_INI
zend_extension=xdebug
EOF

fi

if [ ! -f "$FILE_PHP_INI" ]; then
    echo "😵 User php.ini file should be exiting at this stage"
    exit 1
fi

FILE_PHP_INI_FINAL="/usr/local/etc/php/php.ini"

if [ -f "$FILE_PHP_INI_FINAL" ]; then
    sudo rm $FILE_PHP_INI_FINAL
fi

echo "ℹ️  Symbolic link is now created between $FILE_PHP_INI and $FILE_PHP_INI_FINAL"
sudo ln -s $FILE_PHP_INI $FILE_PHP_INI_FINAL

echo -e "\n🎉 PHP configuration is finished !"