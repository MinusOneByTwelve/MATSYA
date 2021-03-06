#!/bin/bash

set -e

clear

CURRENTUSER=$(whoami)
sudo rm -rf /home/$CURRENTUSER/.ssh/known_hosts
sudo rm -rf /root/.ssh/known_hosts

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

echo -e "${ORANGE}==============================================================================${NC}"
echo -e "${BLUE}${BOLD}\x1b[4mM${NORM}${NC}ultifaceted deploy${BLUE}${BOLD}\x1b[4mA${NORM}${NC}gnostic ${BLUE}${BOLD}\x1b[4mT${NORM}${NC}imesaving ${BLUE}${BOLD}\x1b[4mS${NORM}${NC}calable anal${BLUE}${BOLD}\x1b[4mY${NORM}${NC}tics ${BLUE}${BOLD}\x1b[4mA${NORM}${NC}malgamated ${BOLD}\x1b[30;44mPLATFORM\x1b[m${NORM}"
echo -e "${GREEN}==============================================================================${NC}"
echo ''
echo -e "\x1b[3m\x1b[4mVAGRANT VIRTUALBOX STANDALONE\x1b[m"
echo ''

USERINTERACTION="YES"
USERVALS=""
CONFIRMFILETOCREATE=""

BASE=""
CLUSTERNAME=""
CONFIRMPROCEED=""
NODESNUMBER=""
DEFAULTCONFIG=""
LANTYPE=""
NIC=""
GATEWAY=""
NETMASK=""
STARTRANDOMIP=""
FILEMOUNTOPTION=""
REALFILEMOUNT=""
ADDTOHOSTSFILE=""
ROOTPWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
MATSYAPWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
VAGRANTPWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
RANDOMSSHPORT=$(shuf -i 45000-46000 -n 1)
	
if [ "$#" -ne 1 ]; then
	USERVALS=""
