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
DoubleQuotes='"'
NoQuotes=''

echo -e "${ORANGE}==============================================================================${NC}"
echo -e "${BLUE}${BOLD}\x1b[4mM${NORM}${NC}ultifaceted deploy${BLUE}${BOLD}\x1b[4mA${NORM}${NC}gnostic ${BLUE}${BOLD}\x1b[4mT${NORM}${NC}imesaving ${BLUE}${BOLD}\x1b[4mS${NORM}${NC}calable anal${BLUE}${BOLD}\x1b[4mY${NORM}${NC}tics ${BLUE}${BOLD}\x1b[4mA${NORM}${NC}malgamated ${BOLD}\x1b[30;44mPLATFORM\x1b[m${NORM}"
echo -e "${GREEN}==============================================================================${NC}"
echo ''
echo -e "\x1b[3m\x1b[4mVAGRANT VIRTUALBOX MULTINODE\x1b[m"
echo ''
read -p "Enter File Path For Settings > " -e -i "/opt/Matsya/Repo/Matsya.config" NODES_JSON
echo "                                                                         "

BASE=$(jq '.VagVBoxMN.Cluster.Terminal[0].BaseLocation' $NODES_JSON)
BASE="${BASE//$DoubleQuotes/$NoQuotes}"
sudo mkdir -p $BASE/VagVBoxMN
sudo mkdir -p $BASE/Repo
ISFA="$BASE/Repo/KLM15_v1_1_0.box"
VBOXCHOICE="AUTO"
if [ -f "$ISFA" ]
then
	VBOXCHOICE="MANUAL"
else
	echo "
==============================================================================

*Vagrant VirtualBox Missing...
--------
OPTION 1
--------
*Download From Here => https://bit.ly/MatsyaKLM15VagVBox
   * Copy To $BASE/Repo
   * Rename To KLM15_v1_1_0.box
--------
OPTION 2
-------- 
*Automatic Download & Configuration  

==============================================================================
"
	read -p "Enter OPTION 1 OR 2 > " -e -i "2" USERCHOICE
	echo ''
	if [ $USERCHOICE == "1" ] || [ $USERCHOICE == "1" ] ; then
		echo "Exiting...Download & Execute Again."
		echo ''
		exit
	else
		WGET="/usr/bin/wget"
		$WGET -q --tries=20 --timeout=10 http://www.google.com -O /tmp/google.idx &> /dev/null
		if [ ! -s /tmp/google.idx ]
		then
			echo "INTERNET NOT CONNECTED"
			echo ''
			exit
		fi
	fi
fi

CLUSTERNAME=$(jq '.VagVBoxMN.Cluster.Info[0].Name' $NODES_JSON)
CLUSTERNAME="${CLUSTERNAME//$DoubleQuotes/$NoQuotes}"
if [ "$CLUSTERNAME" == "" ] || [ "$CLUSTERNAME" == "" ] ; then
UUID=$(uuidgen)
UUIDREAL=${UUID:1:6}
CLUSTERNAME=$UUIDREAL
fi

echo "==============================================================================

*To Avoid Conflict Later...Open Another Terminal & Execute

   * sudo vagrant global-status --prune
   * sudo vagrant box list

If '$CLUSTERNAME' Appears On Above Commands,Execute

   * sudo $BASE/matsya-vagvbox-mn-$CLUSTERNAME-kill.sh      
     
==============================================================================
"
echo -e "Enter Choice => { (${GREEN}${BOLD}\x1b[4mC${NORM}${NC})onfirm (${RED}${BOLD}\x1b[4mA${NORM}${NC})bort (${YELLOW}${BOLD}\x1b[4mP${NORM}${NC})roceed } c/a/p"
read -p "> " -e -i "a" CONFIRMPROCEED	
echo ""
if [ $CONFIRMPROCEED == "p" ] || [ $CONFIRMPROCEED == "P" ] ; then
	sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-kill.sh	
	CONFIRMPROCEED="C"
