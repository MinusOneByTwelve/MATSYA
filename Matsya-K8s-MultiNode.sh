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
sudo mkdir -p $BASE/tmp
sudo rm -rf $BASE/tmp/*

CLUSTERNAME=$(jq '.K8sMN.Cluster.Info[0].Name' $NODES_JSON)
CLUSTERNAME="${CLUSTERNAME//$DoubleQuotes/$NoQuotes}"
if [ "$CLUSTERNAME" == "" ] || [ "$CLUSTERNAME" == "" ] ; then
UUID=$(uuidgen)
UUIDREAL=${UUID:1:6}
CLUSTERNAME=$UUIDREAL
fi

echo "==============================================================================

If '$CLUSTERNAME' Cluster Already Exists,Execute

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
	TerminalsCount=$((TerminalsCount - 1))

	GLOBALUSERNAME=$(jq '.K8sMN.Cluster.Terminal[0].UserName' $NODES_JSON)
	GLOBALUSERNAME="${GLOBALUSERNAME//$DoubleQuotes/$NoQuotes}"
	
	GLOBALSSHPORT=$(jq '.K8sMN.Cluster.Terminal[0].SSHPort' $NODES_JSON)
	GLOBALSSHPORT="${GLOBALSSHPORT//$DoubleQuotes/$NoQuotes}"	

	GLOBALOS=$(jq '.K8sMN.Cluster.Terminal[0].OS' $NODES_JSON)
	GLOBALOS="${GLOBALOS//$DoubleQuotes/$NoQuotes}"
	
	FINAL_BEFORE_CONNECT_TERMINAL_LIST=()
	FINAL_TERMINAL_LIST=()
	THEACTUALSECRETS=""
	THESECRETKEY=""
	GlobalE2EPassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
	E2EALLOCATIONHAPPENED="NO"
						
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
		if [ "$CHECKIFTOOMIT" == "null" ] || [ "$CHECKIFTOOMIT" == "" ] ; then			
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
			
			CHECKIFRANGEISPRESENT=$(jq '.K8sMN.Cluster.Terminals['${j}'].Range?' $NODES_JSON)
			CHECKIFRANGEISPRESENT="${CHECKIFRANGEISPRESENT//$DoubleQuotes/$NoQuotes}"
			if [ "$CHECKIFRANGEISPRESENT" == "null" ] || [ "$CHECKIFRANGEISPRESENT" = "" ] ; then			
				FINAL_BEFORE_CONNECT_TERMINAL_LIST+=("$Terminal├$TerminalIP├$TerminalUserName├$TerminalSSHPort├$TerminalTheRqOS├$TerminalTheRqBase├$TerminalTheRqLocation")
			else				
				REGEXNUMBER='^[0-9]+$'
				if ! [[ $CHECKIFRANGEISPRESENT =~ $REGEXNUMBER ]] ; then
					echo '-----------------------'					
					echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'Range' Needed Numeric In '$NODES_JSON' For Terminal => $Terminal ($TerminalIP)"
					echo '-----------------------'
					echo ''
					exit
				fi
				
				THESECRETSFILE=$(jq '.K8sMN.Cluster.Terminal[0].SecretsFileLocation' $NODES_JSON)
				THESECRETSFILE="${THESECRETSFILE//$DoubleQuotes/$NoQuotes}"
				if [ "$THESECRETSFILE" == "" ] || [ "$THESECRETSFILE" == "" ] ; then
					echo '-----------------------'					
					echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mSecrets File Location Missing !!"
					echo '-----------------------'
					echo ''
					exit
				fi
				
				if [ -f "$THESECRETSFILE" ]
				then
					ABC="XYZ"
				else
					echo '-----------------------'					
					echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mSecret File Missing !!"
					echo '-----------------------'
					echo ''
					exit
				fi
				
				CHECKIFTERRAFORMISPRESENT=$(jq '.K8sMN.Cluster.Terminals['${j}'].Terraform?' $NODES_JSON)
				CHECKIFTERRAFORMISPRESENT="${CHECKIFTERRAFORMISPRESENT//$DoubleQuotes/$NoQuotes}"
				if [ "$CHECKIFTERRAFORMISPRESENT" == "null" ] || [ "$CHECKIFTERRAFORMISPRESENT" = "" ] ; then				
					if [ "$TerminalIP" == "null" ] || [ "$TerminalIP" = "" ] ; then
						echo '-----------------------'					
						echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'IPAddress' Missing In '$NODES_JSON' For Terminal => $Terminal"
						echo '-----------------------'
						echo ''
						exit
					fi								
									
					IFS='.' read -r -a IPAddressPieces <<< $TerminalIP
					STARTPOINT="${IPAddressPieces[3]}"
					STARTPOINT="$(($STARTPOINT + 0))"
					ENDPOINT="$(($CHECKIFRANGEISPRESENT + 0))"
					THENEWIP=""
					THENEWTERMINALNAME=""				
					for((TCounter=STARTPOINT;TCounter<=ENDPOINT;TCounter++))
					do
						THENEWIP=$THENEWIP"${IPAddressPieces[0]}"".""${IPAddressPieces[1]}"".""${IPAddressPieces[2]}""."$TCounter"¬"
						THENEWTERMINALNAME=$THENEWTERMINALNAME"$Terminal-""${IPAddressPieces[0]}""-""${IPAddressPieces[1]}""-""${IPAddressPieces[2]}""-"$TCounter"-"$(echo "$TerminalTheRqOS" | tr '[:upper:]' '[:lower:]')".cluster""¬"										
					done
					FINAL_BEFORE_CONNECT_TERMINAL_LIST+=("$THENEWTERMINALNAME├$THENEWIP├$TerminalUserName├$TerminalSSHPort├$TerminalTheRqOS├$TerminalTheRqBase├$TerminalTheRqLocation")
				else
					if [ $TerminalTheRqOS == "E2E7" ] || [ $TerminalTheRqOS == "E2E8" ] || [ $TerminalTheRqOS == "E2ED" ] || [ $TerminalTheRqOS == "E2EU" ] ; then
						CHECKIFTHEDISTROISPRESENT=$(jq '.K8sMN.Cluster.Terminals['${j}'].Distro?' $NODES_JSON)
						CHECKIFTHEDISTROISPRESENT="${CHECKIFTHEDISTROISPRESENT//$DoubleQuotes/$NoQuotes}"					
						if [ "$CHECKIFTHEDISTROISPRESENT" == "null" ] || [ "$CHECKIFTHEDISTROISPRESENT" = "0" ] ; then
							echo '-----------------------'					
							echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'Distro' Missing In '$NODES_JSON' For Terminal => $Terminal"
							echo '-----------------------'
							echo ''
							exit
						fi
						
						IFS=',' read -r -a CHECKIFTERRAFORMISPRESENTVALS <<< $CHECKIFTERRAFORMISPRESENT
						THEREGION="${CHECKIFTERRAFORMISPRESENTVALS[0]}"
						THEFAMILY="${CHECKIFTERRAFORMISPRESENTVALS[1]}"
						THEREGION=$(echo "${THEREGION##*( )}")
						THEREGION=$(echo "${THEREGION%%*( )}")
						THEFAMILY=$(echo "${THEFAMILY##*( )}")
						THEFAMILY=$(echo "${THEFAMILY%%*( )}")												
						if [ "$THESECRETKEY" == "null" ] || [ "$THESECRETKEY" = "" ] ; then
							read -s -p "Enter Secret Key > " -e -i "" THESECRETKEY
							echo ''	
							echo ''
							ITER=${THESECRETKEY:7:6}
							RANDOMSECFILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
							sudo cp $THESECRETSFILE $BASE/tmp/$RANDOMSECFILENAME
							sudo chown $CURRENTUSER:$CURRENTUSER $BASE/tmp/$RANDOMSECFILENAME
							sudo chmod u=r,g=,o= $BASE/tmp/$RANDOMSECFILENAME
							REALSECRETSFILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
							openssl enc -a -d -aes-256-cbc -pbkdf2 -iter $ITER -k $THESECRETKEY -in $BASE/tmp/$RANDOMSECFILENAME -out $BASE/tmp/$REALSECRETSFILENAME
							sudo chown $CURRENTUSER:$CURRENTUSER $BASE/tmp/$REALSECRETSFILENAME
							sudo chmod u=r,g=,o= $BASE/tmp/$REALSECRETSFILENAME
							THEACTUALSECRETS=$(<$BASE/tmp/$REALSECRETSFILENAME)		
							sudo rm -rf $BASE/tmp/$REALSECRETSFILENAME				
							sudo rm -rf $BASE/tmp/$RANDOMSECFILENAME						
						fi
						APIKey=$(echo $THEACTUALSECRETS | jq -c ".K8sMN.Cluster.E2E[0].APIKey?")
						APIKey="${APIKey//$DoubleQuotes/$NoQuotes}"
						TokenName=$(echo $THEACTUALSECRETS | jq -c ".K8sMN.Cluster.E2E[0].TokenName?")
						TokenName="${TokenName//$DoubleQuotes/$NoQuotes}"
						AuthToken=$(echo $THEACTUALSECRETS | jq -c ".K8sMN.Cluster.E2E[0].AuthToken?")
						AuthToken="${AuthToken//$DoubleQuotes/$NoQuotes}"
						SSHKey=$(echo $THEACTUALSECRETS | jq -c ".K8sMN.Cluster.E2E[0].SSHKey?")
						SSHKey="${SSHKey//$DoubleQuotes/$NoQuotes}"
						if [ "$APIKey" == "null" ] || [ "$APIKey" = "" ] ; then
							echo '-----------------------'					
							echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'APIKey' Missing In '$NODES_JSON' For Terminal => $Terminal"
							echo '-----------------------'
							echo ''
							exit
						fi
						if [ "$TokenName" == "null" ] || [ "$TokenName" = "" ] ; then
							echo '-----------------------'					
							echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'TokenName' Missing In '$NODES_JSON' For Terminal => $Terminal"
							echo '-----------------------'
							echo ''
							exit
						fi
						if [ "$AuthToken" == "null" ] || [ "$AuthToken" = "" ] ; then
							echo '-----------------------'					
							echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'AuthToken' Missing In '$NODES_JSON' For Terminal => $Terminal"
							echo '-----------------------'
							echo ''
							exit
						fi
						if [ "$SSHKey" == "null" ] || [ "$SSHKey" = "" ] ; then
							echo '-----------------------'					
							echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'SSHKey' Missing In '$NODES_JSON' For Terminal => $Terminal"
							echo '-----------------------'
							echo ''
							exit 
						fi
						GlobalE2EPEMFile="$BASE/Repo/Matsya-SetUp-SSHE2E.pem"
						sudo chown $CURRENTUSER:$CURRENTUSER $GlobalE2EPEMFile
						sudo chmod 400 $GlobalE2EPEMFile
						E2EMatsyaUserCreationCode=""
						if [ $TerminalTheRqOS == "E2E7" ] || [ $TerminalTheRqOS == "E2E8" ] ; then
							E2EMatsyaUserCreationCode="sudo useradd -d /home/matsya -s /bin/bash -m matsya && sudo usermod -p \$(echo \"$GlobalE2EPassword\" | openssl passwd -1 -stdin) matsya && sudo usermod -aG wheel matsya && sudo rm -f /etc/sudoers.d/matsya-user && echo \"matsya ALL=(ALL) NOPASSWD:ALL\" | sudo tee /etc/sudoers.d/matsya-user > /dev/null && sudo sed -i -e s~\"PasswordAuthentication\"~\"#PasswordAuthentication\"~g /etc/ssh/sshd_config && sudo sed -i -e s~\"PermitRootLogin\"~\"#PermitRootLogin\"~g /etc/ssh/sshd_config && echo \"PasswordAuthentication yes\" | sudo tee -a /etc/ssh/sshd_config > /dev/null && sudo systemctl restart sshd.service && sudo rm -rf /root/.ssh/authorized_keys"
						fi
						if [ $TerminalTheRqOS == "E2ED" ] || [ $TerminalTheRqOS == "E2EU" ] ; then
							E2EMatsyaUserCreationCode="sudo useradd -d /home/matsya -s /bin/bash -m matsya && sudo usermod -p \$(echo \"$GlobalE2EPassword\" | openssl passwd -1 -stdin) matsya && sudo usermod -aG sudo matsya && sudo rm -f /etc/sudoers.d/matsya-user && echo \"matsya ALL=(ALL) NOPASSWD:ALL\" | sudo tee /etc/sudoers.d/matsya-user > /dev/null && sudo sed -i -e s~\"PasswordAuthentication\"~\"#PasswordAuthentication\"~g /etc/ssh/sshd_config && sudo sed -i -e s~\"PermitRootLogin\"~\"#PermitRootLogin\"~g /etc/ssh/sshd_config && echo \"PasswordAuthentication yes\" | sudo tee -a /etc/ssh/sshd_config > /dev/null && sudo systemctl restart sshd.service && sudo rm -rf /root/.ssh/authorized_keys"
						fi
						
						echo -e "${RED}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
						echo -e "${BOLD}\x1b[3m\x1b[30;44m    ROUGE E2E PLANETARY SYSTEM ENCOUNTERED    \x1b[m${NORM}${BLUE}${BOLD}"
						echo -e "${RED}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
						echo ''
						echo -e "${GREEN}Kryptonian${NC}  : \x1b[3mOrders Sir !!"
						echo ''
						sleep 2						
						echo -e "${GREEN}General Zod${NC} : Release The World Engine"
						sleep 2						
						echo -e "              Bring The Phantom Drive Online"
						sleep 2						
						echo -e "${RED}${BOLD}              INITIATE TERRAFORMING${NORM}${NC}"
						sleep 1						
						echo ''
						echo -e "              \x1b[3m\x1b[4mhttp://bit.ly/InitiateTerraform"
						echo ''						
						sleep 1
						echo -e "${RED}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
						echo ''
						
						sudo rm -rf $BASE/tmp/*
						sudo rm -rf /home/$CURRENTUSER/.ssh/known_hosts
						
						STARTPOINT=1
						STARTPOINT="$(($STARTPOINT + 0))"
						ENDPOINT="$(($CHECKIFRANGEISPRESENT + 0))"
						THENEWIP=""
						THENEWTERMINALNAME=""
						E2ERESPONSE=""				
						for((TCounter=STARTPOINT;TCounter<=ENDPOINT;TCounter++))
						do												
							echo -e "${PURPLE}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
							RANDOMINSTANCENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
							RANDOMRESPONSEFILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
							RANDOMINSTANCENEWNAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)								
							sudo cp $BASE/Repo/Matsya-SetUp-E2ENewTerminal $BASE/tmp/$RANDOMINSTANCENAME
							sudo chmod 777 $BASE/tmp/$RANDOMINSTANCENAME 
							
							THEACTUALREGION="$THEREGION"
							E2ETHEVMLOCATION="Delhi"
							if [ "$THEREGION" == "mumbai" ] ; then
								CityReplace="DISK-MUM"
								THEFAMILY="${THEFAMILY/DISK/$CityReplace}"
								THEACTUALREGION="ncr"
								E2ETHEVMLOCATION="Mumbai"
							fi
							
							sed -i -e s~"E2ETHEAPIKEY"~"$APIKey"~g $BASE/tmp/$RANDOMINSTANCENAME
							sed -i -e s~"E2ETHEVMLOCATION"~"$E2ETHEVMLOCATION"~g $BASE/tmp/$RANDOMINSTANCENAME
							sed -i -e s~"E2ETHEAUTHTOKEN"~"$AuthToken"~g $BASE/tmp/$RANDOMINSTANCENAME
							sed -i -e s~"E2ETHETOKENNAME"~"$TokenName"~g $BASE/tmp/$RANDOMINSTANCENAME
							sed -i -e s~"E2ETHENAMEOFINSTANCE"~"$RANDOMINSTANCENAME"~g $BASE/tmp/$RANDOMINSTANCENAME
							sed -i -e s~"E2ETHEREGION"~"$THEACTUALREGION"~g $BASE/tmp/$RANDOMINSTANCENAME
							sed -i -e s~"E2ETHEPLAN"~"$THEFAMILY"~g $BASE/tmp/$RANDOMINSTANCENAME
							sed -i -e s~"E2ETHEDISTRO"~"$CHECKIFTHEDISTROISPRESENT"~g $BASE/tmp/$RANDOMINSTANCENAME
							sed -i -e s~"E2ETHESSHKEYS"~"$SSHKey"~g $BASE/tmp/$RANDOMINSTANCENAME
							sed -i -e s~"E2ETHEPLACETOSAVERESPONSE"~"$BASE/tmp/$RANDOMRESPONSEFILE"~g $BASE/tmp/$RANDOMINSTANCENAME
							(
								set -Ee
								function _catch {
									echo "ERROR"
									exit 0
								}
								function _finally {
									ABC="XYZ"
								}
								trap _catch ERR
								trap _finally EXIT
								sudo $BASE/tmp/$RANDOMINSTANCENAME								
							)
							E2ERESPONSE=$(<$BASE/tmp/$RANDOMRESPONSEFILE)							
							E2ECODE=$(echo $E2ERESPONSE | jq -c ".code")
							E2ECODE="${E2ECODE//$DoubleQuotes/$NoQuotes}"
							if [ "$E2ECODE" == "200" ] || [ "$E2ECODE" = "200" ] ; then
								E2EMESSAGE=$(echo $E2ERESPONSE | jq -c ".message")
								E2EMESSAGE="${E2EMESSAGE//$DoubleQuotes/$NoQuotes}"
								if [ "$E2EMESSAGE" == "Success" ] || [ "$E2EMESSAGE" = "Success" ] ; then
									E2EINSTANCEID=$(echo $E2ERESPONSE | jq -c ".data.id")
									E2EINSTANCEID="${E2EINSTANCEID//$DoubleQuotes/$NoQuotes}"
									E2EINSTANCEIP=$(echo $E2ERESPONSE | jq -c ".data.public_ip_address")
									E2EINSTANCEIP="${E2EINSTANCEIP//$DoubleQuotes/$NoQuotes}"
									IFS='.' read -r -a IPAddressPieces <<< $E2EINSTANCEIP							
									THENEWIP=$THENEWIP"$E2EINSTANCEIP¬"
									THENEWNAME="$Terminal-""${IPAddressPieces[0]}""-""${IPAddressPieces[1]}""-""${IPAddressPieces[2]}""-"${IPAddressPieces[3]}"-"$(echo "$TerminalTheRqOS" | tr '[:upper:]' '[:lower:]')"-$E2EINSTANCEID""-"$(echo "$THEREGION" | tr '[:upper:]' '[:lower:]')".cluster"
									THENEWNAME2="$Terminal-""${IPAddressPieces[0]}""-""${IPAddressPieces[1]}""-""${IPAddressPieces[2]}""-"${IPAddressPieces[3]}"-"$TerminalTheRqOS"-$E2EINSTANCEID""-"$(echo "$THEREGION" | tr '[:lower:]' '[:upper:]')
									THENEWTERMINALNAME=$THENEWTERMINALNAME$THENEWNAME"¬"
									echo -e "${PURPLE}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
									echo -e "${GREEN}Kryptonian${NC}  : ${YELLOW}\x1b[3m$THENEWNAME ($E2EINSTANCEIP) Is Now Slave To The World Engine...${NC}"
									sudo cp $BASE/Repo/Matsya-SetUp-E2ENameTerminal $BASE/tmp/$RANDOMINSTANCENEWNAME
									sudo chmod 777 $BASE/tmp/$RANDOMINSTANCENEWNAME 
									sed -i -e s~"E2ETHEAPIKEY"~"$APIKey"~g $BASE/tmp/$RANDOMINSTANCENEWNAME
									sed -i -e s~"E2ETHEAUTHTOKEN"~"$AuthToken"~g $BASE/tmp/$RANDOMINSTANCENEWNAME
									sed -i -e s~"E2ETHENEWNODEID"~"$E2EINSTANCEID"~g $BASE/tmp/$RANDOMINSTANCENEWNAME
									sed -i -e s~"E2ETHENEWNODENAME"~"$THENEWNAME2"~g $BASE/tmp/$RANDOMINSTANCENEWNAME
									echo -e "${PURPLE}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
									(
										set -Ee
										function _catch {
											echo "ERROR"
											exit 0
										}
										function _finally {
											ABC="XYZ"
										}
										trap _catch ERR
										trap _finally EXIT
										sudo $BASE/tmp/$RANDOMINSTANCENEWNAME								
									)
									echo -e "${PURPLE}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
									echo -e "${GREEN}Kryptonian${NC}  : ${YELLOW}\x1b[3mHarvesting Resources...${NC}"
									echo -e "${PURPLE}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
									TempCounter=0
									while [ $TempCounter -lt 1 ]
									do
										THEFIRSTCONNECTE2E=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
										touch $BASE/tmp/$THEFIRSTCONNECTE2E	
										sudo chmod 777 $BASE/tmp/$THEFIRSTCONNECTE2E
																				
										(
										set -Ee
										function _catch {
											echo "ERROR"
											exit 0
										}
										function _finally {
											ABC="XYZ"
										}
										trap _catch ERR
										trap _finally EXIT
										THERESPONSE=$(ssh -o ConnectTimeout=15 -o BatchMode=yes -o PasswordAuthentication=no root@$E2EINSTANCEIP -p $TerminalSSHPort -o "StrictHostKeyChecking=no" -i $GlobalE2EPEMFile "echo \"$THEFIRSTCONNECTE2E\"")
										echo "$THERESPONSE" >> $BASE/tmp/$THEFIRSTCONNECTE2E		
										)
										
										THERESULT="NO"
										LINE=$(<$BASE/tmp/$THEFIRSTCONNECTE2E)
										if [ "$LINE" == "$THEFIRSTCONNECTE2E" ] || [ "$LINE" == "$THEFIRSTCONNECTE2E" ] ; then										
										E2EHOSTDETAILSETUP="sudo systemctl stop one-context && sudo systemctl disable one-context && sudo rm -rf /etc/hosts && sudo rm -rf /etc/hostname && echo \"
127.0.0.1 localhost
# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
$E2EINSTANCEIP	$THENEWNAME
\" | sudo tee -a /etc/hosts > /dev/null && echo \"$THENEWNAME\" | sudo tee -a /etc/hostname > /dev/null"										
											ssh -o ConnectTimeout=15 -o BatchMode=yes -o PasswordAuthentication=no root@$E2EINSTANCEIP -p $TerminalSSHPort -o "StrictHostKeyChecking=no" -i $GlobalE2EPEMFile "$E2EHOSTDETAILSETUP"
											ssh -o ConnectTimeout=15 -o BatchMode=yes -o PasswordAuthentication=no root@$E2EINSTANCEIP -p $TerminalSSHPort -o "StrictHostKeyChecking=no" -i $GlobalE2EPEMFile "$E2EMatsyaUserCreationCode"
											echo -e "${PURPLE}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
											echo -e "${GREEN}Kryptonian${NC}  : ${YELLOW}${BOLD}\x1b[3mTerraforming Complete${NORM}${NC}"
											sudo rm -rf $BASE/tmp/$THEFIRSTCONNECTE2E
											TempCounter=$((TempCounter + 1))
											THERESULT="YES"
											E2EALLOCATIONHAPPENED="YES"
										else
											sudo rm -rf $BASE/tmp/$THEFIRSTCONNECTE2E									
										fi
										if [ "$THERESULT" == "NO" ] || [ "$THERESULT" == "NO" ] ; then
											sleep 10
										fi
									done									
									echo -e "${PURPLE}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
									echo ''								
								else
									echo -e "${PURPLE}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
									echo -e "${GREEN}Kryptonian${NC}  : ${RED}${BOLD}\x1b[3mKal-El Destroyed The World Engine !!!${NORM}${NC}"
									echo -e "            : $E2ERESPONSE"									
									echo -e "${PURPLE}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
									echo ''
								fi	 
							else
									echo -e "${PURPLE}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
									echo -e "${GREEN}Kryptonian${NC}  : ${RED}${BOLD}\x1b[3mKal-El Destroyed The World Engine !!!${NORM}${NC}"
									echo -e "            : $E2ERESPONSE"									
									echo -e "${PURPLE}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
									echo ''
							fi
							sudo rm -rf $BASE/tmp/$RANDOMINSTANCENAME
							sudo rm -rf $BASE/tmp/$RANDOMRESPONSEFILE
							sudo rm -rf $BASE/tmp/$RANDOMINSTANCENEWNAME
						done
						FINAL_BEFORE_CONNECT_TERMINAL_LIST+=("$THENEWTERMINALNAME├$THENEWIP├$TerminalUserName¬$GlobalE2EPassword├$TerminalSSHPort├$TerminalTheRqOS├$TerminalTheRqBase├$TerminalTheRqLocation")						
						echo -e "${RED}¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬${NC}"
						echo ''				
					fi
				fi											
			fi																						
		fi
	done
	
	sudo mkdir -p $BASE/tmp
	sudo chmod -R 777 $BASE/tmp
	SECRETSAVAILABLE=""
	THESECRETSFILE=$(jq '.K8sMN.Cluster.Terminal[0].SecretsFileLocation' $NODES_JSON)
	THESECRETSFILE="${THESECRETSFILE//$DoubleQuotes/$NoQuotes}"
	if [ "$THESECRETSFILE" == "" ] || [ "$THESECRETSFILE" == "" ] ; then
		SECRETSAVAILABLE="NO"
	else
		SECRETSAVAILABLE="YES"
		if [ -f "$THESECRETSFILE" ]
		then
			ABC="XYZ"
		else
			echo '-----------------------'					
			echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mSecret File Missing !!"
			echo '-----------------------'
			echo ''
			exit
		fi				
		echo '-----------------------'
		if [ "$THESECRETKEY" == "null" ] || [ "$THESECRETKEY" = "" ] ; then		
			echo ''		
			read -s -p "Enter Secret Key > " -e -i "" THESECRETKEY
			echo ''	
			ITER=${THESECRETKEY:7:6}
			RANDOMSECFILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $THESECRETSFILE $BASE/tmp/$RANDOMSECFILENAME
			sudo chown $CURRENTUSER:$CURRENTUSER $BASE/tmp/$RANDOMSECFILENAME
			sudo chmod u=r,g=,o= $BASE/tmp/$RANDOMSECFILENAME
			REALSECRETSFILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			openssl enc -a -d -aes-256-cbc -pbkdf2 -iter $ITER -k $THESECRETKEY -in $BASE/tmp/$RANDOMSECFILENAME -out $BASE/tmp/$REALSECRETSFILENAME
			sudo chown $CURRENTUSER:$CURRENTUSER $BASE/tmp/$REALSECRETSFILENAME
			sudo chmod u=r,g=,o= $BASE/tmp/$REALSECRETSFILENAME
			THEACTUALSECRETS=$(<$BASE/tmp/$REALSECRETSFILENAME)		
			sudo rm -rf $BASE/tmp/$REALSECRETSFILENAME				
			sudo rm -rf $BASE/tmp/$RANDOMSECFILENAME
		fi		
	fi	
				
	GLOBALPASSWORD=""		
	if [ $AUTHMODE == "PASSWORD" ] || [ $AUTHMODE == "PASSWORD" ] ; then
		ISSAMEPASSWORD=$(jq '.K8sMN.Cluster.Terminal[0].IsSamePassword' $NODES_JSON)
		ISSAMEPASSWORD="${ISSAMEPASSWORD//$DoubleQuotes/$NoQuotes}"
		if [ $ISSAMEPASSWORD == "YES" ] || [ $ISSAMEPASSWORD == "YES" ] ; then
			if [ $SECRETSAVAILABLE == "YES" ] || [ $SECRETSAVAILABLE == "YES" ] ; then
				xx1234=$(echo $THEACTUALSECRETS | jq -c ".K8sMN.Cluster.Terminal[0].SamePassword?")
				xx1234="${xx1234//$DoubleQuotes/$NoQuotes}"
				if [ "$xx1234" == "null" ] || [ "$xx1234" = "" ] ; then
					echo ''				
					echo '-----------------------'					
					echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'SamePassword' Missing In Secret File !!"
					echo '-----------------------'
					echo ''
					exit
				else
					GLOBALPASSWORD="$xx1234"							
				fi								
			fi
			if [ "$GLOBALPASSWORD" == "" ] || [ "$GLOBALPASSWORD" == "" ] ; then
				echo '-----------------------'
				echo ''		
				read -s -p "Enter Password For All Terminals > " -e -i "" GLOBALPASSWORD
				echo ''
			fi
			THECOUNTKEEPER=0
			for((j=0;j<$TerminalsCount;j++))
			do
				CHECKIFTOOMIT=$(jq '.K8sMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
				CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
				if [ "$CHECKIFTOOMIT" == "null" ] || [ "$CHECKIFTOOMIT" == "" ] ; then
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]}'├PASSWORD├'$GLOBALPASSWORD
					THECOUNTKEEPER=$((THECOUNTKEEPER + 1))
				fi		
			done
			THECOUNTKEEPER=0
			echo ''
			echo '-----------------------'
			echo ''									
		else
			if [ $SECRETSAVAILABLE == "NO" ] || [ $SECRETSAVAILABLE == "NO" ] ; then
				echo '-----------------------'
				echo ''
			fi		
			THECOUNTKEEPER=0
			for((j=0;j<$TerminalsCount;j++))
			do
				CHECKIFTOOMIT=$(jq '.K8sMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
				CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
				if [ "$CHECKIFTOOMIT" == "null" ] || [ "$CHECKIFTOOMIT" == "" ] ; then
					Terminal=$(jq '.K8sMN.Cluster.Terminals['${j}'].HostName' $NODES_JSON)
					Terminal="${Terminal//$DoubleQuotes/$NoQuotes}"
					TerminalIP=$(jq '.K8sMN.Cluster.Terminals['${j}'].IPAddress' $NODES_JSON)
					TerminalIP="${TerminalIP//$DoubleQuotes/$NoQuotes}"				
					TEMPPASSWORD=""
					if [ $SECRETSAVAILABLE == "YES" ] || [ $SECRETSAVAILABLE == "YES" ] ; then
						TerminalsInnerCount=$(echo $THEACTUALSECRETS | jq -c ".K8sMN.Cluster.Terminals | length")
						for((i=0;i<TerminalsInnerCount;i++))
						do
							xx1234=$(echo $THEACTUALSECRETS | jq -c '.K8sMN.Cluster.Terminals['${i}'].IPAddress?')
							xx1234="${xx1234//$DoubleQuotes/$NoQuotes}"
							if [ "$xx1234" == "null" ] || [ "$xx1234" = "" ] ; then
								echo ''
								echo '-----------------------'					
								echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'IPAddress' Missing In Secret File For Terminal => $Terminal ($TerminalIP)"
								echo '-----------------------'
								echo ''
								exit
							fi
							xx12534=$(echo $THEACTUALSECRETS | jq -c '.K8sMN.Cluster.Terminals['${i}'].Password?')
							xx12534="${xx12534//$DoubleQuotes/$NoQuotes}"
							if [ "$xx12534" == "null" ] || [ "$xx12534" = "" ] ; then
								echo ''
								echo '-----------------------'					
								echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'Password' Missing In Secret File For Terminal => $Terminal ($TerminalIP)"
								echo '-----------------------'
								echo ''
								exit
							fi
							if [ "$xx1234" == "$Terminal" ] || [ "$xx1234" = "$Terminal" ] ; then
								TEMPPASSWORD="$xx12534"
								break
							else
								TEMPPASSWORD="NA"
							fi
						done						
					else					
						read -s -p "Enter Password For => $Terminal ($TerminalIP) > " -e -i "" TEMPPASSWORD
						echo ''
					fi
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
			if [ $SECRETSAVAILABLE == "YES" ] || [ $SECRETSAVAILABLE == "YES" ] ; then
				xx1234=$(echo $THEACTUALSECRETS | jq -c ".K8sMN.Cluster.Terminal[0].SamePEM?")
				xx1234="${xx1234//$DoubleQuotes/$NoQuotes}"
				if [ "$xx1234" == "null" ] || [ "$xx1234" = "" ] ; then
					echo ''
					echo '-----------------------'					
					echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'SamePEM' Missing In Secret File !!"
					echo '-----------------------'
					echo ''
					exit
				else
					GLOBALPEM="$xx1234"
					echo ''							
				fi								
			fi
			if [ "$GLOBALPEM" == "" ] || [ "$GLOBALPEM" == "" ] ; then		
				echo '-----------------------'
				echo ''		
				read -p "Enter .pem File Location For All Terminals > " -e -i "" GLOBALPEM
				echo ''
			fi
			THECOUNTKEEPER=0
			for((j=0;j<$TerminalsCount;j++))
			do
				CHECKIFTOOMIT=$(jq '.K8sMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
				CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
				if [ "$CHECKIFTOOMIT" == "null" ] || [ "$CHECKIFTOOMIT" == "" ] ; then
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]}'├PEM├'$GLOBALPEM
					THECOUNTKEEPER=$((THECOUNTKEEPER + 1))
				fi		
			done
			THECOUNTKEEPER=0
			echo '-----------------------'
			echo ''			
		else
			if [ $SECRETSAVAILABLE == "NO" ] || [ $SECRETSAVAILABLE == "NO" ] ; then
				echo '-----------------------'
				echo ''
			fi
			THECOUNTKEEPER=0
			for((j=0;j<$TerminalsCount;j++))
			do
				CHECKIFTOOMIT=$(jq '.K8sMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
				CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
				if [ "$CHECKIFTOOMIT" == "null" ] || [ "$CHECKIFTOOMIT" == "" ] ; then			
					Terminal=$(jq '.K8sMN.Cluster.Terminals['${j}'].HostName' $NODES_JSON)
					Terminal="${Terminal//$DoubleQuotes/$NoQuotes}"
					TerminalIP=$(jq '.K8sMN.Cluster.Terminals['${j}'].IPAddress' $NODES_JSON)
					TerminalIP="${TerminalIP//$DoubleQuotes/$NoQuotes}"
					TEMPPEM=""
					if [ $SECRETSAVAILABLE == "YES" ] || [ $SECRETSAVAILABLE == "YES" ] ; then
						TerminalsInnerCount=$(echo $THEACTUALSECRETS | jq -c ".K8sMN.Cluster.Terminals | length")
						for((i=0;i<TerminalsInnerCount;i++))
						do
							xx1234=$(echo $THEACTUALSECRETS | jq -c '.K8sMN.Cluster.Terminals['${i}'].IPAddress?')
							xx1234="${xx1234//$DoubleQuotes/$NoQuotes}"
							if [ "$xx1234" == "null" ] || [ "$xx1234" = "" ] ; then
								echo ''
								echo '-----------------------'					
								echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'IPAddress' Missing In Secret File For Terminal => $Terminal ($TerminalIP)"
								echo '-----------------------'
								echo ''
								exit
							fi
							xx12534=$(echo $THEACTUALSECRETS | jq -c '.K8sMN.Cluster.Terminals['${i}'].PEM?')
							xx12534="${xx12534//$DoubleQuotes/$NoQuotes}"
							if [ "$xx12534" == "null" ] || [ "$xx12534" = "" ] ; then
								echo ''
								echo '-----------------------'					
								echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'PEM' Missing In Secret File For Terminal => $Terminal ($TerminalIP)"
								echo '-----------------------'
								echo ''
								exit
							fi
							if [ "$xx1234" == "$Terminal" ] || [ "$xx1234" = "$Terminal" ] ; then
								TEMPPEM="$xx12534"
								break
							else
								TEMPPEM="NA"
							fi
						done						
					else					
						read -p "Enter .pem File Location For => $Terminal ($TerminalIP) > " -e -i "" TEMPPEM
					fi													
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
		if [ $SECRETSAVAILABLE == "NO" ] || [ $SECRETSAVAILABLE == "NO" ] ; then
			echo '-----------------------'
			echo ''
		fi
		THECOUNTKEEPER=0
		for((j=0;j<$TerminalsCount;j++))
		do
			CHECKIFTOOMIT=$(jq '.K8sMN.Cluster.Terminals['${j}'].OMIT?' $NODES_JSON)
			CHECKIFTOOMIT="${CHECKIFTOOMIT//$DoubleQuotes/$NoQuotes}"
			if [ "$CHECKIFTOOMIT" == "null" ] || [ "$CHECKIFTOOMIT" == "" ] ; then			
				Terminal=$(jq '.K8sMN.Cluster.Terminals['${j}'].HostName' $NODES_JSON)
				Terminal="${Terminal//$DoubleQuotes/$NoQuotes}"
				TerminalIP=$(jq '.K8sMN.Cluster.Terminals['${j}'].IPAddress' $NODES_JSON)
				TerminalIP="${TerminalIP//$DoubleQuotes/$NoQuotes}"
				TEMPACCESS="NA"
				TEMPTYPEACCESS="NA"
				CHECKIFAUTHMODEMISSING=$(jq '.K8sMN.Cluster.Terminals['${j}'].AuthMode?' $NODES_JSON)
				CHECKIFAUTHMODEMISSING="${CHECKIFAUTHMODEMISSING//$DoubleQuotes/$NoQuotes}"
				if [ $CHECKIFAUTHMODEMISSING == "null" ] || [ $CHECKIFAUTHMODEMISSING == "null" ] ; then
					echo '-----------------------'
					echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'AuthMode' Missing In '$NODES_JSON' For Terminal => $Terminal ($TerminalIP)"				
					echo '-----------------------'
					echo ''										
					exit				
				fi
				if [ $SECRETSAVAILABLE == "YES" ] || [ $SECRETSAVAILABLE == "YES" ] ; then
					TerminalsInnerCount=$(echo $THEACTUALSECRETS | jq -c ".K8sMN.Cluster.Terminals | length")
					for((i=0;i<TerminalsInnerCount;i++))
					do
						xx1234=$(echo $THEACTUALSECRETS | jq -c '.K8sMN.Cluster.Terminals['${i}'].IPAddress?')
						xx1234="${xx1234//$DoubleQuotes/$NoQuotes}"
						if [ "$xx1234" == "null" ] || [ "$xx1234" = "" ] ; then
							echo ''
							echo '-----------------------'					
							echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'IPAddress' Missing In Secret File For Terminal => $Terminal ($TerminalIP)"
							echo '-----------------------'
							echo ''
							exit
						fi
						if [ "$CHECKIFAUTHMODEMISSING" == "PEM" ] || [ "$CHECKIFAUTHMODEMISSING" == "PEM" ] ; then
							xx12534=$(echo $THEACTUALSECRETS | jq -c '.K8sMN.Cluster.Terminals['${i}'].PEM?')
							xx12534="${xx12534//$DoubleQuotes/$NoQuotes}"
							if [ "$xx1234" == "$Terminal" ] || [ "$xx1234" = "$Terminal" ] ; then
								if [ "$xx12534" == "null" ] || [ "$xx12534" = "" ] ; then
									echo ''
									echo '-----------------------'					
									echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'PEM' Missing In Secret File For Terminal => $Terminal ($TerminalIP)"
									echo '-----------------------'
									echo ''
									exit
								fi
							fi
							if [ "$xx1234" == "$Terminal" ] || [ "$xx1234" = "$Terminal" ] ; then
								TEMPACCESS="$xx12534"
								TEMPTYPEACCESS="PEM"
								break
							else
								TEMPACCESS="NA"
								TEMPTYPEACCESS="PEM"								
							fi
						fi
						if [ "$CHECKIFAUTHMODEMISSING" == "PASSWORD" ] || [ "$CHECKIFAUTHMODEMISSING" == "PASSWORD" ] ; then
							xx12534=$(echo $THEACTUALSECRETS | jq -c '.K8sMN.Cluster.Terminals['${i}'].Password?')
							xx12534="${xx12534//$DoubleQuotes/$NoQuotes}"
							if [ "$xx1234" == "$Terminal" ] || [ "$xx1234" = "$Terminal" ] ; then
								if [ "$xx12534" == "null" ] || [ "$xx12534" = "" ] ; then
									echo ''
									echo '-----------------------'					
									echo -e "${RED}${BOLD}\x1b[5mERROR !!! > ${NORM}${NC}\x1b[3mProperty 'Password' Missing In Secret File For Terminal => $Terminal ($TerminalIP)"
									echo '-----------------------'
									echo ''
									exit
								fi
							fi
							if [ "$xx1234" == "$Terminal" ] || [ "$xx1234" = "$Terminal" ] ; then
								TEMPACCESS="$xx12534"
								TEMPTYPEACCESS="PASSWORD"
								break
							else
								TEMPACCESS="NA"
								TEMPTYPEACCESS="PASSWORD"								
							fi
						fi												
					done
					TEMPACCESS=$TEMPTYPEACCESS'├'$TEMPACCESS
					FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]=${FINAL_BEFORE_CONNECT_TERMINAL_LIST[${THECOUNTKEEPER}]}'├'$TEMPACCESS
					THECOUNTKEEPER=$((THECOUNTKEEPER + 1))											
				else					
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
			fi
		done
		THECOUNTKEEPER=0
		echo ''
		echo '-----------------------'	
		echo ''	
	fi
	
	FINAL_BEFORE_CONNECT_TERMINAL_LIST_BCK=("${FINAL_BEFORE_CONNECT_TERMINAL_LIST[@]}")
	FINAL_BEFORE_CONNECT_TERMINAL_LIST=()
	for Terminal in "${FINAL_BEFORE_CONNECT_TERMINAL_LIST_BCK[@]}"
	do
		SUB='¬'
		if [[ "$Terminal" == *"$SUB"* ]]; then
			IFS='├' read -r -a TerminalVals <<< $Terminal
			
			THEVAL0="${TerminalVals[0]}"
			IFS='¬' read -r -a THEVAL0Vals <<< $THEVAL0
			
			THEVAL1="${TerminalVals[1]}"
			IFS='¬' read -r -a THEVAL1Vals <<< $THEVAL1
			
			THEVAL2="${TerminalVals[2]}"
			THEVAL3="${TerminalVals[3]}"
			THEVAL4="${TerminalVals[4]}"
			THEVAL5="${TerminalVals[5]}"
			THEVAL6="${TerminalVals[6]}"
			THEVAL7="${TerminalVals[7]}"
			THEVAL8="${TerminalVals[8]}"
			
			if [ "$E2EALLOCATIONHAPPENED" == "YES" ] || [ "$E2EALLOCATIONHAPPENED" == "YES" ] ; then
				if [ "$THEVAL8" == "AUTO" ] || [ "$THEVAL8" == "AUTO" ] ; then
					IFS='¬' read -r -a THEVAL2Vals <<< $THEVAL2
					THEVAL2="${THEVAL2Vals[0]}"
					THEVAL8="${THEVAL2Vals[1]}"
				fi			
			fi
			
			VCount=0
			for V in "${THEVAL0Vals[@]}"
			do
				if [ "$V" == "" ] || [ "$V" == "" ] ; then
					ABC='XYZ'
				else
					THEIP="${THEVAL1Vals[${VCount}]}"
					FINAL_BEFORE_CONNECT_TERMINAL_LIST+=("$V├$THEIP├$THEVAL2├$THEVAL3├$THEVAL4├$THEVAL5├$THEVAL6├$THEVAL7├$THEVAL8")
					VCount=$((VCount + 1))
				fi	
			done												
		else
			FINAL_BEFORE_CONNECT_TERMINAL_LIST+=("$Terminal")		
		fi			
	done
	
	sudo rm -rf /home/$CURRENTUSER/.ssh/known_hosts
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
		if [ "$THEREQUIREDIP" == "null" ] || [ "$THEREQUIREDIP" = "" ] ; then
			THEREQUIREDIP=$THEREQUIREDHOSTNAME
		fi		
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
		if [ "$THEREQUIREDAUTH" == "PASSWORD" ] || [ "$THEREQUIREDAUTH" == "PASSWORD" ] ; then
			THERESPONSE=$(sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT  -o "StrictHostKeyChecking=no" "echo \"$RANDOMFOLDERNAME\"")
			echo "$Terminal├$THERESPONSE" >> $RANDOMFOLDERNAME		
		fi
		if [ "$THEREQUIREDAUTH" == "PEM" ] || [ "$THEREQUIREDAUTH" == "PEM" ] ; then
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
		if [ "$THEREQUIREDIP" == "null" ] || [ "$THEREQUIREDIP" = "" ] ; then
			THEREQUIREDIP=""
		else
			THEREQUIREDIP=" ($THEREQUIREDIP)"
		fi				
		echo "($COUNTERe) $THEREQUIREDHOSTNAME$THEREQUIREDIP"
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
			if [ "$THEREQUIREDIP" == "null" ] || [ "$THEREQUIREDIP" = "" ] ; then
				ABC="XYZ"
			else
				echo "sudo sed -i -e s~\"$THEREQUIREDIP\"~\"#$THEREQUIREDIP\"~g /etc/hosts > /dev/null" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/ListOfHosts > /dev/null
				echo "echo '$THEREQUIREDIP	$THEREQUIREDHOSTNAME' | sudo tee -a /etc/hosts > /dev/null" | sudo tee -a $BASE/K8sMN/$CLUSTERNAME/ListOfHosts > /dev/null
			fi											 
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
			THENAMETOBESHOWN=""
			if [ "$THEREQUIREDIP" == "null" ] || [ "$THEREQUIREDIP" = "" ] ; then
				THEREQUIREDIP=$THEREQUIREDHOSTNAME
				THENAMETOBESHOWN=""
			else
				THENAMETOBESHOWN=" ($THEREQUIREDIP)"
			fi			
			echo ''
			echo '~~~~~~~~~~~~~~~~~~~~~~~'
			echo "$THEREQUIREDHOSTNAME$THENAMETOBESHOWN"
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
			sudo sed -i s#USERSELIGIBLE#"$THEREQUIREDUSER├$RANDOMUSERNAME"#g $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME		
			sudo chmod 777 $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME
			
			RND1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostAddTemplate $BASE/K8sMN/$CLUSTERNAME/$RND1
			
			RND2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostExecTemplate $BASE/K8sMN/$CLUSTERNAME/$RND2
			sudo chmod 777 $BASE/K8sMN/$CLUSTERNAME/$RND2
			sudo sed -i s#THENAMEOFTHEUSER#$RANDOMUSERNAME#g $BASE/K8sMN/$CLUSTERNAME/$RND2
			sudo sed -i s#OSNAMETOBEUSED#$THEREQUIREDOS#g $BASE/K8sMN/$CLUSTERNAME/$RND2
			sudo sed -i s#BASENAMETOBEUSED#$THEREQUIREDBASE#g $BASE/K8sMN/$CLUSTERNAME/$RND2
			sudo sed -i s#CLUSTERNAMETOBEUSED#$CLUSTERNAME#g $BASE/K8sMN/$CLUSTERNAME/$RND2
			sudo sed -i s#USERSELIGIBLE#"$THEREQUIREDUSER├$RANDOMUSERNAME"#g $BASE/K8sMN/$CLUSTERNAME/$RND2			
			
			RND3=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostKillTemplate $BASE/K8sMN/$CLUSTERNAME/$RND3
			
			RND5=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostPushTemplate $BASE/K8sMN/$CLUSTERNAME/$RND5
			sudo chmod 777 $BASE/K8sMN/$CLUSTERNAME/$RND5
			sudo sed -i s#THENAMEOFTHEUSER#$RANDOMUSERNAME#g $BASE/K8sMN/$CLUSTERNAME/$RND5
			sudo sed -i s#OSNAMETOBEUSED#$THEREQUIREDOS#g $BASE/K8sMN/$CLUSTERNAME/$RND5
			sudo sed -i s#BASENAMETOBEUSED#$THEREQUIREDBASE#g $BASE/K8sMN/$CLUSTERNAME/$RND5
			sudo sed -i s#CLUSTERNAMETOBEUSED#$CLUSTERNAME#g $BASE/K8sMN/$CLUSTERNAME/$RND5
			sudo sed -i s#USERSELIGIBLE#"$THEREQUIREDUSER├$RANDOMUSERNAME"#g $BASE/K8sMN/$CLUSTERNAME/$RND5					
			
			RND6=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostRemoveTemplate $BASE/K8sMN/$CLUSTERNAME/$RND6
			
			RND7=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
			sudo cp $BASE/Repo/Matsya-K8s-MultiNode-HostSyncTemplate $BASE/K8sMN/$CLUSTERNAME/$RND7
			sudo sed -i s#THENAMEOFTHEUSER#$RANDOMUSERNAME#g $BASE/K8sMN/$CLUSTERNAME/$RND7
			sudo sed -i s#OSNAMETOBEUSED#$THEREQUIREDOS#g $BASE/K8sMN/$CLUSTERNAME/$RND7
			sudo sed -i s#BASENAMETOBEUSED#$THEREQUIREDBASE#g $BASE/K8sMN/$CLUSTERNAME/$RND7
			sudo sed -i s#CLUSTERNAMETOBEUSED#$CLUSTERNAME#g $BASE/K8sMN/$CLUSTERNAME/$RND7
			sudo sed -i s#USERSELIGIBLE#"$THEREQUIREDUSER├$RANDOMUSERNAME"#g $BASE/K8sMN/$CLUSTERNAME/$RND7			
																						
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
					sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "chmod 777 $RANDOM2FILENAME && echo \"$THEREQUIREDACCESS\" | sudo -S ./$RANDOM2FILENAME && rm -rf $RANDOM2FILENAME"
					sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME	
				fi
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"$THEREQUIREDACCESS\" | sudo -S chmod -R u=rwx,g=,o= $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME && echo \"$THEREQUIREDACCESS\" | sudo -S chmod 0700 $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.ssh && echo \"$THEREQUIREDACCESS\" | sudo -S chmod 0644 $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.ssh/authorized_keys && echo \"$THEREQUIREDACCESS\" | sudo -S chown $RANDOMUSERNAME:$RANDOMUSERNAME $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.ssh/authorized_keys"
				if [ $SECRETSAVAILABLE == "YES" ] || [ $SECRETSAVAILABLE == "YES" ] ; then
					RANDOMSECFILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
					sudo cp $THESECRETSFILE $BASE/tmp/$RANDOMSECFILENAME
					sudo chmod 777 $BASE/tmp/$RANDOMSECFILENAME
					sshpass -p "$THEREQUIREDACCESS" scp -P $THEREQUIREDPORT $BASE/tmp/$RANDOMSECFILENAME $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"$THEREQUIREDACCESS\" | sudo -S mv $RANDOMSECFILENAME $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/.Secret && echo \"$THEREQUIREDACCESS\" | sudo -S chmod u=,g=,o= $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/.Secret"					
					sudo rm -rf $BASE/tmp/$RANDOMSECFILENAME
				fi				
				sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"$THEREQUIREDACCESS\" | sudo -S rm -rf /root/.bash_history && echo \"$THEREQUIREDACCESS\" | sudo -S rm -rf /home/$THEREQUIREDUSER/.bash_history && echo \"$THEREQUIREDACCESS\" | sudo -S rm -rf $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.bash_history"						
				if [ $THEREQUIREDOS == "E2E8" ] ; then
					sshpass -p "$THEREQUIREDACCESS" ssh -o ConnectTimeout=15 $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "echo \"nameserver 8.8.8.8\" | sudo tee -a /etc/resolv.conf > /dev/null && echo \"nameserver 8.8.4.4\" | sudo tee -a /etc/resolv.conf > /dev/null && sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl status docker && sudo docker run hello-world"
				fi
				echo ''
			fi
			if [ $THEREQUIREDAUTH == "PEM" ] || [ $THEREQUIREDAUTH == "PEM" ] ; then
				sudo rm -rf ThePemFile
				sudo cp $THEREQUIREDACCESS ThePemFile
				sudo chown $CURRENTUSER:$CURRENTUSER ThePemFile
				sudo chmod 400 ThePemFile
				
				scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/$RANDOMFILENAME $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "chmod 777 $RANDOMFILENAME && sudo ./$RANDOMFILENAME && rm -rf $RANDOMFILENAME"								
				
				scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/$RANDOM3FILENAME $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "chmod 777 $RANDOM3FILENAME && sudo ./$RANDOM3FILENAME && rm -rf $RANDOM3FILENAME"				
				
				scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "sudo mv $RANDOM4FILENAME $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-connect.sh && sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-connect.sh && sudo chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-connect.sh"								
				
				scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/$RND1 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "sudo mv $RND1 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-add.sh && sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-add.sh && sudo chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-add.sh"								

				scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/$RND2 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "sudo mv $RND2 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-exec.sh && sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-exec.sh && sudo chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-exec.sh"								
				
				scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/$RND3 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "sudo mv $RND3 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-kill.sh && sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-kill.sh && sudo chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-kill.sh"								

				scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/$RND5 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "sudo mv $RND5 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-push.sh && sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-push.sh && sudo chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-push.sh"								

				scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/$RND6 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "sudo mv $RND6 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-remove.sh && sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-remove.sh && sudo chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-remove.sh"								

				scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/$RND7 $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
				ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "sudo mv $RND7 $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-sync.sh && sudo chown $THEREQUIREDUSER:$THEREQUIREDUSER $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-sync.sh && sudo chmod u=rx,g=rx,o=rx $THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-sync.sh"								
				
				sudo cat $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub | ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "cat >> $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.ssh/authorized_keys"
				THEFILERESPONSE=$(ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "[ -f \"$THEREQUIREDBASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem\" ] && echo 'YES' || echo 'NO'")
				if [ $THEFILERESPONSE == "NO" ] || [ $THEFILERESPONSE == "NO" ] ; then
					RANDOM2FILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
					scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa.pub $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/Keys/id_rsa_terminal.pub $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/matsya-k8s-mn-$CLUSTERNAME.pem $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/matsya-k8s-mn-$CLUSTERNAME.ppk $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.ppk $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/HOSTS $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
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
					scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "chmod 777 $RANDOM2FILENAME && sudo ./$RANDOM2FILENAME && rm -rf $RANDOM2FILENAME"
					sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RANDOM2FILENAME	
				fi
				ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "sudo chmod -R u=rwx,g=,o= $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME && sudo chmod 0700 $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.ssh && sudo chmod 0644 $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.ssh/authorized_keys && sudo chown $RANDOMUSERNAME:$RANDOMUSERNAME $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.ssh/authorized_keys"				
				if [ $SECRETSAVAILABLE == "YES" ] || [ $SECRETSAVAILABLE == "YES" ] ; then
					RANDOMSECFILENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
					sudo cp $THESECRETSFILE $BASE/tmp/$RANDOMSECFILENAME
					sudo chmod 777 $BASE/tmp/$RANDOMSECFILENAME
					scp -P $THEREQUIREDPORT -o "StrictHostKeyChecking=no" -i ThePemFile $BASE/tmp/$RANDOMSECFILENAME $THEREQUIREDUSER@$THEREQUIREDIP:/home/$THEREQUIREDUSER
					ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "sudo mv $RANDOMSECFILENAME $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/.Secret && sudo chmod u=,g=,o= $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/.Secret"					
					sudo rm -rf $BASE/tmp/$RANDOMSECFILENAME
				fi				
				ssh -o ConnectTimeout=15 -i ThePemFile $THEREQUIREDUSER@$THEREQUIREDIP -p $THEREQUIREDPORT -o "StrictHostKeyChecking=no" "sudo rm -rf /root/.bash_history && sudo rm -rf /home/$THEREQUIREDUSER/.bash_history && sudo rm -rf $THEREQUIREDBASE/K8sMN/$CLUSTERNAME/$RANDOMUSERNAME/.bash_history"						
				echo ''								
				sudo rm -rf ThePemFile				
			fi
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RANDOMFILENAME
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RANDOM3FILENAME
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RANDOM4FILENAME
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RND1
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RND2
			sudo rm -rf $BASE/K8sMN/$CLUSTERNAME/$RND3
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
			if [ "$THEREQUIREDIP" == "null" ] || [ "$THEREQUIREDIP" = "" ] ; then
				THEREQUIREDIP=""
			else
				THEREQUIREDIP=" ($THEREQUIREDIP)"
			fi				
			echo "($COUNTERe) $THEREQUIREDHOSTNAME$THEREQUIREDIP"
			COUNTERe=$((COUNTERe + 1)) 
		done		
		echo '-----------------------'	
		echo ''
		echo -e "${RED}-----------------------${NC}"
		echo -e "${RED}${BOLD}\x1b[5mACCESS INFO${NORM}${NC}"
		echo -e "${RED}-----------------------${NC}"
		echo -e "${BOLD}FELLOWSHIP => $CLUSTERNAME${NORM}"		
		echo -e "${RED}$RANDOMUSERNAME => $RANDOMPASSWORD${NC}"
		if [ "$E2EALLOCATIONHAPPENED" == "YES" ] || [ "$E2EALLOCATIONHAPPENED" == "YES" ] ; then
			echo -e "${RED}E2E (matsya) => $GlobalE2EPassword${NC}"		
		fi
		echo -e "${RED}-----------------------${NC}"	
		echo "* $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.pem
* $BASE/matsya-k8s-mn-$CLUSTERNAME-terminal.ppk"
		echo '-----------------------'
		echo "* PASSWORD LOGIN     => sshpass -p \"$RANDOMPASSWORD\" ssh -p PORT -o \"StrictHostKeyChecking=no\" $RANDOMUSERNAME@TERMINAL"
		echo '-----'		
		echo "* FILE PUSH          => $BASE/matsya-k8s-mn-$CLUSTERNAME-push.sh"
		echo '-----'		
		echo "* EXECUTE            => $BASE/matsya-k8s-mn-$CLUSTERNAME-exec.sh"
		echo '-----'
		echo "* CONNECT TERMINAL   => $BASE/matsya-k8s-mn-$CLUSTERNAME-connect.sh"
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

