#!/bin/bash

source /root/tests_swupd/output.sh



function swupd:_show_ip (){
	IP=$(ip -o -4 add show | awk -F '[ /]+' '/global/ {print $4}')
	if [[ $IP != "" ]]
	then
        echo "ok swupd:_show_ip"
	    echo "swupd:_show_ip %PASS -" >> /root/results.txt
	else
		echo "not ok swupd:_show_ip"
	    echo "swupd:_show_ip %FAIL -" >> /root/results.txt
	fi
}

swupd:_show_ip
