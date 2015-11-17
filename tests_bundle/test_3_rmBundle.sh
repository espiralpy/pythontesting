#!/bin/bash


function  swupd:_bundle_add_for_remove (){
	swupd bundle-add storage-utils -VV
	touch /usr/share/clear/bundles/storage-utils
	swupd verify --url=http://clearlinux-sandbox.jf.intel.com/update/ --format=staging --fix -V

	echo 'quit' | parted > logout_add_bundle
	IP=`find logout_add_bundle -type f | xargs grep "GNU Parted"`
	echo $IP
	if grep 'GNU Parted' logout_add_bundle
    	then
        	echo "BUNDLE INSTALLED WORK AROUND"
    	else
        	echo "NOT BUNDLE INSTALLED WORK AROUND"
    fi
}

function  swupd:_bundle_rm (){
  swupd bundle-remove storage-utils -VV  > logout_rm_bundle
  parted 2> logout_parted
  
 if grep 'Bundle removed successfully' logout_rm_bundle
        then
            echo "ok swupd:_bundle_rm"
            echo "swupd:_bundle_rm %PASS -" >> /root/results.txt
        else
            echo "not ok swupd:_bundle_rm"
            echo "swupd:_bundle_rm %FAIL -" >> /root/results.txt
    fi


}

function  swupd:_command_removed (){
    if grep 'command not found' logout_parted
        then
            echo "ok swupd:_verify_command_removed"
            echo "swupd:_verify_command_removed %PASS -" >> /root/results.txt
	elif grep '-bash: /usr/bin/parted: No such file or directory' logout_parted
        then
            echo "not ok warning swupd:_verify_command_removed"
            echo "swupd:_verify_command_removed %PASS -" >> /root/results.txt
        else
            echo "not ok swupd:_bundle_add_for_remove"
            echo "swupd:_bundle_add_for_remove %FAIL -" >> /root/results.txt
    fi
}

setup
swupd:_bundle_add_for_remove
swupd:_bundle_rm
swupd:_command_removed
