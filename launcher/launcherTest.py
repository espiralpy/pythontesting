#!/bin/python

import sys
import pycurl
import cStringIO
import os
import re
import commands
import threading
import time

URL_LATEST	= 'http://someurl.com'
URL_STAGING	= 'http://someurl.com'
IMG_HOSTNAME    = 'someurl.com'
PATH_RESOURCES	= '/var/taas/resources/'
EXIST_BUILD	= PATH_RESOURCES + 'existBuilds.txt'
NOT_EXIST_BUILD = PATH_RESOURCES + 'notExistBuilds.txt'
VIRSH_LIST	= PATH_RESOURCES + 'virsh_list.txt'
START_BUILD	= 5030
array = []

class Launcher(threading.Thread):
	def __init__(self):
        	self._amount = 3
		self._nbuild = None
		self._url = None
		self._urlsuffix = lambda number_build : '-kvm' if str(number_build) >= 5010 else ''
		self._array1=[]
		self._array2=[]
		self._array3=[]
		self._array4=[]
		self._freshImages=None

	@staticmethod
       	def url(url):
	       content = cStringIO.StringIO()
	       curl = pycurl.Curl()
               curl.setopt(curl.URL, url)
               curl.setopt(curl.WRITEFUNCTION, content.write)
               curl.perform()
               curl.close()
	       if (str(url) == str(URL_LATEST)):
			return content.getvalue().rstrip('\n')
	       else:
			return content.getvalue()

        def get_list_release(self):
	       self._list=[]
	       parse = re.findall('\href="[0-9]+', launcher.url(URL_STAGING))
	       for number in parse:
			self._list.append(int(number.replace('href="','')))
	       return self._list
	       
	def getImages(self):

		os.system('mkdir -p %s' % PATH_RESOURCES)
		saveExistBuild=open(EXIST_BUILD,"w")
		saveNotExistBuild=open(NOT_EXIST_BUILD,"w")

		for build in launcher.get_list_release():
                        self._url = r'http://%s/releases/%s/clear/clear-%s%s.img.xz' \
                                % (IMG_HOSTNAME, build, build, self._urlsuffix(self._nbuild))
                        curl_version = pycurl.Curl()
                        curl_version.setopt(curl_version.URL, self._url)
                        curl_version.setopt(curl_version.NOBODY, 1)
                        curl_version.perform()
                        error_code = curl_version.getinfo(pycurl.HTTP_CODE)

                        if error_code == 404:
				saveNotExistBuild.write(str(build) + "\n")
			else:
				if build >= START_BUILD:
 					saveExistBuild.write(str(build) + "\n")
                        curl_version.close()
		saveNotExistBuild.close()
		saveExistBuild.close()

	def getVirshList(self):
		os.system('virsh list > %s' % VIRSH_LIST)

	def getBuildsVirsh(self):
		f = open(VIRSH_LIST)
		line = f.readline()
		while line:
			if (re.findall("clear-[0-9]*-swsandbox", line)):
				self._array1.append(re.findall("clear-[0-9]*-swsandbox", line))
			line = f.readline()
		f.close()

	def getArrayExistBuilds(self):
		f = open(EXIST_BUILD)
                line = f.readline()
                while line:
                        self._array2.append(line)
			line = f.readline()
                f.close()

	def arrays(self):
		images=''

		##Get just number build from virsh list, cleaning string and saving in array
		for n in self._array1:
		         var = str(n)
			 var2=var.replace('clear-','');
			 var3=var2.replace("['", '');
			 var4=var3.replace("']", '');
			 self._array3.append(var4)
		print "ARRAY3"
		print self._array3
		##Get just number build from self._array2 and clean "\n"
		for j in self._array2:
			var=j.replace('\n','');
			if (var != ''):
				self._array4.append(var)
		#self.ommitRelease()
		print "AARAY$"
		print self._array4
		##Get differences between virsh list and existBuild.txt arrays.
		for m in self._array4:
			if m in self._array3:
				print ""
			else:
				#print ("no"+m)
				images+=m+","
				self._freshImages=images[:-1]
		print ">>" + str(self._freshImages)

	def fresh_images(self):

		return self._freshImages

	def ommitRelease(self):
