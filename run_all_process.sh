#!/bin/bash

function getPrefix(){
    PREFIX=`find info.txt -type f | xargs grep "VM Prefix Name: " | awk '{print $4}'`
    echo $PREFIX
}

function  selectTest(){
	varPrefix=$(getPrefix)
    echo $varPrefix
	case $varPrefix in
		""|"swsandbox")
			echo "**************KnifeTool Test...starting******************"
			executeKnifeToolTests
			;;
		"bundle")
			echo "**************KnifeTool Test...starting******************"
			executeRemoveBundle
			;;
	esac


}

function executeKnifeToolTests(){
	mkdir -p taplogs/swupd/
	./get_original_version.sh
	./tests_swupd/test_1_swupd.sh
	./tests_swupd/test_2_telemetrics.sh
	./tests_swupd/test_3_interfaces.sh
	./get_tags.sh
	./test_hook_sendlog.sh
}

function executeRemoveBundle(){
	mkdir -p taplogs/swupd/
	./get_original_version.sh
	./tests_bundle/test_1_swupd.sh 
	./tests_bundle/test_2_addBundle.sh
	./tests_bundle/test_3_rmBundle.sh
	./get_tags.sh
	./test_hook_sendlog.sh
}

getPrefix
selectTest
