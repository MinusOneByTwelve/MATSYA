#!/bin/bash
# OpenLogic OpenJDK 11

clear

UserName=$(whoami)
JAVAPackageName="jdk11.7z"
JAVAInstallPath="/opt/java/Open"
JAVAFolderName='jdk11'

mkdir -p $JAVAInstallPath

echo "====================================================================="
echo "************* Open Java SetUp [ $JAVAFolderName ]  *******************"
echo "====================================================================="
echo "                                                                         "

if [ -f "/opt/java/$JAVAPackageName" ]
then
	echo "$JAVAPackageName Found...Not Downloading..."
	echo "                                                                         "
else
	exit
fi

if [ -f "/opt/java/mysql-connector-java-8.0.23.jar" ]
then
	echo "mysql-connector-java-8.0.23.jar Found...Not Downloading..."
	echo "                                                                         "
else
	exit
fi

if [ -f "/opt/java/$JAVAPackageName" ]
then
	pushd /opt/java
	echo "                                                                         "
	echo "Setting Up...Please Wait..."
	rm -Rf $JAVAInstallPath/*
	7z x $JAVAPackageName -o.
	mv $JAVAFolderName $JAVAInstallPath	
	echo "                                                                         "
	echo "Set Up Complete."
	echo "                                                                         "
	popd
	mv $JAVAInstallPath/$JAVAFolderName/* $JAVAInstallPath
	rm -Rf $JAVAInstallPath/$JAVAFolderName
	rm -f /etc/alternatives/jar
	rm -f /etc/alternatives/jps
	rm -f /etc/alternatives/java
	rm -f /etc/alternatives/javac
	rm -f /etc/alternatives/javadoc
	rm -f /etc/alternatives/javap
	rm -f /etc/alternatives/javapackager
	rm -f /etc/alternatives/javaws
	rm -f /etc/alternatives/javaws.real
	rm -f /usr/bin/jar
	rm -f /usr/bin/jps
	rm -f /usr/bin/java
	rm -f /usr/bin/javac
	rm -f /usr/bin/javadoc
	rm -f /usr/bin/javap
	rm -f /usr/bin/javapackager
	rm -f /usr/bin/javaws
	rm -f /usr/bin/javaws.real
	rm -Rf /opt/java/$JAVAFolderName
	ln -s $JAVAInstallPath /opt/java/$JAVAFolderName
	ln -s /opt/java/$JAVAFolderName /usr/java/$JAVAFolderName
	ln -s /opt/java/$JAVAFolderName/bin/jar /etc/alternatives/jar
	ln -s /opt/java/$JAVAFolderName/bin/jps /etc/alternatives/jps
	ln -s /opt/java/$JAVAFolderName/bin/java /etc/alternatives/java
	ln -s /opt/java/$JAVAFolderName/bin/javac /etc/alternatives/javac
	ln -s /opt/java/$JAVAFolderName/bin/javadoc /etc/alternatives/javadoc
	ln -s /opt/java/$JAVAFolderName/bin/javap /etc/alternatives/javap
	ln -s /opt/java/$JAVAFolderName/bin/javapackager /etc/alternatives/javapackager
	ln -s /opt/java/$JAVAFolderName/bin/javaws /etc/alternatives/javaws
	ln -s /etc/alternatives/jar /usr/bin/jar
	ln -s /etc/alternatives/jps /usr/bin/jps
	ln -s /etc/alternatives/java /usr/bin/java
	ln -s /etc/alternatives/javac /usr/bin/javac
	ln -s /etc/alternatives/javadoc /usr/bin/javadoc
	ln -s /etc/alternatives/javap /usr/bin/javap
	ln -s /etc/alternatives/javapackager /usr/bin/javapackager
	ln -s /etc/alternatives/javaws /usr/bin/javaws
	echo "                                                                         "
	echo "---------------------------------------------------------------------"
	java -version
	echo "---------------------------------------------------------------------"
	ls -l /etc/alternatives/java*
	ls -l /etc/alternatives/jar
	ls -l /etc/alternatives/jps
	echo "---------------------------------------------------------------------"
	ls -l /usr/bin/java*
	ls -l /usr/bin/jar
	ls -l /usr/bin/jps
	echo "---------------------------------------------------------------------"
	chown root:root -R /opt/java
	chmod 777 -R /opt/java
	rm -f /usr/share/java/mysql-connector-java.jar
	ln -s /opt/java/mysql-connector-java-8.0.23.jar /usr/share/java/mysql-connector-java.jar
	chmod 777 -R /opt/java/mysql-connector-java-8.0.23.jar
	chmod 777 -R /usr/share/java/mysql-connector-java.jar
else
	exit
fi

echo "                                                                         "
echo "====================================================================="
echo "************* Open Java SetUp [ $JAVAFolderName ]  *******************"
echo "====================================================================="
echo "                                                                         "
