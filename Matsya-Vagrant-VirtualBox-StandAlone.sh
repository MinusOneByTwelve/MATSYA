#!/bin/bash

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

echo -e "${ORANGE}==============================================================================${NC}"
echo -e "${BLUE}${BOLD}\x1b[4mM${NORM}${NC}ultifaceted deploy${BLUE}${BOLD}\x1b[4mA${NORM}${NC}gnostic ${BLUE}${BOLD}\x1b[4mT${NORM}${NC}imesaving ${BLUE}${BOLD}\x1b[4mS${NORM}${NC}calable anal${BLUE}${BOLD}\x1b[4mY${NORM}${NC}tics ${BLUE}${BOLD}\x1b[4mA${NORM}${NC}malgamated ${BOLD}\x1b[30;44mPLATFORM\x1b[m${NORM}"
echo -e "${GREEN}==============================================================================${NC}"
echo ''
echo -e "\x1b[3m\x1b[4mVAGRANT VIRTUALBOX STANDALONE\x1b[m"
echo ''
read -p "Enter Base Location (If Missing, Will Be Created) > " -e -i "/opt/Matsya" BASE
sudo mkdir -p $BASE/VagVBoxSA
sudo mkdir -p $BASE/Repo
ISFA="/opt/Matsya/Repo/KLM15_v1_1_0.box"
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
UUID=$(uuidgen)
UUIDREAL=${UUID:1:6}
read -p "Enter Cluster Name (Preferably Unique...) > " -e -i "$UUIDREAL" CLUSTERNAME
echo ""
echo "==============================================================================

*To Avoid Conflict Later...Open Another Terminal & Execute

   * sudo vagrant global-status --prune
   * sudo vagrant box list

If '$CLUSTERNAME' Appears On Above Commands,Execute

   * sudo vagrant global-status --prune | grep $CLUSTERNAME | cut -f 1 -d ' ' | xargs -L 1 sudo vagrant halt 
   * sudo vagrant global-status --prune | grep $CLUSTERNAME | cut -f 1 -d ' ' | xargs -L 1 sudo vagrant destroy -f  
   * sudo vagrant box list | grep $CLUSTERNAME | cut -f 1 -d ' ' | xargs -L 1 sudo vagrant box remove -f
   * sudo rm -rf $BASE/VagVBoxSA/$CLUSTERNAME
   * sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem
   * sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME.ppk     
     
==============================================================================
"
echo -e "Enter Choice => { (${GREEN}${BOLD}\x1b[4mC${NORM}${NC})onfirm (${RED}${BOLD}\x1b[4mA${NORM}${NC})bort (${YELLOW}${BOLD}\x1b[4mP${NORM}${NC})roceed } c/a/p"
read -p "> " -e -i "a" CONFIRMPROCEED	
echo ""
IP_ADDRESS_LIST=()
if [ $CONFIRMPROCEED == "p" ] || [ $CONFIRMPROCEED == "P" ] ; then
	sudo vagrant global-status --prune | grep $CLUSTERNAME | cut -f 1 -d ' ' | xargs -L 1 sudo vagrant halt
	sudo vagrant global-status --prune | grep $CLUSTERNAME | cut -f 1 -d ' ' | xargs -L 1 sudo vagrant destroy -f
	sudo vagrant box list | grep $CLUSTERNAME | cut -f 1 -d ' ' | xargs -L 1 sudo vagrant box remove -f
	sudo rm -rf $BASE/VagVBoxSA/$CLUSTERNAME
	sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem
	sudo rm -rf $BASE/matsya-vagvbox-sa-$CLUSTERNAME.ppk
	CONFIRMPROCEED="C"
