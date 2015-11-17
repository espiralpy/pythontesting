#!/bin/python

import MySQLdb
import sys
import threading
import os
import pycurl
import re
import subprocess

FILE_NUMBER_CONSOLS  = 'consols.txt'
FILE_DUMP            = 'dumpxml.txt'
FILE_MACS_IP	     = 'mac_ip.txt'
FILE_REPLACE	     = 'replace_ip.sh'

class Updates(threading.Thread):
        def __init__(self):
                self._consoles = []
		self._mac      = []
		self._ip       = []

	def runUpVM(self):	
		####os.path.abspath(".xml")

		os.remove('recovery_vm.txt')
		os.system('find /var/taas/ | grep .xml > recovery_vm.txt')

		f = open('recovery_vm.txt')
		line = f.readline()
		while line:
		      print line
		      os.system('virsh create %s' % line)
		      line = f.readline()
		f.close()

	def deleteFiles(self):
		 os.system("rm %s" % FILE_NUMBER_CONSOLS)
		 os.system("rm %s" % FILE_MACS_IP )
		 os.system("rm %s" % FILE_DUMP )
		 os.system("rm /var/taas/resources/recovery_files/*")
		 
	def getVirshList(self):
		os.system("mkdir -p /var/taas/resources/recovery_files")
                os.system("virsh list | grep 'clear' | awk '{print $1}' > %s" % FILE_NUMBER_CONSOLS)

	def getConsole(self):
                f = open(FILE_NUMBER_CONSOLS)
                line = f.readline()
                while line:
                        self._consoles.append(line.replace('\n',''))
			line = f.readline()
                f.close()

	def getMac(self):
		for console in self._consoles:
	        	os.system('virsh dumpxml %s > %s ' % (console, FILE_DUMP))			
			pattern = re.compile("<mac address=")

			for i, line in enumerate(open('%s' % FILE_DUMP)):
    				for match in re.finditer(pattern, line):
					a = line.replace('<mac address=\'', '')
					b = a.replace('\n', '')
					mac = b.replace('\'/>', '')
					self._mac.append(mac)
		print self._mac	
	def getNewIP(self):
		for mac in self._mac:
			os.system("arp | grep %s  >> 1" % mac)
                	os.system("arp | grep %s | awk '{print $1}' >> %s" % (mac, FILE_MACS_IP))
		f= open(FILE_MACS_IP)
		line = f.readline()
		while line:
			os.system('sed -i "3d" %s' % FILE_REPLACE )
			os.system('sed -i "3i\IP=%s" %s' % (line, FILE_REPLACE ))
			os.system('scp -oStrictHostKeyChecking=no -q /var/taas/resources/knife_taas/launcher/info.expect  root@"%s":.' % line)
			os.system('scp -oStrictHostKeyChecking=no -q /var/taas/resources/knife_taas/launcher/replace_ip.sh  root@"%s":.' % line)
			helper = Helper()
	                helper.remote_cmd('/usr/bin/chmod a+x /root/*', line)
        	        helper.remote_cmd('/bin/sh /root/replace_ip.sh', line)
			print "Replaced info.txt for "+line
			line = f.readline()
                f.close()
	def insertIP(self):
		ficheros  = os.listdir('/var/taas/resources/recovery_files')
		listIP	  = []
		listUUID  = []
		#print ficheros		
		for file in ficheros:
			#print file
			f = open('/var/taas/resources/recovery_files/'+file)
	                line = f.readline()
        	        while line:
  				#buildFindall = re.findall('BuildFrom: ([0-9]*)', line)
				UUIDFindall  = re.findall('UUID: (.*)', line)
				ipFindall    = re.findall('IP Address: (.*)', line)
				
				if UUIDFindall:
					listUUID.append(UUIDFindall)
				if ipFindall:
                                        listIP.append(ipFindall)
        	                line = f.readline()
                	f.close()
		
		for n in range(len(listUUID)):
			print listIP[n], listUUID[n]
			#print launcher.cleanIP(listIP[n])
			#print launcher.cleanIP(listUUID[n])
			try:                        
                        	db = MySQLdb.connect('localhost','swupd','knc@123','swupddb')
                        	rs = db.cursor()
                        	rs.execute("UPDATE swupdate SET IP='%s' WHERE UUID='%s'" % (launcher.cleanIP(listIP[n]), launcher.cleanIP(listUUID[n])))
				db.commit()

	                except MySQLdb.Error, e:
        	                print "ERROR %d: %s" % (e.args[0], e.args[1])
                	        sys.exit(1)
	                finally:
        	                if db:
                	            db.close()
	@staticmethod
	def cleanIP(content):
		a = str(content).replace('[\'', '')
        	b = a.replace('\']', '')
		return b
	
class Helper(object):
        def remote_cmd(self, rcmd, ipaddr):
                cmd = ['ssh', '-oStrictHostKeyChecking=no', 'root@'+ipaddr, rcmd]
                f = open(os.devnull, 'w')
                p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                f.close()
                out, err = p.communicate()
                print out

launcher = Updates()
launcher.runUpVM()
launcher.getVirshList()
launcher.getConsole()
launcher.getMac()
launcher.getNewIP()
launcher.insertIP()
launcher.deleteFiles()
