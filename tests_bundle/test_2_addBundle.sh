#!/bin/bash

setup() {

#Updating image from staging

}

function  swupd:_bundle_add_for_remove (){
	swupd bundle-add storage-utils -VV
#	touch /usr/share/clear/bundles/storage-utils
#	swupd verify --url=http://clearlinux-sandbox.jf.intel.com/update/ --format=staging --fix -V

	echo 'quit' | parted > logout_add_bundle
	IP=`find logout_add_bundle -type f | xargs grep "GNU Parted"`
	echo $IP
	if grep 'GNU Parted' logout_add_bundle
    	then
        	echo "ok swupd:_bundle_add_for_remove"
	        echo "swupd:_bundle_add_for_remove %PASS -" >> /root/results.txt
    	else
        	echo "not ok swupd:_bundle_add_for_remove"
	        echo "swupd:_bundle_add_for_remove %FAIL -" >> /root/results.txt
    fi
}

setup
swupd:_bundle_add_for_remove
