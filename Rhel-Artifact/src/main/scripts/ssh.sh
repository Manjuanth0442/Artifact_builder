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

# Script to Enable/Disable SSH and add valid ssh users

upload -<<END /EFI/HPE/isdeploy/scripts/08ssh_service.bash
#!/bin/bash
# This script was loaded by HPE Image Streamer
exec 1> >(logger -s -t $(basename $0)) 2>&1

ssh=@SSH:Enable@
ssh=$(echo "$ssh" | tr '[:upper:]' '[:lower:]')

echo "Starting manage-ssh-service using setting: $ssh"

if [ $ssh == enable ]
then
	
	echo "Enabling sshd to start at boot"
	systemctl enable sshd
    
	echo "Disabling Firewald"

	systemctl disable firewalld.service
      service firewalld stop

	echo "modifying /etc/ssh/sshd_config"
	cat <<-CONF>>/etc/ssh/sshd_config
	#
	#The following was added by HPE Image Streamer:
	PermitRootLogin yes
	CONF
	
	echo "Restarting sshd"
	systemctl restart sshd
else
	echo "Stopping sshd service"
	systemctl stop sshd

	echo "Disabling sshd from starting at boot"
	systemctl disable sshd
fi 

echo "Finished manage-ssh-service script"

exit 0
END