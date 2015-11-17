#!/bin/bash

source /root/tests_swupd/output.sh


setup() {

#Updating image from staging
      

        ORIGEN_VERSION=$(cat /root/original_version.txt)
        LAST_LOCALVERSION=$(cat /usr/share/clear/version)
        LATEST_SANDBOX=$(curl http://clearlinux-sandbox.jf.intel.com/update/version/formatstaging/latest)
        LATEST_STAGING=$(curl http://clearlinux-staging.jf.intel.com/update/version/formatstaging/latest)
        VER_OS_RELEASE=$(find /usr/lib/os-release -type f | xargs grep "VERSION_ID=" | grep  -o '[0-9]*')
		rm releases.txt releases_staging.txt
}

function  swupd:_return_original_version_sandbox (){
    sleep 2
    swupd_basic_verify -f -m $ORIGEN_VERSION -V -u http://clearlinux-sandbox.jf.intel.com/update/ --format=staging
    if [[ "$VER_OS_RELEASE" == "$ORIGEN_VERSION" ]];
        then
            echo "ok swupd:_return_original_version_sandbox"
            echo "swupd:_return_original_version_sandbox %PASS -" >> /root/results.txt
        else
            echo "not ok swupd:_return_original_version_sandbox"
            echo "swupd:_return_original_version_sandbox %FAIL -" >> /root/results.txt
    fi

}

function  swupd:_return_original_version_staging (){
    sleep 2
    swupd_basic_verify -f -m $ORIGEN_VERSION -V -u http://clearlinux-staging.jf.intel.com/update/
    if [[ "$VER_OS_RELEASE" == "$ORIGEN_VERSION" ]];
        then
            echo "ok swupd:_return_original_version_staging"
            echo "swupd:_return_original_version_staging %PASS -" >> /root/results.txt
        else
            echo "not ok swupd:_return_original_version_staging"
            echo "swupd:_return_original_version_staging %FAIL -" >> /root/results.txt
    fi

}


function  swupd:_verify_specific_version_sandbox (){

    if [ -f /root/results.txt ];
    then
       rm /root/results.txt
    fi

    curl -s http://clearlinux-sandbox.jf.intel.com/releases/ | grep "<a href=" |  grep  -o '<a href="[0-9]*' | grep  -o '[0-9]*' > releases.txt

    LINE=$(grep -n -w "$ORIGEN_VERSION" releases.txt)
#    replace=${LINE/:$ORIGEN_VERSION/''}
#    sed "$replace"',$ d' releases.txt > forwardReleases.txt
#    filecontent=(`cat "forwardReleases.txt"`)
    filecontent=(`cat "releases.txt"`)
    RELEASE=${filecontent[2]}
    echo "-----"$RELEASE
	sleep 2
                swupd_basic_verify -f -m $RELEASE -V -u http://clearlinux-sandbox.jf.intel.com/update/ --format=staging
				echo ">>>>>>>>"$VER_OS_RELEASE
                if [[ "$VER_OS_RELEASE" == "$RELEASE" ]];
                then
                    echo "ok swupd:_verify_specific_version_sandbox"
                    echo "swupd:_verify_specific_version_sandbox %PASS -" >> /root/results.txt
                else
                    echo "not ok swupd:_verify_specific_version_sandbox"
                    echo "swupd:_verify_specific_version_sandbox %FAIL -" >> /root/results.txt

                fi


    echo "#########"
   echo "Latest = " $LATEST_SANDBOX
   echo "Origen version = "$ORIGEN_VERSION
   echo "Line = "$LINE
    echo "Longitut array = "${#filecontent[@]}
    echo "item"${filecontent[1]}
   echo "******************************************************"
}

function  swupd:_verify_specific_version_staging (){

    curl -s http://clearlinux-staging.jf.intel.com/releases/ | grep "<a href=" |  grep  -o '<a href="[0-9]*' | grep  -o '[0-9]*' > releases_staging.txt
    filecontent=(`cat "releases_staging.txt"`)
    RELEASE=${filecontent[2]}
#    echo "-----"$RELEASE
    sleep 2
    swupd_basic_verify -f -m $RELEASE -V -u http://clearlinux-staging.jf.intel.com/update/

    if [[ "$VER_OS_RELEASE" == "$RELEASE" ]];
    then
        echo "ok swupd:_verify_specific_version_staging"
        echo "swupd:_verify_specific_version_staging %PASS -" >> /root/results.txt
    else
        echo "not ok swupd:_verify_specific_version_staging"
        echo "swupd:_verify_specific_version_staging %FAIL -" >> /root/results.txt
    fi
}

setup
swupd:_verify_specific_version_sandbox
swupd:_return_original_version_sandbox
swupd:_verify_specific_version_staging
swupd:_return_original_version_staging