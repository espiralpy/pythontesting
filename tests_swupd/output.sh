#!/bin/bash

function output(){

    echo $1
    if [[ $($2) ]] ;
        then echo "ok" $1;
        else echo "not" $1 ;
    fi

}

function print_log {
   echo "`date +"%F %T.%N"` $@"
}

function error {
   print_log "ERROR" $@
}

function warn {
   print_log "WARN" $@
}

function info {
   print_log "INFO" $@
}

function debug {
   print_log "DEBUG" $@
}

function logtest {
    test_name=$1
    shift
    test_cmd=$@

    #info "Running: $test_cmd"
    result=$(eval $test_cmd 2>&1)
    if [ $? -eq 0 ]; then
        echo "ok $test_name"
        echo "$test_name %PASS -" >> /root/results.txt
    else
        error "not ok swupd: $test_name"
        echo $result
        echo "$test_name %FAIL -" >> /root/results.txt
        echo $result >> /root/results.txt
    fi
}

