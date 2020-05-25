# (c) Copyright 2018-2019 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.


# Wrapper script to execute personalization scrips in ISROOT/scripts directory

upload -<<END /EFI/HPE/isdeploy/HPE-ImageStreamer.bash
#! /bin/bash

# This script was loaded by HPE Image Streamer

# setup
ISROOT="/boot/efi/EFI/HPE/isdeploy/"
LOGFILE="${ISROOT}../$(basename $0).log"

# prep
echo "$(/usr/bin/date)" >> ${LOGFILE} 2>&1
cd $ISROOT >> ${LOGFILE} 2>&1

# process
# - invoke all executables in sub-directory ./scripts (in lexographic order)
# 	assumes :
#		all scripts handle their own logging (for later debugging)
#		are independent/self-contained
#			(but can source info from other sub-directories/files)
#		if script run
#			succeeds, then script is moved to ./tmp 
#			has issues, leave in place (for later debug)
# - if entire process is
#	successful
#		remove top-level ISROOT directory
#	has errors
#		

RC=0

for i in $(/usr/bin/ls scripts/*)
do
# Note: execute status is really a function of the FAT partition mount
[ -n ${i} ] && [ -x ${i} ] && {

echo "=== ${i} "

if ${i};
then
/usr/bin/mv ${i} ./tmp
else
RC=1
fi
} >> ${LOGFILE} 2>&1
done

if [ ${RC} -eq 0 ];
then
{
	# temp saves

/usr/bin/cp -p $(/usr/bin/basename $0) ./tmp

 /usr/bin/rm -rf ${ISROOT}

} >> ${LOGFILE} 2>&1
else
{		
	/usr/bin/mv -f $(/usr/bin/basename $0) ${ISROOT}../
echo "Failures found, please review ${LOGFILE}"
} >> ${LOGFILE} 2>&1
fi



exit 0
END