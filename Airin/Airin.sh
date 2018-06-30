#!/bin/bash

#Define coin specific var
COIN_NAME='AIRIN'
COIN_DOWNLOAD_URL='https://github.com/airincoin/airin/releases/download/2.1.2.0/ubuntu_16.04_daemon.tar.gz'
FILE_NAME='ubuntu_16.04_daemon.tar.gz'
#COIN_GIT=''
COIN_PORT=18821
COIN_RPC=18822
CONF_FILE='airin.conf'
DATA_FOLDER='/root/.airin'
COIN_DAEMON='airind'
COIN_CLI='airin-cli'
BLOCKS_API='http://explore.airin.cc/api/getblockcount'

#Define global var (same for all masternodes)
BIN_PATH='/usr/local/bin/'
SERV_IP=$(curl -s4 api.ipify.org)

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
MAGENTA='\033[00;35m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
WHITE='\033[01;37m'


#Check previous installation
function check_already_installed() {
	if [ pgrep $COIN_DAEMON -gt 0 ]
	then
		$COIN_CLI stop
		sleep 2
		if -e [ $BIN_PATH$COIN_DAEMON ]
		then
			rm $BIN_PATH$COIN_DAEMON
		fi
		if -e [ $BIN_PATH$COIN_CLI ]
		then
			rm $BIN_PATH$COIN_CLI
		fi
	fi
}


#Install packages for many types of masternodes
function install_packages() {

	echo -e " 
 *** ${MAGENTA}PREPARING SYSTEM ${NC}
"

	#upgrade system
	apt-get -qq update
	apt-get -qq upgrade
	apt-get -qq dist-upgrade
	apt-get -qq autoremove
	
	#add bitcoin repository
	add-apt-repository -y ppa:bitcoin/bitcoin > /dev/null
	apt-get -qq update > /dev/null
		
	#install utilities
	apt-get -y install wget > /dev/null
	apt-get -y install make > /dev/null
	apt-get -y install automake > /dev/null
	apt-get -y install autoconf > /dev/null
	apt-get -y install libtool > /dev/null
	apt-get -y install build-essential > /dev/null
	apt-get -y install autotools-dev > /dev/null
	apt-get -y install python-virtualenv
	apt-get -y pwgen > /dev/null
	apt-get -y virtualenv > /dev/null
	apt-get -y install pkg-config > /dev/null
	apt-get -y install libssl-dev > /dev/null
	apt-get -y install libevent-dev > /dev/null
	apt-get -y install bsdmainutils > /dev/null
	apt-get -y install software-properties-common > /dev/null
	apt-get -y install libboost-all-dev > /dev/null
	apt-get -y install libminiupnpc-dev > /dev/null
	apt-get -y install libdb4.8-dev > /dev/null	
	apt-get -y install libdb4.8++-dev > /dev/null
	apt-get -y install nano > /dev/null
	apt-get -y install git > /dev/null
	apt-get -y install htop > /dev/null	
	apt-get -y install pkg-config > /dev/null

}

function download_mn() {

	echo -e " 
 *** ${MAGENTA}DOWNLOADING HOT WALLET ${NC}
"
	mkdir $COIN_NAME > /dev/null
	cd $COIN_NAME > /dev/null
	wget $COIN_DOWNLOAD_URL > /dev/null
	tar -xvzf $FILE_NAME -C $BIN_PATH > /dev/null
	chmod +x $BIN_PATH$COIN_DAEMON > /dev/null
	chmod +x $BIN_PATH$COIN_CLI > /dev/null
	cd .. > /dev/null
	rm -rf $COIN_NAME > /dev/null
}

function conf_mn() {
	echo -e " 
 *** ${MAGENTA}SETTING UP THE MASTERNODE ${NC}
"

	#Unblock MN port
	ufw allow ssh > /dev/null
	ufw allow $COIN_PORT/tcp > /dev/null
	ufw allow $COIN_RPC/tcp > /dev/null

	#Read MN privkey
	while [[ -z "$MN_KEY" ]]
	do
		echo -e "
 *** PLEASE INPUT YOUR ${RED}$COIN_NAME ${NC}MASTERNODE PRIVATE KEY
"
		read -e MN_KEY
	done
	
	#Create and fill $COIN.conf file
	mkdir $DATA_FOLDER
	RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
	RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)	
	
	cat << EOF > $DATA_FOLDER/$CONF_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcport=$COIN_RPC
port=$COIN_PORT
externalip=$SERV_IP:$COIN_PORT
listen=1
maxconnections=250
daemon=1
masternode=1
masternodeprivkey=$MN_KEY
addnode=209.250.254.137:18821
addnode=95.179.138.3:18821
addnode=209.250.248.165:18821
addnode=95.179.141.183:18821
addnode=45.76.43.174:18821
addnode=188.166.43.58:18821
addnode=138.68.54.190:18821
addnode=85.119.150.141:18821
addnode=85.119.150.140:18821
addnode=95.213.204.95:18821
addnode=85.119.150.206:18821
addnode=95.213.235.179:18821
addnode=95.213.204.136:18821
EOF

}

function launch_mn() {
	echo -e " 
 *** ${MAGENTA}STARTING $COIN_NAME DAEMON ${NC}
"
	#launch_mn
	$COIN_DAEMON -daemon
	sleep 3
}

function sync_blocks() {
	#Wait until chain is sync
	SyncedBlocks=0
	TotalBlocks=$(curl $BLOCKS_API 2>/dev/null)
	
	until [ $SyncedBlocks -eq $TotalBlocks ] ; do
		TotalBlocks=$(curl $BLOCKS_API 2>/dev/null)
		SyncedBlocks=$($COIN_CLI getblockcount)
		clear
		echo -e " 
 *** ${MAGENTA}BLOCKCHAIN SYNCHRONIZATION IN PROGRESS : ${NC}$SyncedBlocks / $TotalBlocks
"
        sleep 3
    done
}

function wait_mn_activation() {
	#Wait remonte activation
	clear
	echo -e " 
 *** WAITING ${RED}REMOTE ACTIVATION : ${NC}GO TO YOUR WALLET AND START MASTERNODE
"
	until $COIN_CLI masternode status 2>/dev/null | grep 'successfully' > /dev/null; do
		sleep 3
	done
	
	echo -e " 
 *** ${GREEN}CONGRATULATIONS ! YOUR MASTERNODE IS NOW RUNNING
"
}


#MAIN SCRIPT
#check_already_installed
install_packages
download_mn
conf_mn
launch_mn
sync_blocks
wait_mn_activation




