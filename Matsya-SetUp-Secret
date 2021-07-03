#!/bin/bash

set -e

clear

RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
LBLUE='\033[1;34m'
DGRAY='\033[1;35m'
PURPLE='\033[0;35m'
RGRAY='\033[1;30m'
BOLD=$(tput bold)
NORM=$(tput sgr0)
ORANGE='\033[1;33m'

CURRENTUSER=$(whoami)

sudo mkdir -p /opt/Matsya/Repo

echo -e "${ORANGE}==============================================================================${NC}"
echo -e "${BLUE}${BOLD}\x1b[4mM${NORM}${NC}ultifaceted deploy${BLUE}${BOLD}\x1b[4mA${NORM}${NC}gnostic ${BLUE}${BOLD}\x1b[4mT${NORM}${NC}imesaving ${BLUE}${BOLD}\x1b[4mS${NORM}${NC}calable anal${BLUE}${BOLD}\x1b[4mY${NORM}${NC}tics ${BLUE}${BOLD}\x1b[4mA${NORM}${NC}malgamated ${BOLD}\x1b[30;44mPLATFORM\x1b[m${NORM}"
echo -e "${GREEN}==============================================================================${NC}"
echo ''
echo -e "\x1b[3m\x1b[4mSecret File Creation\x1b[m"
echo ''
read -p "Enter File Path > " -e -i "/opt/Matsya/Repo/AuthData" AUTH_DATA
echo "                                                                         "
if [ -f "$AUTH_DATA" ]
then
	DIFF=$((600000-500000+1))
	R=$(($(($RANDOM%$DIFF))+500000))
	RANDOMFILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
	RANDOMKEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
	RKEY1=${RANDOMKEY:0:7}
	RKEY2=${RANDOMKEY:7:8}
	RANDOMKEY="$RKEY1$R$RKEY2"	
	sudo cp $AUTH_DATA /opt/Matsya/Repo/$RANDOMFILENAME
	sudo chown $CURRENTUSER:$CURRENTUSER /opt/Matsya/Repo/$RANDOMFILENAME
	sudo chmod u=r,g=,o= /opt/Matsya/Repo/$RANDOMFILENAME
	openssl enc -a -aes-256-cbc -pbkdf2 -iter $R -in /opt/Matsya/Repo/$RANDOMFILENAME -out /opt/Matsya/Repo/".$RANDOMFILENAME" -k $RANDOMKEY
	sudo chown $CURRENTUSER:$CURRENTUSER /opt/Matsya/Repo/".$RANDOMFILENAME"
	sudo chmod u=r,g=,o= /opt/Matsya/Repo/".$RANDOMFILENAME"
	sudo rm -rf /opt/Matsya/Repo/$RANDOMFILENAME
	echo -e "${PURPLE}-----------------------${NC}"
	echo -e "${PURPLE}${BOLD}PROCESS INFO${NORM}${NC}"
	echo -e "${PURPLE}-----------------------${NC}"
	echo -e "${BOLD}ORIGINAL FILE => $AUTH_DATA${NORM} (${RED}\x1b[5m\x1b[3m\x1b[4mRECOMMENDED TO DELETE\x1b[m)${NC}"		
	echo -e "${BOLD}SECRET FILE   => /opt/Matsya/Repo/.$RANDOMFILENAME${NORM}"
	echo -e "${BOLD}SECRET KEY    => $RANDOMKEY${NORM}"	
	echo -e "${PURPLE}-----------------------${NORM}"		
	sudo rm -rf /root/.bash_history
	sudo rm -rf /home/$CURRENTUSER/.bash_history
	echo ''
else
	exit
fi

