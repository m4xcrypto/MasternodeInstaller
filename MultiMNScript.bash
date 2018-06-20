#!/bin/bash
clear

#This Script will allow the user to install many different masternodes
#m4x_crypto 2018

echo "
 **************************************************
 **                                              **
 **        M4XCRYPTO MASTERNODE INSTALLER        **
 **                                              **
 **            for Ubuntu 16.04 only             **
 **                                              **
 **************************************************
"

#run basic checks (root, ram, free space)

if [ "$(id -u)" != "0" ]; then
   echo "You need to be root to run this script." 1>&2
   exit 1
fi

if [[ `free -m | awk '/^Mem:/{print $2}'` -lt 900 ]]; then
  echo "This installation requires at least 1GB of RAM.";
  exit 1
fi

if [[ `df -k --output=avail / | tail -n1` -lt 10485760 ]]; then
  echo "This installation requires at least 10GB of free disk space.";
  exit 1
fi

#read online the list of supported projects
wget https://github.com/m4xcrypto/MasternodeInstaller/blob/master/MNList.txt

export IFS=";"
cat list | while read a b; do echo "$a:$b"; done




