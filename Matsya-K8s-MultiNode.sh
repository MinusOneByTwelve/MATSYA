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
echo -e "\x1b[3m\x1b[4mK8s MULTINODE\x1b[m"
echo ''
read -p "Enter File Path For Settings > " -e -i "/opt/Matsya/Repo/Matsya.config" NODES_JSON
echo "                                                                         "

BASE=$(jq '.K8sMN.Cluster.Terminal[0].BaseLocation' $NODES_JSON)
BASE="${BASE//$DoubleQuotes/$NoQuotes}"
sudo mkdir -p $BASE/K8sMN
sudo mkdir -p $BASE/Repo

CLUSTERNAME=$(jq '.K8sMN.Cluster.Info[0].Name' $NODES_JSON)
CLUSTERNAME="${CLUSTERNAME//$DoubleQuotes/$NoQuotes}"
if [ "$CLUSTERNAME" == "" ] || [ "$CLUSTERNAME" == "" ] ; then
UUID=$(uuidgen)
UUIDREAL=${UUID:1:6}
CLUSTERNAME=$UUIDREAL
fi

echo "==============================================================================

If '$CLUSTERNAME' Already Exists,Execute

   * sudo $BASE/matsya-k8s-mn-$CLUSTERNAME-kill.sh      
     
==============================================================================
"
echo -e "Enter Choice => { (${GREEN}${BOLD}\x1b[4mC${NORM}${NC})onfirm (${RED}${BOLD}\x1b[4mA${NORM}${NC})bort (${YELLOW}${BOLD}\x1b[4mP${NORM}${NC})roceed } c/a/p"
read -p "> " -e -i "a" CONFIRMPROCEED	
echo ""
if [ $CONFIRMPROCEED == "p" ] || [ $CONFIRMPROCEED == "P" ] ; then
	sudo $BASE/matsya-k8s-mn-$CLUSTERNAME-kill.sh	
	CONFIRMPROCEED="C"
