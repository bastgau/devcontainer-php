#!/bin/bash

MODULE_NAME="no-debug-non-zts-20190902"

# TOOLS INSTALLATION

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install vim

# INSTALLATION XDEBUG

TMP_DIRECTORY="/tmp/configenv"

mkdir $TMP_DIRECTORY
cd $TMP_DIRECTORY

wget https://xdebug.org/files/xdebug-3.1.5.tgz
tar -xvzf xdebug-3.1.5.tgz
cd xdebug-3.1.5
phpize
./configure
make

sudo cp modules/xdebug.so /usr/local/lib/php/extensions/$MODULE_NAME
rm -rvf $TMP_DIRECTORY