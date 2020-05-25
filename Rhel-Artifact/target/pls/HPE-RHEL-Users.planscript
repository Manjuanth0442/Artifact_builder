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

# Script to change root's password and add users

upload -<<END /EFI/HPE/isdeploy/scripts/05configure-users.bash
#!/bin/bash
# This script was loaded by HPE Image Streamer
exec 1> >(logger -s -t $(basename $0)) 2>&1

echo "Starting configure-users script for users: @NewUser@"

# Change root user password

echo "Changing root password"
echo "root:@NewRootPassword@" | chpasswd

# "Removing admin user added while creating GI"

userdel admin 
rm -rf /home/admin

# Add users
echo "Adding users"

#Add comments
sed -i -e '$a\#Following users added by HPE Image Streamer' /etc/passwd
sed -i -e '$a\#Following users added by HPE Image Streamer' /etc/group
users_string="@NewUser@"

#Users will be added with the same password. On first login users have to change their password.
password=@NewUsersPassword@
IFS=',; ' read -r -a array <<< "$users_string"
for user in "${array[@]}"
do
	if [ $(id -u) -eq 0 ]; 
	then
		egrep "$user" /etc/passwd >/dev/null
		if [ $? -eq 0 ]; 
		then
			echo "$user User exists!"
			exit 1
		else
			useradd -m $user
			echo "$user:$password" | chpasswd 
			[ $? -eq 0 ] && echo "User $user has been added to system!" || echo "Failed to add $user User!"
		fi
	else
		echo "Unable to add User $user"
 		exit 2
	fi
done

echo "Finished configure-users script"

exit 0
END