fi
if [ $CONFIRMPROCEED == "c" ] || [ $CONFIRMPROCEED == "C" ] ; then
	echo "=============================================================================="
	echo ''
	AUTHMODE=$(jq '.K8sMN.Cluster.Terminal[0].AuthMode' $NODES_JSON)
	AUTHMODE="${AUTHMODE//$DoubleQuotes/$NoQuotes}"
	
	TerminalsCount=$(jq '.K8sMN.Cluster.Terminals | length' $NODES_JSON)

	GLOBALUSERNAME=$(jq '.K8sMN.Cluster.Terminal[0].UserName' $NODES_JSON)
	GLOBALUSERNAME="${GLOBALUSERNAME//$DoubleQuotes/$NoQuotes}"
	
	GLOBALSSHPORT=$(jq '.K8sMN.Cluster.Terminal[0].SSHPort' $NODES_JSON)
	GLOBALSSHPORT="${GLOBALSSHPORT//$DoubleQuotes/$NoQuotes}"	

	GLOBALOS=$(jq '.K8sMN.Cluster.Terminal[0].OS' $NODES_JSON)
	GLOBALOS="${GLOBALOS//$DoubleQuotes/$NoQuotes}"
	
	FINAL_BEFORE_CONNECT_TERMINAL_LIST=()
	FINAL_TERMINAL_LIST=()
						
	for((j=0;j<$TerminalsCount;j++))
	do
		Terminal=$(jq '.K8sMN.Cluster.Terminals['${j}'].HostName' $NODES_JSON)
		Terminal="${Terminal//$DoubleQuotes/$NoQuotes}"
		TerminalIP=$(jq '.K8sMN.Cluster.Terminals['${j}'].IPAddress' $NODES_JSON)
		TerminalIP="${TerminalIP//$DoubleQuotes/$NoQuotes}"
		TerminalUserName=""
		TerminalSSHPort=""
		TerminalTheRqOS=""
		TerminalTheRqBase=""
		TerminalTheRqLocation=""	
		CHECKIFTOOMIT=$(jq '.K8sMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
		CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
		if [ $CHECKIFTOOMIT == "null" ] || [ $CHECKIFTOOMIT == "null" ] ; then			
			CHECKIFUSERNAMEMISSING=$(jq '.K8sMN.Cluster.Terminals['${j}'].UserName?' $NODES_JSON)
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
			
			CHECKIFSSHPORTMISSING=$(jq '.K8sMN.Cluster.Terminals['${j}'].SSHPort?' $NODES_JSON)
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
			
			CHECKIFOSMISSING=$(jq '.K8sMN.Cluster.Terminals['${j}'].OS?' $NODES_JSON)
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
			
			CHECKIFBASELOCATIONMISSING=$(jq '.K8sMN.Cluster.Terminals['${j}'].BaseLocation?' $NODES_JSON)
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
			
			CHECKIFTHELOCATIONMISSING=$(jq '.K8sMN.Cluster.Terminals['${j}'].LAN?' $NODES_JSON)
			CHECKIFTHELOCATIONMISSING="${CHECKIFTHELOCATIONMISSING//$DoubleQuotes/$NoQuotes}"
			if [ "$CHECKIFTHELOCATIONMISSING" == "null" ] || [ "$CHECKIFTHELOCATIONMISSING" = "" ] ; then
				TerminalTheRqLocation="PUBLIC"
			else
				TerminalTheRqLocation="$CHECKIFTHELOCATIONMISSING"							
			fi			
									
			FINAL_BEFORE_CONNECT_TERMINAL_LIST+=("$Terminal├$TerminalIP├$TerminalUserName├$TerminalSSHPort├$TerminalTheRqOS├$TerminalTheRqBase├$TerminalTheRqLocation")																			
		fi
	done
				
	GLOBALPASSWORD=""		
	if [ $AUTHMODE == "PASSWORD" ] || [ $AUTHMODE == "PASSWORD" ] ; then
		ISSAMEPASSWORD=$(jq '.K8sMN.Cluster.Terminal[0].IsSamePassword' $NODES_JSON)
		ISSAMEPASSWORD="${ISSAMEPASSWORD//$DoubleQuotes/$NoQuotes}"
		if [ $ISSAMEPASSWORD == "YES" ] || [ $ISSAMEPASSWORD == "YES" ] ; then
			echo '-----------------------'
			echo ''		
			read -s -p "Enter Password For All Terminals > " -e -i "" GLOBALPASSWORD
			echo ''
			THECOUNTKEEPER=0
			for((j=0;j<$TerminalsCount;j++))
			do
				CHECKIFTOOMIT=$(jq '.K8sMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
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
				CHECKIFTOOMIT=$(jq '.K8sMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
				CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
				if [ $CHECKIFTOOMIT == "null" ] || [ $CHECKIFTOOMIT == "null" ] ; then
					Terminal=$(jq '.K8sMN.Cluster.Terminals['${j}'].HostName' $NODES_JSON)
					Terminal="${Terminal//$DoubleQuotes/$NoQuotes}"
					TerminalIP=$(jq '.K8sMN.Cluster.Terminals['${j}'].IPAddress' $NODES_JSON)
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
		ISSAMEPEM=$(jq '.K8sMN.Cluster.Terminal[0].IsSamePEM' $NODES_JSON)
		ISSAMEPEM="${ISSAMEPEM//$DoubleQuotes/$NoQuotes}"
		if [ $ISSAMEPEM == "YES" ] || [ $ISSAMEPEM == "YES" ] ; then
			echo '-----------------------'
			echo ''		
			read -p "Enter .pem File Location For All Terminals > " -e -i "" GLOBALPEM
			echo ''
			THECOUNTKEEPER=0
			for((j=0;j<$TerminalsCount;j++))
			do
				CHECKIFTOOMIT=$(jq '.K8sMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
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
				CHECKIFTOOMIT=$(jq '.K8sMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
				CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
				if [ $CHECKIFTOOMIT == "null" ] || [ $CHECKIFTOOMIT == "null" ] ; then			
					Terminal=$(jq '.K8sMN.Cluster.Terminals['${j}'].HostName' $NODES_JSON)
					Terminal="${Terminal//$DoubleQuotes/$NoQuotes}"
					TerminalIP=$(jq '.K8sMN.Cluster.Terminals['${j}'].IPAddress' $NODES_JSON)
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
			CHECKIFTOOMIT=$(jq '.K8sMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
			CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
			if [ $CHECKIFTOOMIT == "null" ] || [ $CHECKIFTOOMIT == "null" ] ; then			
				Terminal=$(jq '.K8sMN.Cluster.Terminals['${j}'].HostName' $NODES_JSON)
				Terminal="${Terminal//$DoubleQuotes/$NoQuotes}"
				TerminalIP=$(jq '.K8sMN.Cluster.Terminals['${j}'].IPAddress' $NODES_JSON)
				TerminalIP="${TerminalIP//$DoubleQuotes/$NoQuotes}"
				TEMPACCESS=""
				CHECKIFAUTHMODEMISSING=$(jq '.K8sMN.Cluster.Terminals['${j}'].AuthMode?' $NODES_JSON)
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
	sudo mkdir -p $BASE/K8sMN/$RANDOMFOLDERNAME
	sudo chmod -R 777 $BASE/K8sMN/$RANDOMFOLDERNAME
	pushd $BASE/K8sMN/$RANDOMFOLDERNAME
	touch $RANDOMFOLDERNAME
	for Terminal in "${FINAL_BEFORE_CONNECT_TERMINAL_LIST[@]}"
	do
		IFS='├' read -r -a TerminalVals <<< $Terminal
		THEREQUIREDUSER="${TerminalVals[2]}"
		THEREQUIREDAUTH="${TerminalVals[7]}"
		THEREQUIREDACCESS="${TerminalVals[8]}"
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
		ACCESSTRYRESULT="${TerminalFullVals[9]}"
		if [ "$ACCESSTRYRESULT" == "$RANDOMFOLDERNAME" ] || [ "$ACCESSTRYRESULT" == "$RANDOMFOLDERNAME" ] ; then
			FINAL_TERMINAL_LIST+=("$LINE")	
		fi
	done < $BASE/K8sMN/$RANDOMFOLDERNAME/$RANDOMFOLDERNAME	
	sudo rm -rf $BASE/K8sMN/$RANDOMFOLDERNAME

	sleep 2
	clear
	
	echo -e "${ORANGE}==============================================================================${NC}"
	echo -e "${BLUE}${BOLD}\x1b[4mM${NORM}${NC}ultifaceted deploy${BLUE}${BOLD}\x1b[4mA${NORM}${NC}gnostic ${BLUE}${BOLD}\x1b[4mT${NORM}${NC}imesaving ${BLUE}${BOLD}\x1b[4mS${NORM}${NC}calable anal${BLUE}${BOLD}\x1b[4mY${NORM}${NC}tics ${BLUE}${BOLD}\x1b[4mA${NORM}${NC}malgamated ${BOLD}\x1b[30;44mPLATFORM\x1b[m${NORM}"
	echo -e "${GREEN}==============================================================================${NC}"
	echo ''
	echo -e "\x1b[3m\x1b[4mK8s MULTINODE\x1b[m"
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
	WHENJOBBEGAN=$(echo $(date +%H):$(date +%M))	
	if [ $ReadyToGo == "y" ] || [ $ReadyToGo == "Y" ] ; then
		RANDOMUSERNAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
		RANDOMPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
		sudo mkdir -p $BASE/K8sMN/$CLUSTERNAME/Keys		
		sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/HOSTS
		sudo touch $BASE/K8sMN/$CLUSTERNAME/HOSTS
		sudo touch $BASE/K8sMN/$CLUSTERNAME/ListOfHosts
		echo '#!/bin/bash
		' | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/ListOfHosts > /dev/null		
		for Terminal in "${FINAL_TERMINAL_LIST[@]}"
		do
			IFS='├' read -r -a TerminalVals <<< $Terminal
			THEREQUIREDIP="${TerminalVals[1]}"
			THEREQUIREDHOSTNAME="${TerminalVals[0]}"
			THEREQUIREDLANTYPE="${TerminalVals[6]}"
			THEREQUIREDCONNECTPORT="${TerminalVals[3]}"
			echo "$THEREQUIREDHOSTNAME├$THEREQUIREDIP├$THEREQUIREDLANTYPE├$THEREQUIREDCONNECTPORT" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/HOSTS > /dev/null
			echo "sudo sed -i -e s~\"$THEREQUIREDIP\"~\"#$THEREQUIREDIP\"~g /etc/hosts > /dev/null" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/ListOfHosts > /dev/null
			echo "echo '$THEREQUIREDIP	$THEREQUIREDHOSTNAME' | sudo tee -a /etc/hosts > /dev/null" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/ListOfHosts > /dev/null					 
		done	
		sudo chown root:root $BASE/K8sMN/$CLUSTERNAME/HOSTS
		sudo chmod u=r,g=,o= $BASE/K8sMN/$CLUSTERNAME/HOSTS		
		echo '-----------------------'
		echo 'NEW SSH KEYS'
		echo '-----------------------'		
		sudo -H -u root bash -c "cd $BASE/K8sMN/$CLUSTERNAME/Keys && echo -e  'y\n'|ssh-keygen -b 2048 -t rsa -P '' -f id_rsa && cat id_rsa.pub >> authorized_keys && cp id_rsa matsya-k8s-mn-$CLUSTERNAME-terminal.pem && puttygen matsya-k8s-mn-$CLUSTERNAME-terminal.pem -o matsya-k8s-mn-$CLUSTERNAME-terminal.ppk && cd ~"
		sudo rm -rf $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem
		sudo rm -rf $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.ppk
		sudo mv $BASE/K8sMN/$CLUSTERNAME/Keys/matsya-k8s-mn-$CLUSTERNAME-terminal.pem $BASE
		sudo mv $BASE/K8sMN/$CLUSTERNAME/Keys/matsya-k8s-mn-$CLUSTERNAME-terminal.ppk $BASE
		sudo chmod u=r,g=,o= $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem
		sudo chmod u=r,g=,o= $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.ppk
		sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/Keys/authorized_keys
		sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa	
		sudo chown -R root:root $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa.pub
		sudo chmod -R u=rx,g=,o= $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa.pub
		echo ''
		sudo mv $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa.pub $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub
		sudo -H -u root bash -c "cd $BASE/K8sMN/$CLUSTERNAME/Keys && echo -e  'y\n'|ssh-keygen -b 2048 -t rsa -P '' -f id_rsa && cat id_rsa.pub >> authorized_keys && cp id_rsa matsya-k8s-mn-$CLUSTERNAME.pem && puttygen matsya-k8s-mn-$CLUSTERNAME.pem -o matsya-k8s-mn-$CLUSTERNAME.ppk && cd ~"
		sudo rm -rf $BASE/matsya-k8s-mn-$CLUSTERNAME.pem
		sudo rm -rf $BASE/matsya-k8s-mn-$CLUSTERNAME.ppk
		sudo mv $BASE/K8sMN/$CLUSTERNAME/Keys/matsya-k8s-mn-$CLUSTERNAME.pem $BASE
		sudo mv $BASE/K8sMN/$CLUSTERNAME/Keys/matsya-k8s-mn-$CLUSTERNAME.ppk $BASE
		sudo chmod u=r,g=,o= $BASE/matsya-k8s-mn-$CLUSTERNAME.pem
		sudo chmod u=r,g=,o= $BASE/matsya-k8s-mn-$CLUSTERNAME.ppk
		sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/Keys/authorized_keys
		sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa	
		sudo chown -R root:root $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa.pub
		sudo chmod -R u=rx,g=,o= $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa.pub				
		echo '-----------------------'
		echo ''
		echo '-----------------------'
		sudo chmod 777 $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem
		sudo chmod 777 $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.ppk
		sudo chmod 777 $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub
		sudo chmod 777 $BASE/matsya-k8s-mn-$CLUSTERNAME.pem
		sudo chmod 777 $BASE/matsya-k8s-mn-$CLUSTERNAME.ppk
		sudo chmod 777 $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa.pub
		sudo chmod 777 $BASE/K8sMN/$CLUSTERNAME/HOSTS		
		for Terminal in "${FINAL_TERMINAL_LIST[@]}"
		do
			IFS='├' read -r -a TerminalVals <<< $Terminal
			THEREQUIREDUSER="${TerminalVals[2]}"
			THEREQUIREDAUTH="${TerminalVals[7]}"
			THEREQUIREDACCESS="${TerminalVals[8]}"
			THEREQUIREDPORT="${TerminalVals[3]}"
			THEREQUIREDIP="${TerminalVals[1]}"
			THEREQUIREDHOSTNAME="${TerminalVals[0]}"
			THEREQUIREDOS="${TerminalVals[4]}"
			THEREQUIREDBASE="${TerminalVals[5]}"		
			echo ''
			echo '~~~~~~~~~~~~~~~~~~~~~~~'
			echo "$THEREQUIREDHOSTNAME ($THEREQUIREDIP)"
			echo '~~~~~~~~~~~~~~~~~~~~~~~'
			RANDOMFILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-FirstConnectTemplate $BASE/K8sMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo sed -i s#THENAMEOFTHEUSER#$RANDOMUSERNAME#g $BASE/K8sMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo sed -i s#THEPASSWORDFORTHEUSER#$RANDOMPASSWORD#g $BASE/K8sMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo sed -i s#OSNAMETOBEUSED#$THEREQUIREDOS#g $BASE/K8sMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo sed -i s#BASENAMETOBEUSED#$THEREQUIREDBASE#g $BASE/K8sMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo sed -i s#CLUSTERNAMETOBEUSED#$CLUSTERNAME#g $BASE/K8sMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo chmod 777 $BASE/K8sMN/$CLUSTERNAME/$RANDOMFILENAME
							
			RANDOM4FILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostConnectTemplate $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME
			sudo sed -i s#THENAMEOFTHEUSER#$RANDOMUSERNAME#g $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME
			sudo sed -i s#OSNAMETOBEUSED#$THEREQUIREDOS#g $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME
			sudo sed -i s#BASENAMETOBEUSED#$THEREQUIREDBASE#g $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME
			sudo sed -i s#CLUSTERNAMETOBEUSED#$CLUSTERNAME#g $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME
			sudo sed -i s#USERSELIGIBLE#"$CURRENTUSER├$RANDOMUSERNAME"#g $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME		
			sudo chmod 777 $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME
			
			RND1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostAddTemplate $BASE/K8sMN/$CLUSTERNAME/$RND1
			RND2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostExecTemplate $BASE/K8sMN/$CLUSTERNAME/$RND2
			RND3=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostKillTemplate $BASE/K8sMN/$CLUSTERNAME/$RND3
			RND4=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostPullTemplate $BASE/K8sMN/$CLUSTERNAME/$RND4
			RND5=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostPushTemplate $BASE/K8sMN/$CLUSTERNAME/$RND5
			RND6=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostRemoveTemplate $BASE/K8sMN/$CLUSTERNAME/$RND6
			RND7=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostSyncTemplate $BASE/K8sMN/$CLUSTERNAME/$RND7
																						
			RANDOM3FILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/K8sMN/$CLUSTERNAME/ListOfHosts $BASE/K8sMN/$CLUSTERNAME/$RANDOM3FILENAME
			sudo chmod 777 $BASE/K8sMN/$CLUSTERNAME/$RANDOM3FILENAME					
			if [ $THEREQUIREDAUTH == "PASSWORD" ] || [ $THEREQUIREDAUTH == "PASSWORD" ] ; then
				sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/$RANDOMFILENAME $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "chmod 777 $RANDOMFILENAME && echo \"$THEREQUIREDACCESS\" | sudo -S ./$RANDOMFILENAME && rm -rf $RANDOMFILENAME"								
				sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/$RANDOM3FILENAME $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "chmod 777 $RANDOM3FILENAME && echo \"$THEREQUIREDACCESS\" | sudo -S ./$RANDOM3FILENAME && rm -rf $RANDOM3FILENAME"				
				
				sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"$THEREQUIREDACCESS\" | sudo -S mv $RANDOM4FILENAME $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-connect.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-connect.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-connect.sh"								
				
				sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/$RND1 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"$THEREQUIREDACCESS\" | sudo -S mv $RND1 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-add.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-add.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-add.sh"								

				sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/$RND2 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"$THEREQUIREDACCESS\" | sudo -S mv $RND2 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-exec.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-exec.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-exec.sh"								
				
				sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/$RND3 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"$THEREQUIREDACCESS\" | sudo -S mv $RND3 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-kill.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-kill.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-kill.sh"								

				sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/$RND4 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"$THEREQUIREDACCESS\" | sudo -S mv $RND4 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-pull.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-pull.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-pull.sh"								

				sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/$RND5 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"$THEREQUIREDACCESS\" | sudo -S mv $RND5 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-push.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-push.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-push.sh"								

				sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/$RND6 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"$THEREQUIREDACCESS\" | sudo -S mv $RND6 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-remove.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-remove.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-remove.sh"								

				sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/$RND7 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"$THEREQUIREDACCESS\" | sudo -S mv $RND7 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-sync.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-sync.sh && echo \"$THEREQUIREDACCESS\" | sudo -S chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-sync.sh"								
						
				sudo cat $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub | sshpass -p "$RANDOMPASSWORD" ssh -o ConnectTimeout=15 $RANDOMUSERNAME@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "cat >> $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.ssh/authorized_keys"
				THEFILERESPONSE=$(sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "[ -f \"$THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem\" ] && echo 'YES' || echo 'NO'")
				if [ $THEFILERESPONSE == "NO" ] || [ $THEFILERESPONSE == "NO" ] ; then
					RANDOM2FILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa.pub $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/matsya-k8s-mn-$CLUSTERNAME.pem $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/matsya-k8s-mn-$CLUSTERNAME.ppk $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.ppk $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/HOSTS $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sudo touch $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME
					sudo chmod 777 $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME
					echo "sudo mv HOSTS $THEREQUIREDBASE/K8sMN/$CLUSTERNAME" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null					
					echo "sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/HOSTS && sudo chmod u=r,g=,o= $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/HOSTS" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo mv matsya-k8s-mn-$CLUSTERNAME.pem $THEREQUIREDBASE" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo mv matsya-k8s-mn-$CLUSTERNAME.ppk $THEREQUIREDBASE" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo mv matsya-k8s-mn-$CLUSTERNAME-terminal.pem $THEREQUIREDBASE" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo mv matsya-k8s-mn-$CLUSTERNAME-terminal.ppk $THEREQUIREDBASE" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo mv id_rsa.pub $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/Keys" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo mv id_rsa_terminal.pub $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/Keys" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem && sudo chmod u=r,g=,o= $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-terminal.ppk && sudo chmod u=r,g=,o= $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-terminal.ppk" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME.pem && sudo chmod u=r,g=,o= $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME.pem" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME.ppk && sudo chmod u=r,g=,o= $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME.ppk" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/Keys/id_rsa.pub && sudo chmod -R u=rx,g=,o= $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/Keys/id_rsa.pub" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null
					echo "sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub && sudo chmod -R u=rx,g=,o= $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME > /dev/null					
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "chmod 777 $RANDOM2FILENAME && echo \"$THEREQUIREDACCESS\" | sudo -S ./$RANDOM2FILENAME && rm -rf $RANDOM2FILENAME && echo \"$THEREQUIREDACCESS\" | sudo -S chmod 0700 $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.ssh && echo \"$THEREQUIREDACCESS\" | sudo -S chmod 0644 $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.ssh/authorized_keys"
					sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME	
				fi
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"$THEREQUIREDACCESS\" | sudo -S rm -rf /root/.bash_history && echo \"$THEREQUIREDACCESS\" | sudo -S rm -rf /home/$THEREQUIREDUSER/.bash_history && echo \"$THEREQUIREDACCESS\" | sudo -S rm -rf $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.bash_history"		
				echo ''
			fi
			if [ $THEREQUIREDAUTH == "PEM" ] || [ $THEREQUIREDAUTH == "PEM" ] ; then
				sudo rm -rf ThePemFile
				sudo cp $THEREQUIREDACCESS ThePemFile
				sudo chown $CURRENTUSER:$CURRENTUSER ThePemFile
				sudo chmod 400 ThePemFile
				sudo rm -rf ThePemFile				
			fi
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RANDOM3FILENAME
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RND1
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RND2
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RND3
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RND4
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RND5
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RND6
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RND7
			echo '~~~~~~~~~~~~~~~~~~~~~~~'						
		done
		sudo chmod u=r,g=,o= $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem
		sudo chmod u=r,g=,o= $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.ppk
		sudo chmod u=rx,g=,o= $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub
		sudo chmod u=r,g=,o= $BASE/matsya-k8s-mn-$CLUSTERNAME.pem
		sudo chmod u=r,g=,o= $BASE/matsya-k8s-mn-$CLUSTERNAME.ppk
		sudo chmod u=rx,g=,o= $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa.pub
		sudo chmod u=r,g=,o= $BASE/K8sMN/$CLUSTERNAME/HOSTS
		
		sudo chown $CURRENTUSER:$CURRENTUSER $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem
		sudo chown $CURRENTUSER:$CURRENTUSER $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.ppk
		sudo chown $CURRENTUSER:$CURRENTUSER $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub
		sudo chown $CURRENTUSER:$CURRENTUSER $BASE/matsya-k8s-mn-$CLUSTERNAME.pem
		sudo chown $CURRENTUSER:$CURRENTUSER $BASE/matsya-k8s-mn-$CLUSTERNAME.ppk
		sudo chown $CURRENTUSER:$CURRENTUSER $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa.pub
		sudo chown $CURRENTUSER:$CURRENTUSER $BASE/K8sMN/$CLUSTERNAME/HOSTS		
		
		sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/ListOfHosts		
		echo ''		
		echo '-----------------------'
		echo ''	
		
		sleep 2
		clear
		
		echo -e "${ORANGE}==============================================================================${NC}"
		echo -e "${BLUE}${BOLD}\x1b[4mM${NORM}${NC}ultifaceted deploy${BLUE}${BOLD}\x1b[4mA${NORM}${NC}gnostic ${BLUE}${BOLD}\x1b[4mT${NORM}${NC}imesaving ${BLUE}${BOLD}\x1b[4mS${NORM}${NC}calable anal${BLUE}${BOLD}\x1b[4mY${NORM}${NC}tics ${BLUE}${BOLD}\x1b[4mA${NORM}${NC}malgamated ${BOLD}\x1b[30;44mPLATFORM\x1b[m${NORM}"
		echo -e "${GREEN}==============================================================================${NC}"
		echo ''
		echo -e "\x1b[3m\x1b[4mK8s MULTINODE\x1b[m"
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
		echo -e "${RED}-----------------------${NC}"
		echo -e "${RED}${BOLD}\x1b[5mACCESS INFO${NORM}${NC}"
		echo -e "${RED}-----------------------${NC}"
		echo -e "${BOLD}FELLOWSHIP => $CLUSTERNAME${NORM}"		
		echo -e "${RED}$RANDOMUSERNAME => $RANDOMPASSWORD${NC}"
		echo -e "${RED}-----------------------${NC}"	
		echo "* $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem
* $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.ppk"
		echo '-----------------------'
		echo "* PASSWORD LOGIN     => sshpass -p \"$RANDOMPASSWORD\" ssh -p PORT -o \"StrictHostKeyChecking=no\" $RANDOMUSERNAME@TERMINAL"
		echo '-----'		
		echo "* SSH KEY LOGIN      => $BASE/matsya-k8s-mn-$CLUSTERNAME-connect.sh"
		echo '-----'		        
		echo "* FILE PUSH          => $BASE/matsya-k8s-mn-$CLUSTERNAME-push.sh"
		echo '-----'		
		echo "* FILE PULL          => $BASE/matsya-k8s-mn-$CLUSTERNAME-pull.sh"
		echo '-----'		
		echo "* EXECUTE            => $BASE/matsya-k8s-mn-$CLUSTERNAME-exec.sh"
		echo '-----'		
		echo "* ADD TERMINAL       => $BASE/matsya-k8s-mn-$CLUSTERNAME-add.sh"
		echo '-----'	
		echo "* REMOVE TERMINAL    => $BASE/matsya-k8s-mn-$CLUSTERNAME-remove.sh"
		echo '-----'
		echo "* SYNC TERMINAL      => $BASE/matsya-k8s-mn-$CLUSTERNAME-sync.sh"
		echo '-----'			
		echo "* DISBAND FELLOWSHIP => $BASE/matsya-k8s-mn-$CLUSTERNAME-kill.sh"							
		echo '-----------------------'		
		echo '' 	
		WHENJOBFIN=$(echo $(date +%H):$(date +%M))
		SEC1=`date +%s -d ${WHENJOBBEGAN}`
		SEC2=`date +%s -d ${WHENJOBFIN}`
		DIFFSEC=`expr ${SEC2} - ${SEC1}`
		THETOTALTIMETAKEN=$(echo `date +%M -ud @${DIFFSEC}`)
		echo "Total Time Taken => $THETOTALTIMETAKEN Minutes"	
		echo ''			
		echo "=============================================================================="
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

