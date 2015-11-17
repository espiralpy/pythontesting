#!/bin/python

import MySQLdb
import sys
import threading
import os
import pycurl

PATH_RESOURCES  = '/var/taas/resources/'
IPs     	= PATH_RESOURCES + 'IPs.txt'
IPs_tmp         = PATH_RESOURCES + 'IPs_tmp.txt'

class Updates(threading.Thread):
        def __init__(self):
                self._array1=[]
	
	def get_IP(self):
		try:
			saveIP=open(IPs,"w")
  			db = MySQLdb.connect('localhost','swupd','knc@123','swupddb')
  			rs = db.cursor()
			rs.execute("select distinct idBuildFrom, idBuildTo, Source, DATE_FORMAT(ReportTimeStamp, '%Y %M %d %H:%i:%s'), IP from swupdate T1 where ReportTimeStamp = (select max(ReportTimeStamp) from swupdate T2 where T1.idBuildFrom=T2.idBuildFrom and T1.Source=T2.Source) and IP != '';") 
 			rows = rs.fetchall()
  			for row in rows:
			     saveIP.write(str(row)+"\n")
			saveIP.close()
		except MySQLdb.Error, e:
  			print "ERROR %d: %s" % (e.args[0], e.args[1])
			sys.exit(1)
		finally:
  			if db:
		    	    db.close()

		#clean extra character in file IPs
		os.system("find %s -type f | xargs grep '192' | awk '{print $12}' > ip_tmp1.txt" % IPs ) 
		replacements = {"'":"", ")":""}

		with open('ip_tmp1.txt') as infile, open('%s' % IPs_tmp, 'w') as outfile:
		    for line in infile:
		        for src, target in replacements.iteritems():
		            line = line.replace(src, target)
		        outfile.write(line)

		os.system("rm ip_tmp1.txt")

	def executeKnifeFresh(self):
                os.system('knife ../../SpecKnifeUpdates.cfg')

	def requestWebPage(self):
                curl_version = pycurl.Curl()
                curl_version.setopt(curl_version.URL, 'http://localhost/swupd/parserTaaS.php')
                curl_version.perform()
                curl_version.close()

launcher = Updates()
launcher.get_IP()
launcher.executeKnifeFresh()
launcher.requestWebPage()