#		self._array4.remove('4330')
		self._array4.remove('4320')
		self._array4.remove('4310')
                self._array4.remove('4000')
		self._array4.remove('1780')
                self._array4.remove('1770')
                self._array4.remove('1750')
                self._array4.remove('1740')
                self._array4.remove('1690')
		self._array4.remove('1640')
                self._array4.remove('1370')
                self._array4.remove('1360')
                self._array4.remove('1350')
                self._array4.remove('1340')
		self._array4.remove('1380')
		self._array4.remove('1330')
                self._array4.remove('1320')
                self._array4.remove('1310')
                self._array4.remove('1290')
                self._array4.remove('1280')
		self._array4.remove('1260')
                self._array4.remove('1250')
                self._array4.remove('1240')
                self._array4.remove('1230')
                self._array4.remove('1220')
		self._array4.remove('1210')
                self._array4.remove('1200')
                self._array4.remove('1190')
                self._array4.remove('1180')
                self._array4.remove('1150')
		self._array4.remove('1140')
                self._array4.remove('1130')
                self._array4.remove('1120')
                self._array4.remove('1100')
                self._array4.remove('1090')
		self._array4.remove('1080')
                self._array4.remove('1070')
                self._array4.remove('1060')
                self._array4.remove('1050')
                self._array4.remove('1040')
		self._array4.remove('1020')
                self._array4.remove('1000')
		self._array4.remove('990')
                self._array4.remove('980')
                self._array4.remove('970')
                self._array4.remove('960')
		self._array4.remove('940')
		self._array4.remove('930')
		self._array4.remove('920')
		self._array4.remove('910')
		self._array4.remove('900')
		self._array4.remove('890')
		self._array4.remove('870')
		self._array4.remove('860')
		self._array4.remove('850')
                self._array4.remove('840')
		self._array4.remove('830')
		self._array4.remove('820')
		self._array4.remove('810')
                self._array4.remove('800')
                self._array4.remove('790')
                self._array4.remove('780')
                self._array4.remove('770')
                self._array4.remove('760')
                self._array4.remove('750')
		self._array4.remove('740')
		self._array4.remove('730')
                self._array4.remove('720')
                self._array4.remove('710')
		self._array4.remove('700')
                self._array4.remove('690')
                self._array4.remove('680')
                self._array4.remove('670')
                self._array4.remove('660')
                self._array4.remove('650')
                self._array4.remove('640')

	def executeKnifeFresh(self):
		#execution for swupdsandbox
		os.system('sed -i "9i\BUILD_NUMBERS=%s" ../../SpecKnifeSwSandbox.cfg' % self._freshImages)
		os.system('sed -i "10d" ../../SpecKnifeSwSandbox.cfg')
		os.system('knife ../../SpecKnifeSwSandbox.cfg')
		#execution for bundle
		#os.system('sed -i "9i\BUILD_NUMBERS=%s" ../../SpecKnifeBundle.cfg' % self._freshImages)
                #os.system('sed -i "10d" ../../SpecKnifeBundle.cfg')
                #os.system('knife ../../SpecKnifeBundle.cfg')


	def requestWebPage(self):	
                curl_version = pycurl.Curl()
                curl_version.setopt(curl_version.URL, 'http://localhost/swupd/parserTaaS.php')
                curl_version.perform()
                curl_version.close()

	def deletefiles(self):
                os.system('rm %s' % EXIST_BUILD)
                os.system('rm %s' % NOT_EXIST_BUILD)
                os.system('rm %s' % VIRSH_LIST)

launcher = Launcher()
#print launcher.url(URL_LATEST)

#print (launcher.get_list_release())

#launcher.deletefiles()
#launcher.getImages()
#launcher.getVirshList()
#launcher.getBuildsVirsh()
launcher.getArrayExistBuilds()
launcher.arrays()
#if launcher.fresh_images() != None:
#	launcher.executeKnifeFresh()
#        launcher.requestWebPage()
print "Finish process launch.py"

