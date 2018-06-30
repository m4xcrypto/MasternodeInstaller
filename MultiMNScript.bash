#!/bin/bash
clear

#This Script will allow the user to install many different masternodes
#m4x_crypto 2018
#bash <(curl https://raw.githubusercontent.com/m4xcrypto/MasternodeInstaller/master/MultiMNScript.bash)

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
MAGENTA='\033[00;35m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
WHITE='\033[01;37m'

echo -e "
 *** ${CYAN}WELCOME TO M4XCRYPTO MULTI MASTERNODES INSTALLER${NC}
 *** for Ubuntu ${MAGENTA}16.04 ${NC}only
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
rm MNList 2>/dev/null
wget https://raw.githubusercontent.com/m4xcrypto/MasternodeInstaller/master/MNList 2>/dev/null

N=0
CRYPTONAME=()
CRYPTOLINK=()
IFS=","

while read a b c; do
  CRYPTONAME[$N]=$a
  CRYPTOLINK[$N]=$b
  ((N++))
  shift
done < MNList

echo -e " *** ${MAGENTA}AVAILABLE MASTERNODES : ${NC}
"

#display selection menu
for (( y=0; y<$N; y++ ))
do
        echo "     $y - ${CRYPTONAME[$y]}"
done

#Read user input until this is a number
until [[ ${number} =~ ^[0-9]+$ ]] && [[ $number -lt $N ]]; do
        echo -e "
 *** ${MAGENTA}SELECT YOUR MASTERNODE : ${NC}INPUT THE MASTERNODE ID NUMBER"
        read number
done

#get the right MN script from online serv
FILE_NAME=$(echo ${CRYPTOLINK[$number]} | awk -F'/' '{print $NF}')
rm $FILE_NAME 2>/dev/null
wget ${CRYPTOLINK[$number]} 2>/dev/null
bash $FILE_NAME
