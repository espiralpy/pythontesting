#!/bin/bash

	rm -rf /etc/telemetrics
	mkdir /etc/telemetrics	#setup telemetry config file
	cp /usr/share/defaults/telemetrics/telemetrics.conf /etc/telemetrics	#setup telemetry config file
	if [ -f /etc/telemetrics/telemetrics.conf ]; then		#setup telemetry config file
        	sed -i 's/server=10.54.39.8/server=telemetry-staging.jf.intel.com/' /etc/telemetrics/telemetrics.conf	#use test telemetry server instead
	fi
	systemctl restart telemd.service	#restart telemd service so it takes the new changes
	sleep 1
	log_file="`mktemp`"
	strace -s 99999 -e sendto -o ${log_file} -p $(pgrep telemd) &	#listen to telemd for data
	proc=$!
	sleep 2
	swupd_update -v http://clear-.jf.intel.com/update -c http://clear-.jf.intel.com/update --format=staging  -V &>/dev/null
	sleep 10
	kill -9 $proc   #stop listening for telemd data
	server_file="`mktemp`" 
	curl -s http://telemetry-staging.jf.intel.com > ${server_file}
	machine_id="`grep -o "machine_id:..*" ${log_file} | cut -d' ' -f2 | cut -d\\\ -f1 | head -1`" 
	ts_capture="`grep -o "creation_timestamp:..*" ${log_file} | cut -d' ' -f2 | cut -d\\\ -f1 | head -1`"
	sleep 2
	result_machine_id="`grep -o "'machine_id': u'${machine_id}'" ${server_file} | cut -d' ' -f2 | cut -d\\\ -f1 | head -1 | cut -d\' -f2`"
	result_ts_capture="`grep -o "'ts_capture': ${ts_capture}" ${server_file} | cut -d' ' -f2 | cut -d\\\ -f1 | head -1 | cut -d\' -f2`"
	#echo $result_machine_id > swupdtelemd.log
	#echo $result_ts_capture > capture.log
	#echo $machine_id > logmachine.log
	#echo $ts_capture > tslog.log
	rm -f ${server_file} ${log_file}
	if [ "$result_machine_id" == "$machine_id" ] && [ "$result_ts_capture" == "$ts_capture" ]; then
		if [ "$result_machine_id" == "" ] && [ "$result_ts_capture" == "" ]; then
			echo "not ok swupd:_telemetrics"
            		echo "swupd:_telemetrics %FAIL -" >> /root/results.txt
		else
			echo "ok swupd:_telemetrics"
		   	echo "swupd:_telemetrics %PASS -" >> /root/results.txt
		fi
	else
		echo "not ok swupd:_telemetrics"
	    	echo "swupd:_telemetrics %FAIL -" >> /root/results.txt
	fi
	sleep 1
	rm -rf /etc/telemetrics
	sleep 1
	systemctl restart telemd.service #restart telemd so its config file is read from /usr/share/defaults




