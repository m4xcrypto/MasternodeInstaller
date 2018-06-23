#!/bin/bash

#Define coin specific var
COIN_NAME='Olympic'
COIN_DOWNLOAD_URL='https://github.com/OlympicCoinTeam/OlympicCoin/releases/download/v4.1.0.2/Olympicd'
COIN_PORT=26667
RPC_PORT=33000
CONF_FILE='Olympic.conf'
DATA_FOLDER='/root/.Olympic'
COIN_DAEMON='Olympicd'
#COIN_CLI='akula-cli'
BLOCKS_API='http://explorer.olympcoin.io/api/getblockcount'

#Define global var (same for all masternodes)
BIN_PATH='/usr/local/bin/'
SERV_IP=$(curl -s4 api.ipify.org)


#Check previous installation
function check_already_installed() {
	#To be done
}


#Install packages for many types of masternodes
function install_packages() {
	#upgrade system
	apt-get -qq update
	apt-get -qq upgrade
	apt-get -qq autoremove
	
	#add bitcoin repository
	add-apt-repository -y ppa:bitcoin/bitcoin > /dev/null
	apt-get -qq update > /dev/null
	
	#install utilities
	apt-get -y install unzip > /dev/null
	apt-get -y install make > /dev/null
	apt-get -y install sudo > /dev/null
	apt-get -y install automake > /dev/null
	apt-get -y install autoconf > /dev/null
	apt-get -y install autogen > /dev/null
	apt-get -y install git > /dev/null
	apt-get -y install htop > /dev/null
	apt-get -y install wget > /dev/null
	apt-get -y install curl > /dev/null
	apt-get -y install ufw > /dev/null
	apt-get -y install systemd > /dev/null
	apt-get -y install aptitude > /dev/null
	apt-get -y install software-properties-common > /dev/null
	apt-get -y install build-essential > /dev/null
	apt-get -y install bsdmainutils > /dev/null
	apt-get -y install pkg-config > /dev/null

	#install lib packages	
	apt-get -y install libtool > /dev/null
	apt-get -y install libssl-dev > /dev/null
	apt-get -y install libboost-all-dev > /dev/null
	apt-get -y install libboost-dev > /dev/null
	apt-get -y install libboost-chrono-dev > /dev/null
	apt-get -y install libboost-filesystem-dev > /dev/null
	apt-get -y install libboost-program-options-dev > /dev/null
	apt-get -y install libboost-system-dev > /dev/null
	apt-get -y install libboost-test-dev > /dev/null
	apt-get -y install libboost-thread-dev > /dev/null
	apt-get -y install libdb++-dev > /dev/null
	apt-get -y install libdb4.8-dev > /dev/null	
	apt-get -y install libdb4.8++-dev > /dev/null
	apt-get -y install libdb5.3++ > /dev/null
	apt-get -y install libminiupnpc-dev > /dev/null
	apt-get -y install libgmp-dev > /dev/null
	apt-get -y install libgmp3-dev > /dev/null
	apt-get -y install libzmq3-dev > /dev/null
	apt-get -y install libzmq5 > /dev/null
	apt-get -y install libevent-dev > /dev/null
	apt-get -y install libcrypto++-dev > /dev/null
	apt-get -y install libqrencode-dev > /dev/null
	apt-get -y install libminiupnpc-dev > /dev/null	
	apt-get -y install libevent-dev > /dev/null	
	
	aptitude -y -q install fail2ban
	service fail2ban restart
}

function download_mn() {
	mkdir $COIN_NAME
	cd $COIN_NAME
	wget $COIN_DOWNLOAD_URL
	#tar xvzf $FILE_NAME -C $BIN_PATH
	chmod +x $COIN_DAEMON
	cp Olympicd /usr/local/bin
	#chmod +x $BIN_PATH$COIN_DAEMON
	#chmod +x $BIN_PATH$COIN_CLI
	#chmod +x ./$COIN_DAEMON
	#chmod +x ./$COIN_CLI
}

function conf_mn() {
	#Unblock MN port
	ufw allow ssh
	ufw allow $COIN_PORT/tcp
	yes | ufw enable

	#Read MN privkey
	while [[ -z "$MN_KEY" ]]
	do
		echo -e "Enter your ${RED}$COIN_NAME Masternode Private Key${NC}"
		read -e MN_KEY
	done
	
	#Create and fill $COIN.conf file
	mkdir $DATA_FOLDER > /dev/null
	RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
	RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	cat << EOF > $DATA_FOLDER/$CONF_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
#rpcport=$RPC_PORT
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
port=$COIN_PORT
logintimestamps=1
maxconnections=256
#bind=$SERV_IP
masternode=1
masternodeaddr=$SERV_IP:$COIN_PORT
masternodeprivkey=$MN_KEY
EOF

}

function launch_mn() {
	#setup systemd
	cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
Type=forking
User=root
Group=root

ExecStart=$BIN_PATH$COIN_DAEMON -daemon -conf=$DATA_FOLDER/$CONFIG_FILE -datadir=$DATA_FOLDER
ExecStop=-$BIN_PATH$COIN_DAEMON -conf=$DATA_FOLDER/$CONFIG_FILE -datadir=$DATA_FOLDER stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF
	
	#launch_mn
	systemctl daemon-reload
	sleep 5
	systemctl enable $COIN_NAME.service
	systemctl start $COIN_NAME.service
	
	#Wait until chain is sync
	SyncedBlocks=0
	TotalBlocks=$(curl $BLOCKS_API 2>/dev/null)
	
	until [ $SyncedBlocks -eq $TotalBlocks ] ; do
		SyncedBlocks=$($COIN_CLI getblockcount)
		TotalBlocks=$(curl $BLOCKS_API 2>/dev/null)
		clear
		echo -e "
 **************************************************
 **                                              **
 **               SYNC IN PROGRESS               **
 **                                              **
 **                 $SyncedBlocks / $TotalBlocks                 **
 **                                              **
 **************************************************
"
        sleep 5
    done

	
	#Wait remonte activation
	echo -e "
 **************************************************
 **                                              **
 **                 BLOCKS SYNCED                **
 **                                              **
 **    GO TO YOUR WALLET AND START MASTERNODE    **
 **                                              **
 **************************************************
"
	until $COIN_CLI masternode status 2>/dev/null | grep 'successfully' > /dev/null; do
		echo "MN not started"
		sleep 5
	done
	
	echo -e "
 **************************************************
 **                                              **
 **              CONGRATULATIONS !               **
 **                                              **
 **       YOUR MASTERNODE IS NOW RUNNING         **
 **                                              **
 **************************************************
"
	sleep 5
}

#MAIN SCRIPT
check_already_installed
install_packages
download_mn
conf_mn
launch_mn