else
	USERVALS=$1
	USERINTERACTION="NO"
	IFS='├' read -r -a USERLISTVALS <<< $USERVALS
	BASE="${USERLISTVALS[0]}"
	CLUSTERNAME="${USERLISTVALS[1]}"
	CONFIRMPROCEED="${USERLISTVALS[2]}"
	NODESNUMBER="${USERLISTVALS[3]}"
	DEFAULTCONFIG="${USERLISTVALS[4]}"
	LANTYPE="${USERLISTVALS[5]}"
	NIC="${USERLISTVALS[6]}"
	GATEWAY="${USERLISTVALS[7]}"
	NETMASK="${USERLISTVALS[8]}"
	STARTRANDOMIP="${USERLISTVALS[9]}"
	FILEMOUNTOPTION="${USERLISTVALS[10]}"	
	REALFILEMOUNT="${USERLISTVALS[11]}"	
	ADDTOHOSTSFILE="${USERLISTVALS[12]}"
	USERINPUTCOUNT=${#USERLISTVALS[@]}
	if (( $USERINPUTCOUNT > 13 )) ; then
		ROOTPWD="${USERLISTVALS[13]}"	
		MATSYAPWD="${USERLISTVALS[14]}"	
		VAGRANTPWD="${USERLISTVALS[15]}"
		CONFIRMFILETOCREATE="${USERLISTVALS[16]}"
		RANDOMSSHPORT="${USERLISTVALS[17]}"
	fi			
fi
if [ "$USERINTERACTION" == "YES" ] || [ "$USERINTERACTION" == "yes" ] ; then
	read -p "Enter Base Location (If Missing, Will Be Created) > " -e -i "/opt/Matsya" BASE
fi
sudo mkdir -p $BASE/MN
sudo mkdir -p $BASE/mounts
sudo mkdir -p $BASE/Repo
sudo mkdir -p $BASE/tmp
sudo mkdir -p $BASE/VagVBoxSA
ISFA="$BASE/Repo/Stack/Bundle/KLM15_v1_1_1.box"
VBOXCHOICE="AUTO"
if [ -f "$ISFA" ]
then
	VBOXCHOICE="MANUAL"
	echo ''
else
	echo "
==============================================================================

*Vagrant VirtualBox Missing...
--------
*Download From Here => https://bit.ly/Minus1by12MatsyaPlatform
   * Copy To $BASE/Repo/Stack/Bundle  

==============================================================================
"
	exit
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
UUID=$(uuidgen)
UUIDREAL=${UUID:1:6}
if [ "$USERINTERACTION" == "YES" ] || [ "$USERINTERACTION" == "yes" ] ; then
	read -p "Enter Cluster Name (Preferably Unique...) > " -e -i "$UUIDREAL" CLUSTERNAME
	echo ""
fi	
echo "==============================================================================

*To Avoid Conflict Later...Open Another Terminal & Execute

   * sudo vagrant global-status --prune
   * sudo vagrant box list

If '$CLUSTERNAME' Appears On Above Commands,Execute

   * sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-kill.sh      
     
==============================================================================
"
echo -e "Enter Choice => { (${GREEN}${BOLD}\x1b[4mC${NORM}${NC})onfirm (${RED}${BOLD}\x1b[4mA${NORM}${NC})bort (${YELLOW}${BOLD}\x1b[4mP${NORM}${NC})roceed } c/a/p"
if [ "$USERINTERACTION" == "YES" ] || [ "$USERINTERACTION" == "yes" ] ; then
	read -p "> " -e -i "a" CONFIRMPROCEED	
	echo ""
fi	
IP_ADDRESS_LIST=()
if [ $CONFIRMPROCEED == "p" ] || [ $CONFIRMPROCEED == "P" ] ; then
	if [ -f "$BASE/matsya-vagvbox-sa-$CLUSTERNAME-kill.sh" ]
	then
		sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-kill.sh
	fi	
	CONFIRMPROCEED="C"
fi	
if [ $CONFIRMPROCEED == "c" ] || [ $CONFIRMPROCEED == "C" ] ; then
	echo "=============================================================================="
	echo ''
	if [ "$USERINTERACTION" == "YES" ] || [ "$USERINTERACTION" == "yes" ] ; then
		read -p "Enter No Of Nodes > " -e -i "6" NODESNUMBER
		echo ''
		read -p "Enter Default Config (RAM {1024*n eg: 3GB RAM = 1024*3}, CORES, DISK SIZE {GB}) > " -e -i "2176,2,200" DEFAULTCONFIG
		echo ''
		read -p "LAN (*Private OR *Custom) p/c > " -e -i "c" LANTYPE
		echo ''
	fi
	THEIPBASE=""
	if [ $LANTYPE == "c" ] || [ $LANTYPE == "C" ] ; then
		echo '-----------------------'
		echo 'Network Cards Available'
		echo '-----------------------'
		ip -br -c addr show
		echo '-----------------------'				
		echo ''
		if [ "$USERINTERACTION" == "YES" ] || [ "$USERINTERACTION" == "yes" ] ; then	
			read -p "Enter NIC > " -e -i "enp2s0" NIC
			echo ''
		fi
		echo '-----------------------'
		ifconfig $NIC
		echo ''
		route -n | grep "$NIC\|Gateway"
		echo '-----------------------'
		echo ''
		if [ "$USERINTERACTION" == "YES" ] || [ "$USERINTERACTION" == "yes" ] ; then		
			read -p "Enter Gateway > " -e -i "192.168.1.1" GATEWAY
			echo ''
			read -p "Enter Netmask > " -e -i "255.255.255.0" NETMASK
			echo ''
		fi	
		IFS='.'
		read -ra GTWY <<< "$GATEWAY"
		BASEIP=$(echo "${GTWY[0]}.${GTWY[1]}.${GTWY[2]}.")
		THEIPBASE=$(echo "${GTWY[0]}.${GTWY[1]}.${GTWY[2]}.")
		DIFF=$((200-100+1))
		R=$(($(($RANDOM%$DIFF))+100))
		if [ "$USERINTERACTION" == "YES" ] || [ "$USERINTERACTION" == "yes" ] ; then
			read -p "Random Starting IP > $BASEIP" -e -i "$R" STARTRANDOMIP
			echo ''
		fi
	else
		DIFF=$((200-100+1))
		R=$(($(($RANDOM%$DIFF))+100))
		BASEIP="192.168.50."
		THEIPBASE="192.168.50."
		if [ "$USERINTERACTION" == "YES" ] || [ "$USERINTERACTION" == "yes" ] ; then
			read -p "Random Starting IP > $BASEIP" -e -i "$R" STARTRANDOMIP
			echo ''	
		fi												
	fi
	if [ "$USERINTERACTION" == "YES" ] || [ "$USERINTERACTION" == "yes" ] ; then
		read -p "File Mount (*Local OR *Custom) l/c > " -e -i "l" FILEMOUNTOPTION
		echo ''	
	fi
	if [ $FILEMOUNTOPTION == "c" ] || [ $FILEMOUNTOPTION == "C" ] ; then
		if [ "$USERINTERACTION" == "YES" ] || [ "$USERINTERACTION" == "yes" ] ; then
			read -p "Enter Mount Location(s) > " -e -i "$BASE/mounts/$CLUSTERNAME/disk1,$BASE/mounts/$CLUSTERNAME/disk2,$BASE/mounts/$CLUSTERNAME/disk3,$BASE/mounts/$CLUSTERNAME/disk1,$BASE/mounts/$CLUSTERNAME/disk2,$BASE/mounts/$CLUSTERNAME/disk3" REALFILEMOUNT
			echo ''
		fi
	fi	
	sudo rm -rf $BASE/VagVBoxSA/$CLUSTERNAME
	sudo mkdir -p $BASE/VagVBoxSA/$CLUSTERNAME/Configs
	sudo mkdir -p $BASE/VagVBoxSA/$CLUSTERNAME/Keys
	sudo mkdir -p $BASE/VagVBoxSA/$CLUSTERNAME/VM
	sudo chown -R root:root $BASE/VagVBoxSA/$CLUSTERNAME
	sudo chmod -R u=rwx,g=,o= $BASE/VagVBoxSA/$CLUSTERNAME	
	echo '-----------------------'
	echo 'NODES (IP & HOSTNAME)'
	echo '-----------------------'
	SERIESSTART=$(echo "$(($STARTRANDOMIP + 0))")
	SERIESEND=$(echo "$(($STARTRANDOMIP + $NODESNUMBER))")	
	SSHBYCOORDINATOR="echo '-----------------------' && "
	COUNTERx=0	
	for ((i = SERIESSTART; i < SERIESEND; i++))
	do 
		NEWIPADDR="${BASEIP}${i}"
		if [ "$REALFILEMOUNT" == "null" ] || [ "$REALFILEMOUNT" = "" ] ; then		
			IP_ADDRESS_LIST+=("$NEWIPADDR¬$BASE/VagVBoxSA/$CLUSTERNAME/VM")
		else
			IFS=',' read -r -a ARRAYFILEMOUNT <<< $REALFILEMOUNT
			ARRAYLENFILEMOUNT=${#ARRAYFILEMOUNT[@]}
			ARRAYLENFILEMOUNT=$((ARRAYLENFILEMOUNT - 1))
			if (( $COUNTERx > $ARRAYLENFILEMOUNT )) ; then
				IP_ADDRESS_LIST+=("$NEWIPADDR¬$BASE/VagVBoxSA/$CLUSTERNAME/VM")
			else
				IP_ADDRESS_LIST+=("$NEWIPADDR¬""${ARRAYFILEMOUNT[$COUNTERx]}")
			fi
		fi
		IP_ADDRESS_HYPHEN=${NEWIPADDR//./-}
		echo "$NEWIPADDR	matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN.local"
		sudo mkdir -p $BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN
		if (( $COUNTERx > 0 )) ; then
			SSHBYCOORDINATOR+="sudo sshpass -p \"$MATSYAPWD\" ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub -o StrictHostKeyChecking=no -o IdentitiesOnly=yes matsya@$NEWIPADDR && "
		fi
		COUNTERx=$((COUNTERx + 1))
	done
	
	SSHBYCOORDINATOR+="echo '-----------------------'"
	echo '-----------------------'
	echo ''
	WHENJOBBEGAN=$(echo $(date +%H):$(date +%M))
	if [ "$USERINTERACTION" == "YES" ] || [ "$USERINTERACTION" == "yes" ] ; then	
		read -p "Add To (/etc/hosts) y/n > " -e -i "y" ADDTOHOSTSFILE			
		echo ""
	fi
	DESTROYCLUSTERSCRIPT=$(echo '#!/bin/bash'"	
sudo vagrant global-status --prune | grep $CLUSTERNAME | cut -f 1 -d ' ' | xargs -L 1 sudo vagrant halt 
sudo vagrant global-status --prune | grep $CLUSTERNAME | cut -f 1 -d ' ' | xargs -L 1 sudo vagrant destroy -f  
sudo vagrant box list | grep $CLUSTERNAME | cut -f 1 -d ' ' | xargs -L 1 sudo vagrant box remove -f
sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-stop-post.sh
sudo rm -rf $BASE/VagVBoxSA/$CLUSTERNAME
sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem
sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME.ppk 
sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME-start.sh
sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME-start-pre.sh	
sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME-stop.sh
sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME-stop-post.sh
sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME-kill.sh
sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME-push.sh
sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec.sh
sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec
sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME-remove.sh
")
	echo "$DESTROYCLUSTERSCRIPT" | sudo tee $BASE/matsya-vagvbox-sa-$CLUSTERNAME-kill.sh > /dev/null
		
	STARTCLUSTERSCRIPT=$(echo '#!/bin/bash'"	

sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-start-pre.sh
sudo vagrant global-status --prune | grep $CLUSTERNAME | cut -f 1 -d ' ' | xargs -L 1 sudo vagrant up
")
	echo "$STARTCLUSTERSCRIPT" | sudo tee $BASE/matsya-vagvbox-sa-$CLUSTERNAME-start.sh > /dev/null	

	STARTPRECLUSTERSCRIPT=$(echo '#!/bin/bash
	
	
	')
	echo "$STARTPRECLUSTERSCRIPT" | sudo tee $BASE/matsya-vagvbox-sa-$CLUSTERNAME-start-pre.sh > /dev/null	
	
	STOPCLUSTERSCRIPT=$(echo '#!/bin/bash'"	

sudo vagrant global-status --prune | grep $CLUSTERNAME | cut -f 1 -d ' ' | xargs -L 1 sudo vagrant halt
sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-stop-post.sh
")
	echo "$STOPCLUSTERSCRIPT" | sudo tee $BASE/matsya-vagvbox-sa-$CLUSTERNAME-stop.sh > /dev/null
	
	STOPPOSTCLUSTERSCRIPT=$(echo '#!/bin/bash
	
	
	')
	echo "$STOPPOSTCLUSTERSCRIPT" | sudo tee $BASE/matsya-vagvbox-sa-$CLUSTERNAME-stop-post.sh > /dev/null	
			
	echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
" | sudo tee $BASE/VagVBoxSA/$CLUSTERNAME/Configs/hosts > /dev/null	
	if [ $ADDTOHOSTSFILE == "y" ] || [ $ADDTOHOSTSFILE == "Y" ] ; then
		for ((i = SERIESSTART; i < SERIESEND; i++))
		do 
			NEWIPADDR="${BASEIP}${i}"
			IP_ADDRESS_HYPHEN2=${NEWIPADDR//./-}
			sudo -H -u root bash -c "sed -i -e s~\"$NEWIPADDR\"~\"#$NEWIPADDR\"~g /etc/hosts"
			sudo -H -u root bash -c "echo \"$NEWIPADDR	matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN2.local\" >> /etc/hosts"
			echo "sudo sed -i -e s~\"$NEWIPADDR\"~\"#$NEWIPADDR\"~g /etc/hosts" | sudo tee -a $BASE/matsya-vagvbox-sa-$CLUSTERNAME-kill.sh > /dev/null
			echo "$NEWIPADDR	matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN2.local" | sudo tee -a $BASE/VagVBoxSA/$CLUSTERNAME/Configs/hosts > /dev/null			
		done											
	fi		
	echo '-----------------------'
	echo 'NEW SSH KEYS'
	echo '-----------------------'
	sudo -H -u root bash -c "cd $BASE/VagVBoxSA/$CLUSTERNAME/Keys && echo -e  'y\n'|ssh-keygen -b 2048 -t rsa -P '' -f id_rsa && cat id_rsa.pub >> authorized_keys && cp id_rsa matsya-vagvbox-sa-$CLUSTERNAME.pem && puttygen matsya-vagvbox-sa-$CLUSTERNAME.pem -o matsya-vagvbox-sa-$CLUSTERNAME.ppk && cd ~"
	sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem
	sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME.ppk
	sudo mv $BASE/VagVBoxSA/$CLUSTERNAME/Keys/matsya-vagvbox-sa-$CLUSTERNAME.pem $BASE
	sudo mv $BASE/VagVBoxSA/$CLUSTERNAME/Keys/matsya-vagvbox-sa-$CLUSTERNAME.ppk $BASE
	sudo chmod u=rwx,g=rx,o=rx $BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem
	sudo chmod u=rwx,g=rx,o=rx $BASE/matsya-vagvbox-sa-$CLUSTERNAME.ppk
	sudo rm -rf $BASE/VagVBoxSA/$CLUSTERNAME/Keys/authorized_keys
	sudo rm -rf $BASE/VagVBoxSA/$CLUSTERNAME/Keys/id_rsa	
	sudo chown -R root:root $BASE/VagVBoxSA/$CLUSTERNAME/Keys/id_rsa.pub
	sudo chmod -R u=rx,g=,o= $BASE/VagVBoxSA/$CLUSTERNAME/Keys/id_rsa.pub	
	echo '-----------------------'
	COUNTER=0
	COORDINATOR="NONE"
	
	for IP_ADDRESS_VALS_LIST in "${IP_ADDRESS_LIST[@]}"
	do
		IFS='¬' read -r -a IP_ADDRESS_VALS_LISTVals <<< $IP_ADDRESS_VALS_LIST
		VMIP="${IP_ADDRESS_VALS_LISTVals[0]}"
		THEFILEMOUNTLOCATION="${IP_ADDRESS_VALS_LISTVals[1]}"		
		IP_ADDRESS_HYPHEN3=${VMIP//./-}
		NAMEOFTHECLUSTERBOX="$CLUSTERNAME"
		CLUSTERBOXURL="https://bit.ly/MatsyaKLM15VagVBox"
		if [ $VBOXCHOICE == "MANUAL" ] || [ $VBOXCHOICE == "MANUAL" ] ; then
			CLUSTERBOXURL="$BASE/Repo/Stack/Bundle/KLM15_v1_1_1.box"	
		fi
		IFS=','
		read -ra DEFCONFG <<< "$DEFAULTCONFIG"
		DEFCONFGMEM=$(echo "${DEFCONFG[0]}")
		DEFCONFGCORES=$(echo "${DEFCONFG[1]}")
		ORIGINALSIZEOFDISK=$(echo "${DEFCONFG[2]}")
		NEWSIZEOFDISK=$((22 + ORIGINALSIZEOFDISK + 17))				
		DEFCONFGDISKSIZE=$(echo "$NEWSIZEOFDISK""GB")
		VMNETWORKADDRESS="config.vm.network \"private_network\", ip: \"$VMIP\""
		if [ $LANTYPE == "c" ] || [ $LANTYPE == "C" ] ; then
			VMNETWORKADDRESS="config.vm.network \"public_network\", bridge: \"$NIC\", ip: \"$VMIP\""	
		fi
		THENAMEOFVBBOX="matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3"
		THENAMETOSHOWONSCREEN="$VMIP"
		if (( $COUNTER == 0 )) ; then
			COORDINATOR="$VMIP"
			THENAMEOFVBBOX="matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3-coordinator​"
			DEFCONFGDISKSIZE="100GB"
			DEFCONFGMEM="512"
			DEFCONFGCORES="1"
			THENAMETOSHOWONSCREEN="$VMIP (Coordinator)"
		fi			    
	    	echo "Vagrant.configure(\"2\") do |config|
  unless Vagrant.has_plugin?(\"vagrant-disksize\")
    raise  Vagrant::Errors::VagrantError.new, \"vagrant-disksize Plugin Missing.Run 'sudo vagrant plugin install vagrant-disksize' & Restart\"
  end 
   
  config.vm.box = \"$NAMEOFTHECLUSTERBOX\"

  config.vm.box_url = \"$CLUSTERBOXURL\"
  config.vm.provider :virtualbox do |vb|
      vb.name = \"$THENAMEOFVBBOX\"
  end
  
  #config.ssh.private_key_path = \"$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem\"
  
  #config.ssh.port = $RANDOMSSHPORT
  
  #config.ssh.host = \"$VMIP\"
  
  config.vm.synced_folder '.', '/vagrant', disabled: true
  
  $VMNETWORKADDRESS  

  config.disksize.size = '$DEFCONFGDISKSIZE'
  
  config.vm.provider \"virtualbox\" do |vb|
     vb.memory = \"$DEFCONFGMEM\"
     vb.cpus = \"$DEFCONFGCORES\"
  end

  if Vagrant.has_plugin?(\"vagrant-vbguest\")
    config.vbguest.auto_update = false  
  end
  
end" | sudo tee $BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3/Vagrantfile > /dev/null
		echo ''
		echo '-----------------------'
		echo "$THENAMETOSHOWONSCREEN"
		echo '-----------------------'
		sudo -H -u root bash -c "pushd $BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3 && sudo vboxmanage setproperty machinefolder $THEFILEMOUNTLOCATION && sudo vagrant up && sudo vboxmanage setproperty machinefolder default && popd"
		if (( $COUNTER == 0 )) ; then
			echo ""
		else
			FINALPOINTTODISKSIZE=$((ORIGINALSIZEOFDISK + 22))
			THECOMMAND=$(echo 'disknumber="1" && number="3" && sudo parted --script /dev/sda mkpart primary ext4 22GB '"$FINALPOINTTODISKSIZE"'GB && sudo partprobe /dev/sda && sudo mkfs -F -t ext4 /dev/sda$number && sudo mkfs -F /dev/sda$number -t ext4 && sudo tune2fs -m 0 /dev/sda$number && sdauuid=$(sudo blkid -s UUID -o value /dev/sda$number) && sudo mkdir -p /opt/MatsyaPlatformData/_$disknumber && sudo mkdir -p /opt/java/Open && sudo mkdir -p /usr/java && sudo mkdir -p /usr/share/java && sudo e2label /dev/sda$number MatsyaPlatformData_$disknumber && echo "UUID=$sdauuid  /opt/MatsyaPlatformData/_$disknumber ext4 defaults 0 3" | sudo tee -a /etc/fstab > /dev/null && echo "----------------------------------------------------------------------------------------------" && sudo cat /etc/fstab && echo "----------------------------------------------------------------------------------------------" && lsblk -o name,mountpoint,label,size,fstype,uuid && echo "----------------------------------------------------------------------------------------------" && sudo parted -ls && echo "----------------------------------------------------------------------------------------------" && sudo rm -rf /opt/MatsyaPlatformData/_$disknumber/*')
			sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3/.vagrant/machines/default/virtualbox/private_key" "$THECOMMAND"
		fi
		THECOMMAND2=$(echo 'sudo useradd -d /home/matsya -s /bin/bash -m matsya && sudo usermod -p $(echo "matsya" | openssl passwd -1 -stdin) matsya && sudo usermod -p $(echo "matsya" | openssl passwd -1 -stdin) root && sudo usermod -aG wheel matsya && sudo rm -f /etc/sudoers.d/matsya-user && echo "matsya ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/matsya-user > /dev/null && sudo mkdir -p /opt/MatsyaPlatformData/_0 && sudo mkdir -p /opt/java/Open && sudo mkdir -p /usr/java && sudo mkdir -p /usr/share/java && echo "'"$MATSYAPWD"'" | sudo tee /usr/bin/.mtsypswd > /dev/null && sudo chmod u=r,g=,o= /usr/bin/.mtsypswd && sudo rm -rf /etc/hostname && echo "'"matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3.local"'" | sudo tee /etc/hostname')
		sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3/.vagrant/machines/default/virtualbox/private_key" "$THECOMMAND2"						
		sudo cat $BASE/VagVBoxSA/$CLUSTERNAME/Keys/id_rsa.pub | sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3/.vagrant/machines/default/virtualbox/private_key" 'cat >> $HOME/.ssh/authorized_keys'
		sudo -H -u root bash -c "pushd $BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3 && sudo vagrant halt && sed -i 's/#config.ssh.private_key_path/config.ssh.private_key_path/' Vagrantfile && popd"
		sudo rm -rf $BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3/.vagrant/machines/default/virtualbox/private_key
		sudo -H -u root bash -c "pushd $BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3 && sudo vagrant up && popd"
		sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" "echo '$ROOTPWD' | sudo passwd --stdin 'root'"				
		sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" "echo '$VAGRANTPWD' | sudo passwd --stdin 'vagrant'"		
		sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" "echo '$MATSYAPWD' | sudo passwd --stdin 'matsya'"
		sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" 'sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config && sudo systemctl restart sshd.service'
		THEHOSTSFILE="$BASE/VagVBoxSA/$CLUSTERNAME/Configs/hosts"
		#SSHRELATEDRPMS="$BASE/Repo/policycoreutils-python.7z"
		sudo sshpass -p "$VAGRANTPWD" scp $THEHOSTSFILE vagrant@$VMIP:/home/vagrant
		sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" "sudo rm -f /etc/hosts && sudo mv /home/vagrant/hosts /etc"
		#sudo sshpass -p "$VAGRANTPWD" scp $SSHRELATEDRPMS vagrant@$VMIP:/home/vagrant
		if (( $COUNTER == 0 )) ; then
			echo ''
		else
			sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" "sudo rm -rf /usr/bin/.mtsypswd"									
		fi
		sudo -H -u root bash -c "pushd $BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3 && sed -i 's/#config.ssh.port/config.ssh.port/' Vagrantfile && sed -i 's/#config.ssh.host/config.ssh.host/' Vagrantfile && popd"								
		echo '-----------------------'
		COUNTER=$((COUNTER + 1))
	done
	sudo ssh vagrant@$COORDINATOR -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" "echo -e  'y\n'|ssh-keygen -t rsa -P '' -f /home/vagrant/.ssh/id_rsa && cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys && eval \$(ssh-agent) > /dev/null && ssh-add && MATSYAPSWD=\$(sudo cat /usr/bin/.mtsypswd) && sshpass -p \"\$MATSYAPSWD\" ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub -o StrictHostKeyChecking=no -o IdentitiesOnly=yes vagrant@$COORDINATOR"
	sudo ssh vagrant@$COORDINATOR -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" "$SSHBYCOORDINATOR"	
	for IP_ADDRESS_VALS_LIST in "${IP_ADDRESS_LIST[@]}"
	do
		IFS='¬' read -r -a IP_ADDRESS_VALS_LISTVals <<< $IP_ADDRESS_VALS_LIST
		VMIP="${IP_ADDRESS_VALS_LISTVals[0]}"
		THEFILEMOUNTLOCATION="${IP_ADDRESS_VALS_LISTVals[1]}"
		#sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" "sudo rm -rf policycoreutils-python && sudo 7z x policycoreutils-python.7z -o. && sudo yum install -y policycoreutils-python/lsof-4.87-6.el7.x86_64.rpm && sudo rm -rf policycoreutils-python && sudo rm -rf policycoreutils-python.7z"
		sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" "SSHPORT=\"$RANDOMSSHPORT\" && sudo systemctl start firewalld && sudo systemctl enable firewalld && sudo sed -i -e s~\"Port\"~\"#Port\"~g /etc/ssh/sshd_config && echo \"Port \$SSHPORT\" | sudo tee -a /etc/ssh/sshd_config > /dev/null && sudo firewall-cmd --permanent --zone=public --add-port=\$SSHPORT/tcp && sudo firewall-cmd --reload && sudo systemctl restart sshd.service && echo '-----' && sudo lsof -nP -iTCP -sTCP:LISTEN | grep \"COMMAND\|IPv4\" && echo '-----' && sudo netstat -tnlp | grep -v tcp6 && echo '-----' && sudo route del default gw 10.0.2.2 && sudo route add default gw $GATEWAY"						
	done			
	echo ''
	sudo cp $BASE/Repo/Matsya-Vagrant-VirtualBox-StandAlone-NodeAddTemplate $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo sed -i s#CLUSTERADDTHEBASE#$BASE#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo sed -i s#CLUSTERADDTHECLUSTERNAME#$CLUSTERNAME#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo sed -i s#CLUSTERADDTHECONFIRMPROCEED#$CONFIRMPROCEED#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo sed -i s#CLUSTERADDTHEDEFAULTCONFIG#"$DEFAULTCONFIG"#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo sed -i s#CLUSTERADDTHELANTYPE#$LANTYPE#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo sed -i s#CLUSTERADDTHENIC#$NIC#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo sed -i s#CLUSTERADDTHEGATEWAY#$GATEWAY#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo sed -i s#CLUSTERADDTHENETMASK#$NETMASK#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo sed -i s#GETTHATIPPART#"${THEIPBASE}"#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo sed -i s#CLUSTERADDTHECOORDINATOR#$COORDINATOR#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo sed -i s#CLUSTERADDTHERANDOMSSHPORT#$RANDOMSSHPORT#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo sed -i s#CLUSTERADDTHEADDTOHOSTSFILE#$ADDTOHOSTSFILE#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh		
	sudo cp $BASE/Repo/Matsya-Vagrant-VirtualBox-StandAlone-NodeRemoveTemplate $BASE/matsya-vagvbox-sa-$CLUSTERNAME-remove.sh
	sudo sed -i s#THEBASELOCATION#$BASE#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-remove.sh
	sudo sed -i s#THECOORDINATOR#$COORDINATOR#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-remove.sh
	sudo sed -i s#THECLUSTERNAME#$CLUSTERNAME#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-remove.sh			
	sudo cp $BASE/Repo/Matsya-Vagrant-VirtualBox-StandAlone-GlobalPushTemplate $BASE/matsya-vagvbox-sa-$CLUSTERNAME-push.sh
	sudo sed -i s#THEBASELOCATION#$BASE#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-push.sh
	sudo sed -i s#THECOORDINATOR#$COORDINATOR#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-push.sh
	sudo sed -i s#THECLUSTERNAME#$CLUSTERNAME#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-push.sh	
	sudo cp $BASE/Repo/Matsya-Vagrant-VirtualBox-StandAlone-GlobalExecTemplate $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec.sh
	sudo sed -i s#THEBASELOCATION#$BASE#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec.sh
	sudo sed -i s#THECOORDINATOR#$COORDINATOR#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec.sh
	sudo sed -i s#THECLUSTERNAME#$CLUSTERNAME#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec.sh	
	sudo sed -i s#THERANDOMSSHPORT#$RANDOMSSHPORT#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-push.sh
	sudo sed -i s#THERANDOMSSHPORT#$RANDOMSSHPORT#g $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec.sh			
	sudo touch $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec
	sudo touch $BASE/VagVBoxSA/$CLUSTERNAME/.ports
	echo "SSH~$RANDOMSSHPORT" | sudo tee -a $BASE/VagVBoxSA/$CLUSTERNAME/.ports > /dev/null
	sudo chown -R root:root $BASE/matsya-vagvbox-sa-$CLUSTERNAME-start.sh
	sudo chmod -R u=x,g=,o= $BASE/matsya-vagvbox-sa-$CLUSTERNAME-start.sh
	sudo chown -R root:root $BASE/matsya-vagvbox-sa-$CLUSTERNAME-start-pre.sh
	sudo chmod -R u=rwx,g=,o= $BASE/matsya-vagvbox-sa-$CLUSTERNAME-start-pre.sh	
	sudo chown -R root:root $BASE/matsya-vagvbox-sa-$CLUSTERNAME-stop.sh
	sudo chmod -R u=x,g=,o= $BASE/matsya-vagvbox-sa-$CLUSTERNAME-stop.sh
	sudo chown -R root:root $BASE/matsya-vagvbox-sa-$CLUSTERNAME-stop-post.sh
	sudo chmod -R u=rwx,g=,o= $BASE/matsya-vagvbox-sa-$CLUSTERNAME-stop-post.sh	
	sudo chown -R root:root $BASE/matsya-vagvbox-sa-$CLUSTERNAME-kill.sh
	sudo chmod -R u=x,g=,o= $BASE/matsya-vagvbox-sa-$CLUSTERNAME-kill.sh
	sudo chown -R root:root $BASE/matsya-vagvbox-sa-$CLUSTERNAME-push.sh
	sudo chmod -R u=x,g=,o= $BASE/matsya-vagvbox-sa-$CLUSTERNAME-push.sh
	sudo chown -R root:root $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec.sh
	sudo chmod -R u=x,g=,o= $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec.sh
	sudo chown -R root:root $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec
	sudo chmod -R u=rw,g=,o= $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec
	sudo chown -R root:root $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh
	sudo chmod -R u=x,g=,o= $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh	
	sudo chown -R root:root $BASE/matsya-vagvbox-sa-$CLUSTERNAME-remove.sh
	sudo chmod -R u=x,g=,o= $BASE/matsya-vagvbox-sa-$CLUSTERNAME-remove.sh	
	sudo chown -R root:root $BASE/VagVBoxSA/$CLUSTERNAME/.ports
	sudo chmod -R u=r,g=,o= $BASE/VagVBoxSA/$CLUSTERNAME/.ports						
	sudo chmod -R u=r,g=,o= $BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem
	sudo chmod -R u=r,g=,o= $BASE/matsya-vagvbox-sa-$CLUSTERNAME.ppk
	sudo rm -rf $BASE/VagVBoxSA/$CLUSTERNAME/Configs/hosts	
	echo -e "${RED}-----------------------${NC}"
	echo -e "${RED}${BOLD}\x1b[5mNEW PASSWORDS${NORM}${NC}"
	echo -e "${RED}-----------------------${NC}"
	echo -e "${RED}root    => $ROOTPWD${NC}"
	echo -e "${RED}vagrant => $VAGRANTPWD${NC}"
	echo -e "${RED}-----------------------${NC}"	
	echo "* $BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem
* $BASE/matsya-vagvbox-sa-$CLUSTERNAME.ppk"
	echo '-----------------------'
	echo "* PASSWORD LOGIN   => sudo sshpass -p \"$VAGRANTPWD\" ssh vagrant@$COORDINATOR -p $RANDOMSSHPORT"
	echo "* SSH KEY LOGIN    => sudo ssh vagrant@$COORDINATOR -p $RANDOMSSHPORT  -o \"StrictHostKeyChecking=no\" -i \"$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem\""
	echo "* FILE PUSH        => sudo sshpass -p \"$VAGRANTPWD\" scp -P $RANDOMSSHPORT File_Path_On_Current_System vagrant@$COORDINATOR:/home/vagrant"
	echo "* FILE PULL        => sudo sshpass -p \"$VAGRANTPWD\" scp -P $RANDOMSSHPORT vagrant@$COORDINATOR:/home/vagrant/RequiredFile Location_On_Current_System"
	echo "* EXECUTE          => sudo ssh vagrant@$COORDINATOR -p $RANDOMSSHPORT  -o \"StrictHostKeyChecking=no\" -i \"$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem\" \"echo 'Hello From '\$(hostname)\""		
	echo "* START CLUSTER    => sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-start.sh"	
	echo "* STOP CLUSTER     => sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-stop.sh"
	echo "* ADD NODE         => sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-add.sh"	
	echo "* REMOVE NODE      => sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-remove.sh"	
	echo "* KILL CLUSTER     => sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-kill.sh"
	echo "* GLOBAL FILE PUSH => sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-push.sh I $VAGRANTPWD File_Path_On_Current_System"
	echo "                      {Params - [1] (I)nclude / (E)xclude Coordinator [2] Password For User => vagrant [3] Full Path Of The Required File}"
	echo "* GLOBAL EXECUTE   => sudo $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec.sh I $VAGRANTPWD"
	echo "                      {Params - [1] (I)nclude / (E)xclude Coordinator [2] Password For User => vagrant}"
	echo "                      {All Commands To Be Executed Can Be Written In $BASE/matsya-vagvbox-sa-$CLUSTERNAME-exec File}"							
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
	if [ "$CONFIRMFILETOCREATE" == "" ] || [ "$CONFIRMFILETOCREATE" == "" ] ; then
		ABC="XYZ"
	else
		echo "$CONFIRMFILETOCREATE" | sudo tee -a $BASE/VagVBoxSA/$CLUSTERNAME/$CONFIRMFILETOCREATE > /dev/null
	fi
else
	echo "Exiting For Now..."
	echo ''
	exit
fi			

