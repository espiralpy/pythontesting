#!/bin/bash

source /root/tests_swupd/output.sh


setup() {

#Updating image from staging
       

        ORIGEN_VERSION=$(cat /root/original_version.txt)
        LAST_LOCALVERSION=$(cat /usr/share/clear/version)
        LATEST=$(curl http://clearlinux-sandbox.jf.intel.com/update/version/formatstaging/latest)

}

function  swupd:_complete_swupd_output (){
	
	if [ -f /root/results.txt ];
	then
	   rm /root/results.txt
	fi

	TAIL=$(tail -n 10 /root/swupd_output.txt)

	if grep 'Update complete. System updated from version' swupd_output.txt
	then
	    echo "ok swupd:_complete_swupd_output"
	    echo "swupd:_complete_swupd_output %PASS -" >> /root/results.txt
	elif  grep 'Update complete. System already up-to-date at version' /root/swupd_output.txt
	then
	    echo "ok swupd:_complete_swupd_output"
	    echo "swupd:_complete_swupd_output %PASS -" >> /root/results.txt
	elif grep 'Update complete, but some failures' /root/swupd_output.txt
	then
	    echo "not ok swupd:_complete_swupd_output"
	    echo "swupd:_complete_swupd_output %FAIL -" >> /root/results.txt
	elif grep 'Insufficient disk space' /root/swupd_output.txt
        then
            echo "not ok swupd:_complete_swupd_output"
            echo "swupd:_complete_swupd_output %FAIL -" >> /root/results.txt
	else
	    echo "not ok swupd:_complete_swupd_output"
	    echo "swupd:_complete_swupd_output %FAIL -" >> /root/results.txt
	fi
	
}

setup
logtest swupd:_from_sandbox "swupd update -v http://clearlinux-sandbox.jf.intel.com/update/ -c http://clearlinux-sandbox.jf.intel.com/update/ -V --format=staging | tee /root/swupd_output.txt"
swupd:_complete_swupd_output
#logtest swupd:_verify_usr/share/clear/version "[ $(( $LAST_LOCALVERSION )) -eq $(( $LATEST )) ]"


