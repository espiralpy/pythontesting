#!/bin/bash

B=""

#version = $(cat original_version)
#echo $version

function getNumberLines(){

    numerar=$(sed '/./=' results.txt | sed 'N;s/\n/\t/')
    echo $numerar  > 1
    sed s/-/"\n"/g 1 > 2

    #Get key word in the end of the line
    while read line; do
            B=$(echo "$line" | grep  -o '%[A-Z][A-Z][A-Z][A-Z]')
        echo $B $line >> 3
    done < 2

    #Delete 5 last character in each line
    while read line; do
           echo ${line:1:-5} >> 4
    done <  3

    #replace key word in the beging with ok or not ok
    find 4 -print | xargs sed -i "s/PASS/ok/g"
    find 4 -print | xargs sed -i "s/FAIL/not ok/g"
    sed -i 's/_/ /g' 4
    sed '/^$/d' 4 > 5

    #count total test
    TOTAL_LINES=$(sed -n '$=' 5)
    RANGE="1..$TOTAL_LINES"
    sed -i "1i $RANGE" 5

    #send to folder results
    cp 5 taplogs/swupd/quick-swupd.t
    rm 1 2 3 4 5
}

#Get original version
function getBuildFrom(){

	ORIGEN_VERSION=$(cat /root/original_version.txt)
	echo $ORIGEN_VERSION
}

#Get Bundles
function getBundles(){

	FILES=$(ls /usr/share/clear/bundles/)
	BUNDLES=$(echo $FILES | tr " " ,)
	echo $BUNDLES
}

#Extract last updated build number from file swupd_output.txt
function cleanBuildTo(){

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

function getBuildTo(){

    BUILDTO=$(cleanBuildTo)

    if [[ $BUILDTO == '' ]]
    then
        LATEST=$(curl http://clearlinux-sandbox.jf.intel.com/update/version/formatstaging/latest)
        echo $LATEST
    else
        echo $BUILDTO
    fi
}

function getTime(){
    TIME=`find swupd_output.txt -type f | xargs grep "duration" | awk '{print $4}'`
    echo $TIME
}

function getIP(){
	IP=`find info.txt -type f | xargs grep "IP Address:" | awk '{print $3}'`
	echo $IP
}

function getUUID(){
    UUID=`find info.txt -type f | xargs grep "UUID:" | awk '{print $2}'`
    echo $UUID
}

function getPrefix(){
    PREFIX=`find info.txt -type f | xargs grep "VM Prefix Name: " | awk '{print $4}'`
    echo $PREFIX
}

function  selectTest(){
    varPrefix=$(getPrefix)
    case $varPrefix in
        ""|"swsandbox")
            echo "Knife Tool - Swupd Sandbox"
            ;;
        "bundle")
            echo "Knife Tool - Bundle Remove"
            ;;
    esac
}

function writeTags(){
	varBuildFrom=$(getBuildFrom)
	varBuildTo=$(getBuildTo)
	varBundles=$(getBundles)
	varTime=$(getTime)
	varIP=$(getIP)
	varUUID=$(getUUID)
	varSelectTest=$(selectTest)

	echo "-------"
	echo "<BUILDFROM>${varBuildFrom}</BUILDFROM>"  >> taplogs/swupd/quick-swupd.t
	echo "<BUILDTO>${varBuildTo}</BUILDTO>"  >> taplogs/swupd/quick-swupd.t
	echo "<IMAGETYPE>KVM</IMAGETYPE>"  >> taplogs/swupd/quick-swupd.t
	echo "<DUT>KVM</DUT>"  >> taplogs/swupd/quick-swupd.t
	echo "<SOURCE>${varSelectTest}</SOURCE>"  >> taplogs/swupd/quick-swupd.t
	echo "<BUNDLES>${varBundles}</BUNDLES>"  >> taplogs/swupd/quick-swupd.t
	echo "<SENDBY>Knife Tool</SENDBY>"  >> taplogs/swupd/quick-swupd.t
	echo "<PATH>http://10.219.106.192/swupd-copy/results/</PATH>"  >> taplogs/swupd/quick-swupd.t
	echo "<TIME>${varTime}</TIME>" >> taplogs/swupd/quick-swupd.t
	echo "<IP>${varIP}</IP>" >> taplogs/swupd/quick-swupd.t
	echo "<UUID>${varUUID}</UUID>" >> taplogs/swupd/quick-swupd.t
}

getNumberLines
getBundles
getBuildFrom
getBuildTo
getTime
getIP
getUUID
writeTags