fi	
if [ $CONFIRMPROCEED == "c" ] || [ $CONFIRMPROCEED == "C" ] ; then
	echo "=============================================================================="
	echo ''
	read -p "Enter No Of Nodes > " -e -i "5" NODESNUMBER
	echo ''
	read -p "Enter Default Config (RAM {1024*n eg: 3GB RAM = 1024*3}, CORES, DISK SIZE {GB}) > " -e -i "3072,1,200" DEFAULTCONFIG
	echo ''
	read -p "LAN (*Private OR *Custom) p/c > " -e -i "c" LANTYPE
	echo ''
	if [ $LANTYPE == "c" ] || [ $LANTYPE == "C" ] ; then
		echo '-----------------------'
		echo 'Network Cards Available'
		echo '-----------------------'
		ip -br -c addr show
		echo '-----------------------'				
		echo ''	
		read -p "Enter NIC > " -e -i "wlp4s0" NIC
		echo ''
		echo '-----------------------'
		ifconfig $NIC
		echo ''
		route -n | grep "$NIC\|Gateway"
		echo '-----------------------'
		echo ''
		read -p "Enter Gateway > " -e -i "192.168.1.1" GATEWAY
		echo ''
		read -p "Enter Netmask > " -e -i "255.255.255.0" NETMASK
		echo ''	
		IFS='.'
		read -ra GTWY <<< "$GATEWAY"
		BASEIP=$(echo "${GTWY[0]}.${GTWY[1]}.${GTWY[2]}.")
		DIFF=$((200-100+1))
		R=$(($(($RANDOM%$DIFF))+100))
		read -p "Random Starting IP > $BASEIP" -e -i "$R" STARTRANDOMIP
		echo ''
	else
		DIFF=$((200-100+1))
		R=$(($(($RANDOM%$DIFF))+100))
		BASEIP="192.168.50."
		read -p "Random Starting IP > $BASEIP" -e -i "$R" STARTRANDOMIP
		echo ''													
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
	for ((i = SERIESSTART; i < SERIESEND; i++))
	do 
		NEWIPADDR="${BASEIP}${i}"
		IP_ADDRESS_LIST+=("$NEWIPADDR")
		IP_ADDRESS_HYPHEN=${NEWIPADDR//./-}
		echo "$NEWIPADDR	matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN.local"
		sudo mkdir -p $BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN
	done
	echo '-----------------------'
	echo ''	
	read -p "Add To (/etc/hosts) y/n > " -e -i "y" ADDTOHOSTSFILE	
	echo ""
	if [ $ADDTOHOSTSFILE == "y" ] || [ $ADDTOHOSTSFILE == "Y" ] ; then
		for ((i = SERIESSTART; i < SERIESEND; i++))
		do 
			NEWIPADDR="${BASEIP}${i}"
			IP_ADDRESS_HYPHEN2=${NEWIPADDR//./-}
			sudo -H -u root bash -c "sed -i -e s~\"$NEWIPADDR\"~\"#$NEWIPADDR\"~g /etc/hosts"
			sudo -H -u root bash -c "echo \"$NEWIPADDR	matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN2.local\" >> /etc/hosts"
		done											
	fi		
	ROOTPWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
	MATSYAPWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
	VAGRANTPWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
	echo -e "${RED}-----------------------${NC}"
	echo -e "${RED}${BOLD}\x1b[5mNEW PASSWORDS${NORM}${NC}"
	echo -e "${RED}-----------------------${NC}"
	echo -e "${RED}root    => $ROOTPWD${NC}"
	echo -e "${RED}vagrant => $VAGRANTPWD${NC}"
	echo -e "${RED}matsya  => $MATSYAPWD${NC}"
	echo -e "${RED}-----------------------${NC}"	
	echo '' 
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
	echo "* $BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem
* $BASE/matsya-vagvbox-sa-$CLUSTERNAME.ppk"
	echo '-----------------------'
	COUNTER=0
	COORDINATOR="NONE"		
	for VMIP in "${IP_ADDRESS_LIST[@]}"
	do
		IP_ADDRESS_HYPHEN3=${VMIP//./-}
		NAMEOFTHECLUSTERBOX="$CLUSTERNAME"
		CLUSTERBOXURL="https://bit.ly/MatsyaKLM15VagVBox"
		if [ $VBOXCHOICE == "MANUAL" ] || [ $VBOXCHOICE == "MANUAL" ] ; then
			CLUSTERBOXURL="$BASE/Repo/KLM15_v1_1_0.box"	
		fi
		IFS=','
		read -ra DEFCONFG <<< "$DEFAULTCONFIG"
		DEFCONFGMEM=$(echo "${DEFCONFG[0]}")
		DEFCONFGCORES=$(echo "${DEFCONFG[1]}")
		ORIGINALSIZEOFDISK=$(echo "${DEFCONFG[2]}")
		NEWSIZEOFDISK=$((43 + ORIGINALSIZEOFDISK + 17))				
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
			DEFCONFGDISKSIZE="50GB"
			DEFCONFGMEM="512"
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
		sudo -H -u root bash -c "pushd $BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3 && sudo vboxmanage setproperty machinefolder $BASE/VagVBoxSA/$CLUSTERNAME/VM && sudo vagrant up && sudo vboxmanage setproperty machinefolder default && popd"
		if (( $COUNTER == 0 )) ; then
			echo ""
		else
			FINALPOINTTODISKSIZE=$((ORIGINALSIZEOFDISK + 43))
			THECOMMAND=$(echo 'number="2" && sudo parted --script /dev/sda mkpart primary ext4 43GB '"$FINALPOINTTODISKSIZE"'GB && sudo partprobe /dev/sda && sudo mkfs -F -t ext4 /dev/sda$number && sudo mkfs -F /dev/sda$number -t ext4 && sudo tune2fs -m 0 /dev/sda$number && sdauuid=$(sudo blkid -s UUID -o value /dev/sda$number) && sudo mkdir -p /mnt/MatsyaHDD && sudo e2label /dev/sda$number MatsyaHDD && echo "UUID=$sdauuid  /mnt/MatsyaHDD ext4 defaults 0 3" | sudo tee -a /etc/fstab > /dev/null && echo "----------------------------------------------------------------------------------------------" && sudo cat /etc/fstab && echo "----------------------------------------------------------------------------------------------" && lsblk -o name,mountpoint,label,size,fstype,uuid && echo "----------------------------------------------------------------------------------------------" && sudo parted -ls && echo "----------------------------------------------------------------------------------------------"')
			sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3/.vagrant/machines/default/virtualbox/private_key" "$THECOMMAND"
		fi				
		sudo cat $BASE/VagVBoxSA/$CLUSTERNAME/Keys/id_rsa.pub | sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3/.vagrant/machines/default/virtualbox/private_key" 'cat >> $HOME/.ssh/authorized_keys'
		sudo -H -u root bash -c "pushd $BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3 && sudo vagrant halt && sed -i 's/#config.ssh.private_key_path/config.ssh.private_key_path/' Vagrantfile && popd"
		sudo rm -rf $BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3/.vagrant/machines/default/virtualbox/private_key
		sudo -H -u root bash -c "pushd $BASE/VagVBoxSA/$CLUSTERNAME/Configs/matsya-vagvbox-sa-$CLUSTERNAME-$IP_ADDRESS_HYPHEN3 && sudo vagrant up && popd"
		sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" "echo '$ROOTPWD' | sudo passwd --stdin 'root'"				
		sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" "echo '$VAGRANTPWD' | sudo passwd --stdin 'vagrant'"		
		sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" "echo '$MATSYAPWD' | sudo passwd --stdin 'matsya'"
		sudo ssh vagrant@$VMIP -p 22  -o "StrictHostKeyChecking=no" -i "$BASE/matsya-vagvbox-sa-$CLUSTERNAME.pem" 'sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config && sudo systemctl restart sshd.service'				
		echo '-----------------------'
		COUNTER=$((COUNTER + 1))
	done	
	echo ''	
	echo "=============================================================================="
	echo ''
else
	echo "Exiting For Now..."
	echo ''
	exit
fi			


