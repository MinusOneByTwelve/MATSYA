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
		echo "Exiting For Now...Download & Execute Again."
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
echo "==============================================================================

*To Avoid Conflict Later...Open Another Terminal & Execute

   * sudo vagrant global-status --prune
   * sudo vagrant box list

If '$CLUSTERNAME' Appears On Above Commands,Execute

   * sudo $BASE/matsya-vagvbox-mn-$CLUSTERNAME-kill.sh      
     
==============================================================================
"
echo -e "Enter Choice => { (${GREEN}${BOLD}\x1b[4mC${NORM}${NC})onfirm (${RED}${BOLD}\x1b[4mA${NORM}${NC})bort (${YELLOW}${BOLD}\x1b[4mP${NORM}${NC})roceed } c/a/p"
read -p "> " -e -i "c" CONFIRMPROCEED	
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
			
			FINAL_BEFORE_CONNECT_TERMINAL_LIST+=("$Terminal├$TerminalIP├$TerminalUserName├$TerminalSSHPort")																			
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
			for((j=0;j<$TerminalsCount;j++))
			do
				CHECKIFTOOMIT=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
				CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
				if [ $CHECKIFTOOMIT == "null" ] || [ $CHECKIFTOOMIT == "null" ] ; then
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${j}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${j}]}'├PASSWORD├'$GLOBALPASSWORD
				fi		
			done
			echo ''
			echo '-----------------------'
			echo ''							
		else
			echo '-----------------------'
			echo ''
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
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${j}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${j}]}'├PASSWORD├'$TEMPPASSWORD
				fi		
			done
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
			for((j=0;j<$TerminalsCount;j++))
			do
				CHECKIFTOOMIT=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
				CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
				if [ $CHECKIFTOOMIT == "null" ] || [ $CHECKIFTOOMIT == "null" ] ; then
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${j}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${j}]}'├PEM├'$GLOBALPEM
				fi		
			done
			echo '-----------------------'
			echo ''			
		else
			echo '-----------------------'
			echo ''
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
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${j}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${j}]}'├PEM├'$TEMPPEM	
				fi
			done
			echo ''
			echo '-----------------------'	
			echo ''		
		fi				
	fi	

	if [ $AUTHMODE == "ANY" ] || [ $AUTHMODE == "ANY" ] ; then
		echo '-----------------------'
		echo ''
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
				if [ $CHECKIFAUTHMODEMISSING == "PASSWORD" ] || [ $CHECKIFAUTHMODEMISSING == "PASSWORD" ] ; then
					read -s -p "Enter Password For => $Terminal ($TerminalIP) > " -e -i "" TEMPACCESS
					echo ''	
					TEMPACCESS='PASSWORD├'$TEMPACCESS									
				fi
				if [ $CHECKIFAUTHMODEMISSING == "PEM" ] || [ $CHECKIFAUTHMODEMISSING == "PEM" ] ; then
					read -p "Enter .pem File Location For => $Terminal ($TerminalIP) > " -e -i "" TEMPACCESS	
					TEMPACCESS='PEM├'$TEMPACCESS									
				fi
				FINAL_BEFORE_CONNECT_TERMINAL_LIST[${j}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${j}]}'├'$TEMPACCESS																
			fi
		done
		echo ''
		echo '-----------------------'	
		echo ''	
	fi
	echo "${FINAL_BEFORE_CONNECT_TERMINAL_LIST[*]}"




	pswdddd="Ubuntu@123"
	(
	  set -Ee
	  function _catch {
	    echo "catch => $1"
	    exit 0  # optional; use if you don't want to propagate (rethrow) error to outer shell
	  }
	  function _finally {
	    echo 'finally'
	  }
	  trap _catch ERR
	  trap _finally EXIT
	  dfdffdf=$(sshpass -p "$pswdddd" ssh osboxes@192.168.1.47 "echo 'hello'")
	  echo 'response-'$dfdffdf > a.txt
	)
	echo $dfdffdf


	echo '#########################'
	for((j=0;j<$TerminalsCount;j++))
	do
		Terminal=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].HostName' $NODES_JSON)
		Terminal="${Terminal//$DoubleQuotes/$NoQuotes}"
		TerminalIP=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].IPAddress' $NODES_JSON)
		TerminalIP="${TerminalIP//$DoubleQuotes/$NoQuotes}"
		echo $Terminal
		echo $TerminalIP
		CHECKFORAUTHPROP=$(jq '.VagVBoxMN.Cluster.Terminals['${j}'].AuthMode?' $NODES_JSON)
		echo $CHECKFORAUTHPROP
		#ssh -q prathamos@$TerminalIP exit
		#RESULT=$(echo $?)
		#echo $RESULT
		#RESULT=$(ssh -o BatchMode=yes -o ConnectTimeout=5 prathamos@$TerminalIP echo ok 2>&1)
		#echo $RESULT
		#status=$(ssh -o BatchMode=yes -o ConnectTimeout=5 prathamos@$TerminalIP echo ok 2>&1)
		#echo $status
		#if [[ $status == ok ]] ; then
		#  echo auth ok, do something
		#elif [[ $status == "Permission denied"* ]] ; then
		#  echo no_auth
		#else
		#  echo other_error
		#fi		
	done	
else
	echo "Exiting For Now..."
	echo ''
	exit
fi			

