#!/bin/bash

B=""

#Read info.txt and extract line build number
function test(){
	while read line; do
#     echo $line # or whaterver you want to do with the $line variable
	   B=$(echo "$line" | grep  'VM Name*')
	   echo $B
	done < info.txt
}

#Save original version
function test2(){
	B2=$(test)
	echo $B2
	B=$(echo "$B2" | grep  -o '[0-9]*')
	echo $B > original_version.txt
}

test2