fi
if [ $CONFIRMPROCEED == "c" ] || [ $CONFIRMPROCEED == "C" ] ; then
	echo "=============================================================================="
	echo ''
	AUTHMODE=$(jq '.VagVBoxMN.Cluster.Terminal[0].AuthMode' $NODES_JSON)
	AUTHMODE="${AUTHMODE//$DoubleQuotes/$NoQuotes}"
	
	TerminalsCount=$(jq '.VagVBoxMN.Cluster.Terminals | length' $NODES_JSON)

	GLOBALUSERNAME=$(jq '.VagVBoxMN.Cluster.Terminal[0].UserName' $NODES_JSON)
	GLOBALUSERNAME="${GLOBALUSERNAME//$DoubleQuotes/$NoQuotes}"
	
	GLOBALSSHPORT=$(jq '.VagVBoxMN.Cluster.Terminal[0].SSHPort' $NODES_JSON)
	GLOBALSSHPORT="${GLOBALSSHPORT//$DoubleQuotes/$NoQuotes}"	

	GLOBALOS=$(jq '.VagVBoxMN.Cluster.Terminal[0].OS' $NODES_JSON)
	GLOBALOS="${GLOBALOS//$DoubleQuotes/$NoQuotes}"
	
	FINAL_BEFORE_CONNECT_TERMINAL_LIST=()
	FINAL_TERMINAL_LIST=()
						
	for((j=0;j<$TerminalsCount;j++))
	do
		Terminal=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].HostName' $NODES_JSON)
		Terminal="${Terminal//$DoubleQuotes/$NoQuotes}"
		TerminalIP=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].IPAddress' $NODES_JSON)
		TerminalIP="${TerminalIP//$DoubleQuotes/$NoQuotes}"
		TerminalUserName=""
		TerminalSSHPort=""
		TerminalTheRqOS=""
		TerminalTheRqBase=""	
		CHECKIFTOOMIT=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
		CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
		if [ $CHECKIFTOOMIT == "null" ] || [ $CHECKIFTOOMIT == "null" ] ; then			
			CHECKIFUSERNAMEMISSING=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].UserName?' $NODES_JSON)
			CHECKIFUSERNAMEMISSING="${CHECKIFUSERNAMEMISSING//$DoubleQuotes/$NoQuotes}"
			if [ "$CHECKIFUSERNAMEMISSING" == "null" ] || [ "$CHECKIFUSERNAMEMISSING" = "" ] ; then
				if [ "$GLOBALUSERNAME" == "" ] || [ "$GLOBALUSERNAME" == "" ] ; then			
					echo '-----------------------'					
					echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'UserName' Missing In '$NODES_JSON' For Terminal => $Terminal ($TerminalIP)"
					echo '-----------------------'
					echo ''
					exit
				else
					TerminalUserName="$GLOBALUSERNAME"
				fi
			else
				TerminalUserName="$CHECKIFUSERNAMEMISSING"				
			fi
			
			CHECKIFSSHPORTMISSING=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].SSHPort?' $NODES_JSON)
			CHECKIFSSHPORTMISSING="${CHECKIFSSHPORTMISSING//$DoubleQuotes/$NoQuotes}"
			if [ "$CHECKIFSSHPORTMISSING" == "null" ] || [ "$CHECKIFSSHPORTMISSING" = "" ] ; then
				if [ "$GLOBALSSHPORT" == "" ] || [ "$GLOBALSSHPORT" == "" ] ; then			
					echo '-----------------------'					
					echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'SSHPort' Missing In '$NODES_JSON' For Terminal => $Terminal ($TerminalIP)"
					echo '-----------------------'
					echo ''
					exit
				else
					TerminalSSHPort="$GLOBALSSHPORT"
				fi
			else
				TerminalSSHPort="$CHECKIFSSHPORTMISSING"							
			fi
			
			CHECKIFOSMISSING=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].OS?' $NODES_JSON)
			CHECKIFOSMISSING="${CHECKIFOSMISSING//$DoubleQuotes/$NoQuotes}"
			if [ "$CHECKIFOSMISSING" == "null" ] || [ "$CHECKIFOSMISSING" = "" ] ; then
				if [ "$GLOBALOS" == "" ] || [ "$GLOBALOS" == "" ] ; then			
					echo '-----------------------'					
					echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'OS' Missing In '$NODES_JSON' For Terminal => $Terminal ($TerminalIP)"
					echo '-----------------------'
					echo ''
					exit
				else
					TerminalTheRqOS="$GLOBALOS"
				fi
			else
				TerminalTheRqOS="$CHECKIFOSMISSING"							
			fi
			
			CHECKIFBASELOCATIONMISSING=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].BaseLocation?' $NODES_JSON)
			CHECKIFBASELOCATIONMISSING="${CHECKIFBASELOCATIONMISSING//$DoubleQuotes/$NoQuotes}"
			if [ "$CHECKIFBASELOCATIONMISSING" == "null" ] || [ "$CHECKIFBASELOCATIONMISSING" = "" ] ; then
				if [ "$BASE" == "" ] || [ "$BASE" == "" ] ; then			
					echo '-----------------------'					
					echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'BaseLocation' Missing In '$NODES_JSON' For Terminal => $Terminal ($TerminalIP)"
					echo '-----------------------'
					echo ''
					exit
				else
					TerminalTheRqBase="$BASE"
				fi
			else
				TerminalTheRqBase="$CHECKIFBASELOCATIONMISSING"							
			fi						
			
			FINAL_BEFORE_CONNECT_TERMINAL_LIST+=("$Terminal├$TerminalIP├$TerminalUserName├$TerminalSSHPort├$TerminalTheRqOS├$TerminalTheRqBase")																			
		fi
	done
				
	GLOBALPASSWORD=""		
	if [ $AUTHMODE == "PASSWORD" ] || [ $AUTHMODE == "PASSWORD" ] ; then
		ISSAMEPASSWORD=$(jq '.VagVBoxMN.Cluster.Terminal[0].IsSamePassword' $NODES_JSON)
		ISSAMEPASSWORD="${ISSAMEPASSWORD//$DoubleQuotes/$NoQuotes}"
		if [ $ISSAMEPASSWORD == "YES" ] || [ $ISSAMEPASSWORD == "YES" ] ; then
			echo '-----------------------'
			echo ''		
			read -s -p "Enter Password For All Terminals > " -e -i "" GLOBALPASSWORD
			echo ''
			THECOUNTKEEPER=0
			for((j=0;j<$TerminalsCount;j++))
			do
				CHECKIFTOOMIT=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
				CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
				if [ $CHECKIFTOOMIT == "null" ] || [ $CHECKIFTOOMIT == "null" ] ; then
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]}'├PASSWORD├'$GLOBALPASSWORD
					THECOUNTKEEPER=$((THECOUNTKEEPER + 1))
				fi		
			done
			THECOUNTKEEPER=0
			echo ''
			echo '-----------------------'
			echo ''							
		else
			echo '-----------------------'
			echo ''
			THECOUNTKEEPER=0
			for((j=0;j<$TerminalsCount;j++))
			do
				CHECKIFTOOMIT=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
				CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
				if [ $CHECKIFTOOMIT == "null" ] || [ $CHECKIFTOOMIT == "null" ] ; then
					Terminal=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].HostName' $NODES_JSON)
					Terminal="${Terminal//$DoubleQuotes/$NoQuotes}"
					TerminalIP=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].IPAddress' $NODES_JSON)
					TerminalIP="${TerminalIP//$DoubleQuotes/$NoQuotes}"				
					TEMPPASSWORD=""
					read -s -p "Enter Password For => $Terminal ($TerminalIP) > " -e -i "" TEMPPASSWORD
					echo ''
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]}'├PASSWORD├'$TEMPPASSWORD
					THECOUNTKEEPER=$((THECOUNTKEEPER + 1))
				fi		
			done
			THECOUNTKEEPER=0
			echo ''
			echo '-----------------------'	
			echo ''	
		fi				
	fi
	
	GLOBALPEM=""		
	if [ $AUTHMODE == "PEM" ] || [ $AUTHMODE == "PEM" ] ; then
		ISSAMEPEM=$(jq '.VagVBoxMN.Cluster.Terminal[0].IsSamePEM' $NODES_JSON)
		ISSAMEPEM="${ISSAMEPEM//$DoubleQuotes/$NoQuotes}"
		if [ $ISSAMEPEM == "YES" ] || [ $ISSAMEPEM == "YES" ] ; then
			echo '-----------------------'
			echo ''		
			read -p "Enter .pem File Location For All Terminals > " -e -i "" GLOBALPEM
			echo ''
			THECOUNTKEEPER=0
			for((j=0;j<$TerminalsCount;j++))
			do
				CHECKIFTOOMIT=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
				CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
				if [ $CHECKIFTOOMIT == "null" ] || [ $CHECKIFTOOMIT == "null" ] ; then
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]}'├PEM├'$GLOBALPEM
					THECOUNTKEEPER=$((THECOUNTKEEPER + 1))
				fi		
			done
			THECOUNTKEEPER=0
			echo '-----------------------'
			echo ''			
		else
			echo '-----------------------'
			echo ''
			THECOUNTKEEPER=0
			for((j=0;j<$TerminalsCount;j++))
			do
				CHECKIFTOOMIT=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
				CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
				if [ $CHECKIFTOOMIT == "null" ] || [ $CHECKIFTOOMIT == "null" ] ; then			
					Terminal=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].HostName' $NODES_JSON)
					Terminal="${Terminal//$DoubleQuotes/$NoQuotes}"
					TerminalIP=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].IPAddress' $NODES_JSON)
					TerminalIP="${TerminalIP//$DoubleQuotes/$NoQuotes}"
					TEMPPEM=""			
					read -p "Enter .pem File Location For => $Terminal ($TerminalIP) > " -e -i "" TEMPPEM
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]}'├PEM├'$TEMPPEM
					THECOUNTKEEPER=$((THECOUNTKEEPER + 1))	
				fi
			done
			THECOUNTKEEPER=0
			echo ''
			echo '-----------------------'	
			echo ''		
		fi				
	fi	

	if [ $AUTHMODE == "ANY" ] || [ $AUTHMODE == "ANY" ] ; then
		echo '-----------------------'
		echo ''
		THECOUNTKEEPER=0
		for((j=0;j<$TerminalsCount;j++))
		do
			CHECKIFTOOMIT=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
			CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
			if [ $CHECKIFTOOMIT == "null" ] || [ $CHECKIFTOOMIT == "null" ] ; then			
				Terminal=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].HostName' $NODES_JSON)
				Terminal="${Terminal//$DoubleQuotes/$NoQuotes}"
				TerminalIP=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].IPAddress' $NODES_JSON)
				TerminalIP="${TerminalIP//$DoubleQuotes/$NoQuotes}"
				TEMPACCESS=""
				CHECKIFAUTHMODEMISSING=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].AuthMode?' $NODES_JSON)
				CHECKIFAUTHMODEMISSING="${CHECKIFAUTHMODEMISSING//$DoubleQuotes/$NoQuotes}"
				if [ $CHECKIFAUTHMODEMISSING == "null" ] || [ $CHECKIFAUTHMODEMISSING == "null" ] ; then
					echo ''
					echo '-----------------------'
					echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'AuthMode' Missing In '$NODES_JSON' For Terminal => $Terminal ($TerminalIP)"				
					echo '-----------------------'
					echo ''										
					exit				
				fi
				if [ "$CHECKIFAUTHMODEMISSING" == "PASSWORD" ] || [ "$CHECKIFAUTHMODEMISSING" == "PASSWORD" ] ; then
					TEMPACCESS=""
					read -s -p "Enter Password For => $Terminal ($TerminalIP) > " -e -i "" TEMPACCESS
					echo ''	
					TEMPACCESS='PASSWORD├'$TEMPACCESS
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]}'├'$TEMPACCESS
					THECOUNTKEEPER=$((THECOUNTKEEPER + 1))									
				fi
				if [ "$CHECKIFAUTHMODEMISSING" == "PEM" ] || [ "$CHECKIFAUTHMODEMISSING" == "PEM" ] ; then
					TEMPACCESS=""
					read -p "Enter .pem File Location For => $Terminal ($TerminalIP) > " -e -i "" TEMPACCESS	
					TEMPACCESS='PEM├'$TEMPACCESS
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]}'├'$TEMPACCESS
					THECOUNTKEEPER=$((THECOUNTKEEPER + 1))														
				fi																				
			fi
		done
		THECOUNTKEEPER=0
		echo ''
		echo '-----------------------'	
		echo ''	
	fi
	
	echo '-----------------------'
	RANDOMFOLDERNAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
	sudo mkdir -p $BASE/VagVBoxMN/$RANDOMFOLDERNAME
	sudo chmod -R 777 $BASE/VagVBoxMN/$RANDOMFOLDERNAME
	pushd $BASE/VagVBoxMN/$RANDOMFOLDERNAME
	touch $RANDOMFOLDERNAME
	for Terminal in "${FINAL_BEFORE_CONNECT_TERMINAL_LIST[@]}"
	do
		IFS='├' read -r -a TerminalVals <<< $Terminal
		THEREQUIREDUSER="${TerminalVals[2]}"
		THEREQUIREDAUTH="${TerminalVals[6]}"
		THEREQUIREDACCESS="${TerminalVals[7]}"
		THEREQUIREDPORT="${TerminalVals[3]}"
		THEREQUIREDIP="${TerminalVals[1]}"
		THEREQUIREDHOSTNAME="${TerminalVals[0]}"
		(
		set -Ee
		function _catch {
			echo "ERROR"
			exit 0
		}
		function _finally {
			abc=xyz
		}
		trap _catch ERR
		trap _finally EXIT
		if [ $THEREQUIREDAUTH == "PASSWORD" ] || [ $THEREQUIREDAUTH == "PASSWORD" ] ; then
			THERESPONSE=$(sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT  -o "StrictHostKeyChecking=no" "echo \"$RANDOMFOLDERNAME\"")
			echo "$Terminal├$THERESPONSE" >> $RANDOMFOLDERNAME		
		fi
		if [ $THEREQUIREDAUTH == "PEM" ] || [ $THEREQUIREDAUTH == "PEM" ] ; then
			sudo cp $THEREQUIREDACCESS ThePemFile
			sudo chown $CURRENTUSER:$CURRENTUSER ThePemFile
			sudo chmod 400 ThePemFile
			THERESPONSE=$(ssh -o ConnectTimeout=15 -o BatchMode=yes -o PasswordAuthentication=no $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile "echo \"$RANDOMFOLDERNAME\"")
			echo "$Terminal├$THERESPONSE" >> $RANDOMFOLDERNAME		
		fi		
		)		
	done	
	popd
	echo '-----------------------'	
	echo ''

	while read LINE; do
		IFS='├' read -r -a TerminalFullVals <<< $LINE
		ACCESSTRYRESULT="${TerminalFullVals[8]}"
		if [ "$ACCESSTRYRESULT" == "$RANDOMFOLDERNAME" ] || [ "$ACCESSTRYRESULT" == "$RANDOMFOLDERNAME" ] ; then
			FINAL_TERMINAL_LIST+=("$LINE")	
		fi
	done < $BASE/VagVBoxMN/$RANDOMFOLDERNAME/$RANDOMFOLDERNAME	
	sudo rm -rf $BASE/VagVBoxMN/$RANDOMFOLDERNAME

	clear
	
	echo -e "${ORANGE}==============================================================================${NC}"
	echo -e "${BLUE}${BOLD}\x1b[4mM${NORM}${NC}ultifaceted deploy${BLUE}${BOLD}\x1b[4mA${NORM}${NC}gnostic ${BLUE}${BOLD}\x1b[4mT${NORM}${NC}imesaving ${BLUE}${BOLD}\x1b[4mS${NORM}${NC}calable anal${BLUE}${BOLD}\x1b[4mY${NORM}${NC}tics ${BLUE}${BOLD}\x1b[4mA${NORM}${NC}malgamated ${BOLD}\x1b[30;44mPLATFORM\x1b[m${NORM}"
	echo -e "${GREEN}==============================================================================${NC}"
	echo ''
	echo -e "\x1b[3m\x1b[4mVAGRANT VIRTUALBOX MULTINODE\x1b[m"
	echo ''
		
	echo '-----------------------'
	echo -e "${BOLD}TERMINALS AVAILABLE${NORM}"
	echo '-----------------------'
	COUNTERe=1
	for Terminal in "${FINAL_TERMINAL_LIST[@]}"
	do
		IFS='├' read -r -a TerminalVals <<< $Terminal
		THEREQUIREDIP="${TerminalVals[1]}"
		THEREQUIREDHOSTNAME="${TerminalVals[0]}"		
		echo "($COUNTERe) $THEREQUIREDHOSTNAME / $THEREQUIREDIP"
		COUNTERe=$((COUNTERe + 1)) 
	done
	echo '-----------------------'	
	echo ''
	read -p "Confirm (y/n) > " -e -i "n" ReadyToGo
	echo ''	
	if [ $ReadyToGo == "y" ] || [ $ReadyToGo == "Y" ] ; then
		RANDOMUSERNAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
		RANDOMPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
		
		echo '-----------------------'
		echo 'NEW SSH KEYS'
		echo '-----------------------'		
		sudo mkdir -p $BASE/VagVBoxMN/$CLUSTERNAME/Keys
		sudo -H -u root bash -c "cd $BASE/VagVBoxMN/$CLUSTERNAME/Keys && echo -e  'y\n'|ssh-keygen -b 2048 -t rsa -P '' -f id_rsa && cat id_rsa.pub >> authorized_keys && cp id_rsa matsya-vagvbox-mn-$CLUSTERNAME-terminal.pem && puttygen matsya-vagvbox-mn-$CLUSTERNAME-terminal.pem -o matsya-vagvbox-mn-$CLUSTERNAME-terminal.ppk && cd ~"
		sudo rm -rf $BASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.pem
		sudo rm -rf $BASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.ppk
		sudo mv $BASE/VagVBoxMN/$CLUSTERNAME/Keys/matsya-vagvbox-mn-$CLUSTERNAME-terminal.pem $BASE
		sudo mv $BASE/VagVBoxMN/$CLUSTERNAME/Keys/matsya-vagvbox-mn-$CLUSTERNAME-terminal.ppk $BASE
		sudo chmod u=r,g=,o= $BASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.pem
		sudo chmod u=r,g=,o= $BASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.ppk
		sudo rm -rf $BASE/VagVBoxMN/$CLUSTERNAME/Keys/authorized_keys
		sudo rm -rf $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa	
		sudo chown -R root:root $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa.pub
		sudo chmod -R u=rx,g=,o= $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa.pub
		echo ''
		sudo mv $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa.pub $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub
		sudo -H -u root bash -c "cd $BASE/VagVBoxMN/$CLUSTERNAME/Keys && echo -e  'y\n'|ssh-keygen -b 2048 -t rsa -P '' -f id_rsa && cat id_rsa.pub >> authorized_keys && cp id_rsa matsya-vagvbox-mn-$CLUSTERNAME.pem && puttygen matsya-vagvbox-mn-$CLUSTERNAME.pem -o matsya-vagvbox-mn-$CLUSTERNAME.ppk && cd ~"
		sudo rm -rf $BASE/matsya-vagvbox-mn-$CLUSTERNAME.pem
		sudo rm -rf $BASE/matsya-vagvbox-mn-$CLUSTERNAME.ppk
		sudo mv $BASE/VagVBoxMN/$CLUSTERNAME/Keys/matsya-vagvbox-mn-$CLUSTERNAME.pem $BASE
		sudo mv $BASE/VagVBoxMN/$CLUSTERNAME/Keys/matsya-vagvbox-mn-$CLUSTERNAME.ppk $BASE
		sudo chmod u=r,g=,o= $BASE/matsya-vagvbox-mn-$CLUSTERNAME.pem
		sudo chmod u=r,g=,o= $BASE/matsya-vagvbox-mn-$CLUSTERNAME.ppk
		sudo rm -rf $BASE/VagVBoxMN/$CLUSTERNAME/Keys/authorized_keys
		sudo rm -rf $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa	
		sudo chown -R root:root $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa.pub
		sudo chmod -R u=rx,g=,o= $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa.pub				
		echo '-----------------------'
		echo ''
		echo '-----------------------'
		sudo chmod 777 $BASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.pem
		sudo chmod 777 $BASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.ppk
		sudo chmod 777 $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub
		sudo chmod 777 $BASE/matsya-vagvbox-mn-$CLUSTERNAME.pem
		sudo chmod 777 $BASE/matsya-vagvbox-mn-$CLUSTERNAME.ppk
		sudo chmod 777 $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa.pub		
		for Terminal in "${FINAL_TERMINAL_LIST[@]}"
		do
			IFS='├' read -r -a TerminalVals <<< $Terminal
			THEREQUIREDUSER="${TerminalVals[2]}"
			THEREQUIREDAUTH="${TerminalVals[6]}"
			THEREQUIREDACCESS="${TerminalVals[7]}"
			THEREQUIREDPORT="${TerminalVals[3]}"
			THEREQUIREDIP="${TerminalVals[1]}"
			THEREQUIREDHOSTNAME="${TerminalVals[0]}"
			THEREQUIREDOS="${TerminalVals[4]}"
			THEREQUIREDBASE="${TerminalVals[5]}"		
			echo ''
			echo '~~~~~~~~~~~~~~~~~~~~~~~'
			echo "$THEREQUIREDHOSTNAME ($THEREQUIREDIP) $RANDOMUSERNAME-$RANDOMPASSWORD"
			echo '~~~~~~~~~~~~~~~~~~~~~~~'
			RANDOMFILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-Vagrant-VirtualBox-MultiNode-FirstConnectTemplate $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo sed -i s#THENAMEOFTHEUSER#$RANDOMUSERNAME#g $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo sed -i s#THEPASSWORDFORTHEUSER#$RANDOMPASSWORD#g $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo sed -i s#OSNAMETOBEUSED#$THEREQUIREDOS#g $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo sed -i s#BASENAMETOBEUSED#$THEREQUIREDBASE#g $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo sed -i s#CLUSTERNAMETOBEUSED#$CLUSTERNAME#g $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo chmod 777 $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOMFILENAME		
			if [ $THEREQUIREDAUTH == "PASSWORD" ] || [ $THEREQUIREDAUTH == "PASSWORD" ] ; then
				sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOMFILENAME $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "chmod 777 $RANDOMFILENAME && echo \"$THEREQUIREDACCESS\" | sudo -S ./$RANDOMFILENAME && rm -rf $RANDOMFILENAME"
				sudo cat $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub | sshpass -p "$RANDOMPASSWORD" ssh -o ConnectTimeout=15 $RANDOMUSERNAME@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "cat >> /home/$RANDOMUSERNAME/.ssh/authorized_keys"
				THEFILERESPONSE=$(sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "[ -f \"$THEREQUIREDBASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.pem\" ] && echo 'YES' || echo 'NO'")
				if [ $THEFILERESPONSE == "NO" ] || [ $THEFILERESPONSE == "NO" ] ; then
					RANDOM2FILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa.pub $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/matsya-vagvbox-mn-$CLUSTERNAME.pem $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/matsya-vagvbox-mn-$CLUSTERNAME.ppk $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.pem $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.ppk $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sudo touch $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME
					sudo chmod 777 $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME
					echo "sudo mv matsya-vagvbox-mn-$CLUSTERNAME.pem $THEREQUIREDBASE" | sudo tee -a $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo mv matsya-vagvbox-mn-$CLUSTERNAME.ppk $THEREQUIREDBASE" | sudo tee -a $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo mv matsya-vagvbox-mn-$CLUSTERNAME-terminal.pem $THEREQUIREDBASE" | sudo tee -a $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo mv matsya-vagvbox-mn-$CLUSTERNAME-terminal.ppk $THEREQUIREDBASE" | sudo tee -a $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo mv id_rsa.pub $THEREQUIREDBASE/VagVBoxMN/$CLUSTERNAME/Keys" | sudo tee -a $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo mv id_rsa_terminal.pub $THEREQUIREDBASE/VagVBoxMN/$CLUSTERNAME/Keys" | sudo tee -a $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo chown root:root $THEREQUIREDBASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.pem && sudo chmod u=r,g=,o= $THEREQUIREDBASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.pem" | sudo tee -a $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo chown root:root $THEREQUIREDBASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.ppk && sudo chmod u=r,g=,o= $THEREQUIREDBASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.ppk" | sudo tee -a $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo chown root:root $THEREQUIREDBASE/matsya-vagvbox-mn-$CLUSTERNAME.pem && sudo chmod u=r,g=,o= $THEREQUIREDBASE/matsya-vagvbox-mn-$CLUSTERNAME.pem" | sudo tee -a $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo chown root:root $THEREQUIREDBASE/matsya-vagvbox-mn-$CLUSTERNAME.ppk && sudo chmod u=r,g=,o= $THEREQUIREDBASE/matsya-vagvbox-mn-$CLUSTERNAME.ppk" | sudo tee -a $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo chown root:root $THEREQUIREDBASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa.pub && sudo chmod -R u=rx,g=,o= $THEREQUIREDBASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa.pub" | sudo tee -a $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo chown root:root $THEREQUIREDBASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub && sudo chmod -R u=rx,g=,o= $THEREQUIREDBASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub" | sudo tee -a $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null					
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "chmod 777 $RANDOM2FILENAME && echo \"$THEREQUIREDACCESS\" | sudo -S ./$RANDOM2FILENAME && rm -rf $RANDOM2FILENAME"
					sudo rm -rf $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOM2FILENAME
					echo ''	
				fi		
			fi
			if [ $THEREQUIREDAUTH == "PEM" ] || [ $THEREQUIREDAUTH == "PEM" ] ; then
				sudo cp $THEREQUIREDACCESS ThePemFile
				sudo chown $CURRENTUSER:$CURRENTUSER ThePemFile
				sudo chmod 400 ThePemFile				
			fi
			sudo rm -rf $BASE/VagVBoxMN/$CLUSTERNAME/$RANDOMFILENAME
			echo '~~~~~~~~~~~~~~~~~~~~~~~'						
		done
		sudo chmod u=r,g=,o= $BASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.pem
		sudo chmod u=r,g=,o= $BASE/matsya-vagvbox-mn-$CLUSTERNAME-terminal.ppk
		sudo chmod -R u=rx,g=,o= $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub
		sudo chmod u=r,g=,o= $BASE/matsya-vagvbox-mn-$CLUSTERNAME.pem
		sudo chmod u=r,g=,o= $BASE/matsya-vagvbox-mn-$CLUSTERNAME.ppk
		sudo chmod -R u=rx,g=,o= $BASE/VagVBoxMN/$CLUSTERNAME/Keys/id_rsa.pub		
		echo ''		
		echo '-----------------------'
		echo ''								
	else
		echo "Exiting..."
		echo ''	
		exit
	fi	
else
	echo "Exiting ..."
	echo ''
	exit
fi			

