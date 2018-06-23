#!/bin/bash
clear

#This Script will allow the user to install many different masternodes
#m4x_crypto 2018

RED='\033[0;31m'
NC='\033[0m'

echo -e "
 **************************************************
 **                                              **
 **        ${RED}M4XCRYPTO ${NC}MASTERNODE INSTALLER        **
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
#rm MNList.txt 2>/dev/null
#wget https://raw.githubusercontent.com/m4xcrypto/MasternodeInstaller/master/MNList.txt 2>/dev/null

N=0
CRYPTONAME=()
CRYPTOLINK=()
IFS=","

while read a b c; do
  CRYPTONAME[$N]=$a
  CRYPTOLINK[$N]=$b
  ((N++))
  shift
done < MNList.txt

echo -e " 
 *** ${RED}AVAILABLE MASTERNODES : ${NC}
"

#display selection menu
for (( y=0; y<$N; y++ ))
do
        echo "    $y - ${CRYPTONAME[$y]}"
done

#Read user input until this is a number
until [[ ${number} =~ ^[0-9]+$ ]]; do
        echo -e "
 ** ${RED}SELECT YOUR MASTERNODE ${NC}"
        read number
done

#get the right MN script from online serv
#wget ${CRYPTONAME[$y]}

#Run downloaded install script
bash akula.sh

echo "retour script 1"
