# -*- coding: utf-8 -*-

"""
Planscript Converter Utility Step 1
Converts Shell Scripts to PlanScript JSON files, along with a MANIFEST file.
Follows a 2 Step process:
    1)Creates a temporary file with scripts in guestfish format.
    2)Creates the final JSON file for each planscript and a MANIFEST file.
"""

from collections import OrderedDict
import json
import uuid
import yaml
import sys
import os
import hashlib
import shutil

from datetime import datetime, tzinfo, timedelta

js = '..\\..\\..\\Rhel-Artifact\\target\\js\\'
pls = '..\\..\\..\\Rhel-Artifact\\target\\pls\\'

try:  
    os.mkdir(js)
except OSError:  
    print ("Creation of the directory %s failed" % js)
else:  
    print ("Successfully created the directory %s " % js)
    
try:  
    os.mkdir(pls)
except OSError:  
    print ("Creation of the directory %s failed" % pls)
else:  
    print ("Successfully created the directory %s " % pls)    
 


""" Class with functions to return time in UTC format"""

class simple_utc(tzinfo):
    def tzname(self, **kwargs):
        return "UTC"
    def utcoffset(self, dt):
        return timedelta(0)
    

	
try:
	with open("../../../Rhel-Artifact/src/main/config.yml", 'r') as stream:  #Reading in the config file into a Python Dictionary
	    config_yaml=yaml.load(stream, Loader=yaml.FullLoader)
except:
    print ("Oops!", sys.exc_info()[0], "occured.")
    print ("Please provide yaml file with correct path and in correct format.")
    sys.exit(1)

"""
Loop to create temporary guestfish format script and then create PlanScript JSON for each entry
"""
    
for ps in config_yaml['plan_scripts']:
	fname = pls + ps['name'] + '.planscript'
	temp_ps = open(fname, "w")
	temp_ps.write(ps['copyright'])
	for files in ps['sources']:
		try:
			print (files['source'])
			with open(files['source'], 'r') as myfile:
				data = myfile.read()
		except:
			print ("Oops!", sys.exc_info()[0], "occured.")
			print ("Please provide correct source file path in the CONFIGURATION file.")
			sys.exit(1)
		temp_ps.write(data)
	temp_ps.close()

	name = ps['name']
	desc = ps['description']

	"""Creating PlanScript JSON"""

	with open(fname, 'r') as myfile:
		content = myfile.read()    
		
	uid = uuid.uuid4() #Generate a random UUID
	jdata = OrderedDict() 
	jdata['type'] = "PlanScript"
	jdata['uri'] = None
	jdata['category'] = None
	jdata['eTag'] = None
	jdata['created'] = None
	jdata['modified'] = None
	jdata['id'] = str(uid)
	jdata['name'] = name
	jdata['description'] = desc
	jdata['status'] = None
	jdata['state'] = None
	jdata['planType'] = ps['type']
	jdata['content'] = content
	jdata['customAttributes'] = None
	jdata['hpProvided'] = True
	jdata['dependentArtifacts'] = None

	json_file = js + str(uid) + '_planscript.json'
	##############################################
	with open(json_file, 'w') as fp:
		json_data = json.dump(jdata, fp)        


"""Fetch the time in UTC format, convert it into JAVA format"""

utc_time = datetime.utcnow().replace(tzinfo=simple_utc()).isoformat()
time = str(utc_time).replace('+00:00', 'Z')

"""Create MANIFEST FILE"""
man=js+"MANIFEST.MF"
manifest_file = open(man, "w")
manifest_file.write("Artifact Bundle:" + config_yaml['artifact_bundle']['name'] + '\n')    
manifest_file.write("Description:" + config_yaml['artifact_bundle']['description'] + '\n')
manifest_file.write("Read Only:" + str(config_yaml['artifact_bundle']['read_only']) + '\n')
manifest_file.write("Time Stamp:" + time + '\n')
manifest_file.write("Artifact Type: User" + '\n')
manifest_file.close()



path=js
dirs=os.listdir(path)
f1=open(path + "SHA256SUM.sha256sum","w")
for i in dirs:
    #print(i)
    path2 = path  + i
    #print(path2)
    with open(path2,"rb") as f:
        bytes = f.read() # read entire file as bytes
    readable_hash = hashlib.sha256(bytes).hexdigest();
    #print i, '\t', readable_hash 
    hesh = i + '\t' + readable_hash + '\n'
    f1.write(hesh)
    
f1.close()



try:
    with open("../../../Rhel-Artifact/src/main/config.yml", 'r') as stream:  #Reading in the config file into a Python Dictionary
        config_yaml=yaml.load(stream)
except:
    print ("Oops!", sys.exc_info()[0], "occured.")
    print ("Please provide yaml file with correct path and in correct format.")
    sys.exit(1)

try:
	destination=config_yaml['artifact_bundle']['name']
	print (destination)

	shutil.make_archive(destination, 'zip', js)
except:
    print ("Oops!", sys.exc_info()[0], "occured.")
	
sys.exit()	