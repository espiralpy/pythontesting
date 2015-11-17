#!/bin/bash

#Read info.txt and extract line build number
BUILD=''
KEY=''
function getBuild(){
    while read line; do
       BUILD=$(echo "$line" | grep  'VM Name*')
       echo $BUILD
    done < info.txt
}

function getKey(){
    while read line; do
       KEY=$(echo "$line" | grep  'UUID: ')
       echo $KEY
    done < info.txt
}

#Extract last updated build number from file swupd_output.txt
function getBuildTo(){

    FILE=`find /root/swupd_output.txt -type f | xargs grep "Update complete. System updated from version"`
    NUMBERS=$(echo "$FILE" | grep  -o '[0-9]*')
    UPDATE_VERSION=$(echo ${NUMBERS:${#NUMBERS}-4:${#NUMBERS}})

    if [[ $UPDATE_VERSION == '' ]]
    then
        FILE=`find /root/swupd_output.txt -type f | xargs grep "Update complete. System already up-to-date at version"`
        NUMBERS=$(echo "$FILE" | grep -o  '[0-9]*')
        UPDATE_VERSION=$(echo ${NUMBERS:${#NUMBERS}-4:${#NUMBERS}})
        echo $UPDATE_VERSION
    else
        echo $UPDATE_VERSION
    fi
}

function getNameFile(){
    
    BUILD=$(getBuild)
    BUILD_NUMBER=$(echo "$BUILD" | grep  -o '[0-9]*')
    #echo $BUILD_NUMBER

    BUILDTO=$(getBuildTo)
    KEY=$(getKey)
    cleaned=${KEY//[UUID: ]}

    if [[ $BUILDTO == '' ]]
    then
        LATEST=$(curl http://clearlinux-sandbox.jf.intel.com/update/version/formatstaging/latest)
        echo $BUILD_NUMBER $LATEST $cleaned
    else
        echo $BUILD_NUMBER $BUILDTO $cleaned
    fi
}

function getPrefix(){
    PREFIX=`find info.txt -type f | xargs grep "VM Prefix Name: " | awk '{print $4}'`
    echo $PREFIX
}

function sendFile(){
	
	##GENERATE KEY SSH KEYGEN
	echo -e 'y' | ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
	expect run_password.expect
	#./generate_keys
	getNameFile
	FILE=$(getNameFile)
	varPrefix=$(getPrefix)
    echo $varPrefix
    if [[ $varPrefix == '' || $varPrefix == 'swsandbox' ]]
    then
	    ssh swupd@10.219.106.192 "mkdir -p /var/taas/results/results-swupdsandbox && chmod 777 /var/taas/results/results-swupdsandbox"
	    sleep 2
	    cp taplogs/swupd/quick-swupd.t /root/
	    sleep 2
	    mv /root/quick-swupd.t "/root/$FILE.log"
    	##PASS RESULT SSH
	    scp "/root/$FILE.log"  swupd@10.219.106.192:"/var/taas/results/results-swupdsandbox"
	    #syncronizing datas to website
            curl http://10.219.106.192/swupd/parserTaaS.php

    else
	    ssh swupd@10.219.106.192 "mkdir -p /var/taas/results/results-$varPrefix && chmod 777 /var/taas/results/results-$varPrefix"
	    sleep 2
	    cp taplogs/swupd/quick-swupd.t /root/
	    sleep 2
	    mv /root/quick-swupd.t "/root/$FILE.log"
    	##PASS RESULT SSH
	    scp "/root/$FILE.log"  swupd@10.219.106.192:"/var/taas/results/results-$varPrefix"
	    #syncronizing datas to website
	    curl http://10.219.106.192/swupd/parserTaaS.php
	fi
}


sendFile
