#!/bin/bash

#Define coin specific var
COIN_NAME='Pyro'
COIN_DOWNLOAD_URL='https://github.com/m4xcrypto/MasternodeInstaller/raw/master/Pyro/Release/pyro.tar.gz'
FILE_NAME='pyro.tar.gz'
COIN_GIT='https://github.com/pyrocoindev/pyro'
COIN_PORT=9669
CONF_FILE='pyro.conf'
DATA_FOLDER='/root/.pyrocore'
COIN_DAEMON='pyrod'
COIN_CLI='pyro-cli'
BLOCKS_API='http://pyro.evo.today/api/getblockcount'

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
		
	#install utilities
	apt-get -y install nano > /dev/null
	apt-get -y install git > /dev/null
	apt-get -y install htop > /dev/null	
	apt-get -y install software-properties-common > /dev/null
	apt-get -y install libtool > /dev/null
	apt-get -y install build-essential > /dev/null
	apt-get -y install pkg-config > /dev/null
	apt-get -y install autotools-dev > /dev/null
	apt-get -y install libssl-dev > /dev/null
	apt-get -y install libboost-all-dev > /dev/null
	apt-get -y install libevent-dev > /dev/null
	apt-get -y install libminiupnpc-dev > /dev/null
	apt-get -y install automake > /dev/null
	apt-get -y install autoconf > /dev/null
	
	#add bitcoin repository
	add-apt-repository -y ppa:bitcoin/bitcoin > /dev/null
	apt-get -qq update > /dev/null
	apt-get -y install libdb4.8-dev > /dev/null	
	apt-get -y install libdb4.8++-dev > /dev/null
	apt-get -y install bsdmainutils > /dev/null
}

function download_mn() {

	echo -e " 
 *** ${MAGENTA}DOWNLOADING HOT WALLET ${NC}
"
	mkdir $COIN_NAME
	cd $COIN_NAME
	wget $COIN_DOWNLOAD_URL
	tar xvzf $FILE_NAME -C $BIN_PATH
	chmod +x $BIN_PATH$COIN_DAEMON
	chmod +x $BIN_PATH$COIN_CLI
	cd ..
	rm -rf $COIN_NAME	
}

function clone_git() {
	git clone $COIN_GIT
	cd pyro
	./autogen.sh
	./configure
	make
	cd src
}

function conf_mn() {
	echo -e " 
 *** ${MAGENTA}SETTING UP THE MASTERNODE ${NC}
"

	#Unblock MN port
	ufw allow ssh
	ufw allow $COIN_PORT/tcp

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
masternode=1
externalip=$SERV_IP:$COIN_PORT
masternodeprivkey=$MN_KEY
addnode=167.99.232.88:9669
addnode=178.32.45.75:12823
addnode=188.166.37.145:42013
addnode=178.32.46.228:53972
addnode=207.148.71.157:45924
addnode=167.88.168.254:46764
addnode=104.227.34.207:50048
addnode=27.145.42.41:24746
addnode=206.189.29.212:34676
addnode=107.152.213.98:55101
addnode=46.4.103.28:53880
addnode=80.211.190.117:44000
addnode=151.106.30.194:63822
addnode=192.154.213.109:52231
addnode=144.76.186.22:48456
addnode=151.106.14.50:64817
addnode=167.114.79.194:51230
addnode=45.76.144.228:45602
addnode=138.128.98.98:54765
addnode=139.99.122.145:43192
addnode=171.241.1.132:53954
addnode=104.227.146.245:59635
addnode=174.76.16.220:52881
addnode=95.71.126.82:61713
addnode=122.10.88.206:58038
addnode=109.173.112.224:59261
addnode=104.168.99.183:50733
addnode=185.235.128.63:61081
addnode=95.179.129.130:50854
addnode=149.28.60.79:54154
addnode=45.76.53.0:45482
addnode=78.28.212.254:53518
addnode=88.198.140.189:42814
addnode=118.89.149.16:49497
addnode=144.202.24.15:58584
addnode=195.201.134.19:9669
addnode=35.184.127.72:9669
addnode=95.171.6.105:51851
addnode=188.166.244.40:9669
addnode=88.164.70.252:50325
addnode=185.39.195.183:48652
addnode=109.195.179.12:59297
addnode=54.36.251.151:56113
addnode=77.222.139.249:54565
addnode=209.250.234.18:9669
addnode=45.76.248.193:9669
addnode=73.51.208.135:58274
addnode=176.119.28.77:9669
addnode=5.101.115.234:9669
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
check_already_installed
install_packages
download_mn
conf_mn
launch_mn
sync_blocks
wait_mn_activation




