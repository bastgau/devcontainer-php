#!/bin/bash

CONFIG_DIRECTORY=$1

if [ -z $CONFIG_DIRECTORY ]; then
    echo "😵 Config directory must be specified as parameter. It cannot be empty."
    echo "😵 Usage: configure-apache <config_directory>"    
    exit 1
fi

if [ ! -d "$CONFIG_DIRECTORY" ]; then
    echo -e "ℹ️  Directory : $CONFIG_DIRECTORY will be created\n"
    mkdir $CONFIG_DIRECTORY
    NOTHING=0
fi

## PREPARE APACHE2 LOG FILES

echo -e "📁  Prepare Apache2 log files :\n"

sudo rm /var/log/apache2/access.log
sudo rm /var/log/apache2/error.log
sudo rm /var/log/apache2/other_vhosts_access.log

sudo touch /workspaces/app/logs/apache-access.log 
sudo touch /workspaces/app/logs/apache-errors.log
sudo touch /workspaces/app/logs/apache-other_vhosts_access.log

ln -s /workspaces/app/logs/apache-access.log  /var/log/apache2/access.log
ln -s /workspaces/app/logs/apache-errors.log /var/log/apache2/error.log
ln -s /workspaces/app/logs/apache-other_vhosts_access.log /var/log/apache2/other_vhosts_access.log

echo -e "ℹ️  Directory and files are created"

## PREPARE SITES-AVAILABLE CONFIGURATION

echo -e "\n📁  Prepare the sites-available configuration for Apache2 :\n"

FILE_SITE_APACHE_CONF_ORIGINAL="/etc/apache2/sites-available/000-default.conf"

if [ -f "$FILE_SITE_APACHE_CONF_ORIGINAL" ] && [ ! -h "$FILE_SITE_APACHE_CONF_ORIGINAL" ]; then
    echo -e "ℹ️  Original sites-available configuration was found here : $FILE_SITE_APACHE_CONF_ORIGINAL"
    echo -e "ℹ️  It will be backuped here : $FILE_SITE_APACHE_CONF_ORIGINAL-bkp"
    sudo mv $FILE_SITE_APACHE_CONF_ORIGINAL $FILE_SITE_APACHE_CONF_ORIGINAL-bkp
else
    if [ -f "$FILE_SITE_APACHE_CONF_ORIGINAL-bkp" ]; then
        echo -e "ℹ️  A sites-available configuration is already backuped here : $FILE_SITE_APACHE_CONF_ORIGINAL-bkp"
    fi
fi

FILE_SITE_APACHE_CONF="$CONFIG_DIRECTORY/apache-sites-available.conf"

if [ -f "$FILE_SITE_APACHE_CONF" ]; then
    echo -e "ℹ️  User sites-available configuration was found here : $FILE_SITE_APACHE_CONF"
else

    echo -e "ℹ️  No sites-available configuration was found"
    echo -e "ℹ️  We will create a sites-available configuration"

    cat << EOF >> $FILE_SITE_APACHE_CONF
<VirtualHost *:8080>
    # The ServerName directive sets the request scheme, hostname and port that
    # the server uses to identify itself. This is used when creating
    # redirection URLs. In the context of virtual hosts, the ServerName
    # specifies what hostname must appear in the request's Host: header to
    # match this virtual host. For the default virtual host (this file) this
    # value is not decisive as it is used as a last resort host regardless.
    # However, you must set it for any further virtual host explicitly.

    ServerName localhost
    ServerAdmin webmaster@localhost
    DocumentRoot /workspaces/app/www

    <Directory /workspaces/app/www>
        Options FollowSymLinks Indexes
        AllowOverride All
        Require all granted
    </Directory>

    # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
    # error, crit, alert, emerg.
    # It is also possible to configure the loglevel for particular
    # modules, e.g.
    #LogLevel info ssl:warn

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    # For most configuration files from conf-available/, which are
    # enabled or disabled at a global level, it is possible to
    # include a line for only one particular virtual host. For example the
    # following line enables the CGI configuration for this host only
    # after it has been globally disabled with "a2disconf".
    #Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF

    echo -e "\n# File created automatically at : $(date)" >> $FILE_SITE_APACHE_CONF

fi

if [ -f "$FILE_SITE_APACHE_CONF_ORIGINAL" ]; then
    sudo rm $FILE_SITE_APACHE_CONF_ORIGINAL
fi

echo -e "ℹ️  Symbolic link is now created between $FILE_SITE_APACHE_CONF and $FILE_SITE_APACHE_CONF_ORIGINAL"
sudo ln -s $FILE_SITE_APACHE_CONF $FILE_SITE_APACHE_CONF_ORIGINAL

## PREPARE APACHE2 CONFIGURATION

echo -e "\n📁  Prepare the Apache2 configuration :\n"

FILE_APACHE_CONF_ORIGINAL="/etc/apache2/apache2.conf"

if [ -f "$FILE_APACHE_CONF_ORIGINAL" ] && [ ! -h "$FILE_APACHE_CONF_ORIGINAL" ]; then
    echo -e "ℹ️  Original Apache2 configuration was found here : $FILE_APACHE_CONF_ORIGINAL"
    echo -e "ℹ️  It will be backuped here : $FILE_APACHE_CONF_ORIGINAL-bkp"
    sudo mv $FILE_APACHE_CONF_ORIGINAL $FILE_APACHE_CONF_ORIGINAL-bkp
else
    if [ -f "$FILE_APACHE_CONF_ORIGINAL-bkp" ]; then
        echo -e "ℹ️  An Apache2 configuration is already backuped here : $FILE_APACHE_CONF_ORIGINAL-bkp"
    fi
fi

FILE_APACHE_CONF="$CONFIG_DIRECTORY/apache2.conf"

if [ -f "$FILE_APACHE_CONF" ]; then
    echo -e "ℹ️  User Apache2 configuration was found here : $FILE_APACHE_CONF"
else

    if [ -f "$FILE_APACHE_CONF_ORIGINAL-bkp" ]; then
        echo -e "ℹ️  We will use the backuped Apache2 configuration as template"
        sudo cp $FILE_APACHE_CONF_ORIGINAL-bkp $FILE_APACHE_CONF
    else
        echo "😵 We cannot continue because no Apache2 configuration was found as template."
        echo "😵 A file should be existing here : $FILE_APACHE_CONF_ORIGINAL-bkp"
        exit 1
    fi

    echo -e "ℹ️  We add a few attributes to the new Apache2 configuration"

    cat << EOF >> $FILE_APACHE_CONF
ServerName 127.0.0.1
EOF

    echo -e "\n# File created automatically at : $(date)" >> $FILE_APACHE_CONF

fi

if [ -f "$FILE_APACHE_CONF_ORIGINAL" ]; then
    sudo rm $FILE_APACHE_CONF_ORIGINAL
fi

echo -e "ℹ️  Symbolic link is now created between $FILE_APACHE_CONF and $FILE_APACHE_CONF_ORIGINAL"
sudo ln -s $FILE_APACHE_CONF $FILE_APACHE_CONF_ORIGINAL

echo -e "ℹ️  We finalize the Apache2 configuration and restart the service :\n"
sudo a2enmod rewrite && sudo /etc/init.d/apache2 restart

echo -e "\n🎉 APACHE configuration is finished !"