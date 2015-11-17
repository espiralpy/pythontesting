#!/bin/bash

IP=192.168.122.155

sed -i "4i\IP Address: "$IP info.txt
sed -i "5d" info.txt

function getName(){
    Name=`find info.txt -type f | xargs grep "VM Name:" | awk '{print $3}'`
    echo $Name
}

function getUUID(){
    UUID=`find info.txt -type f | xargs grep "UUID:" | awk '{print $2}'`
    echo $UUID
}

function sendFile(){
    varName=$(getName)
    varUUID=$(getUUID)
    FILE=$varName'-'$varUUID
    cp info.txt $FILE
    ./info.expect $FILE
}

getName
getUUID
sendFile


