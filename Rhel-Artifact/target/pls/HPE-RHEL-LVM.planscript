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

# Script to configure partition using LVM

upload -<<END /EFI/HPE/isdeploy/scripts/09LVM-Configure.bash
#! /bin/bash
# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "default" will send a empty
# line terminated with a newline to take the fdisk default.
echo " LVM Configuration Started"
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk @DiskName:/dev/sda@
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +@FirstPartitionSize:10@G # boot parttion
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
  +@SecondPartitionSize:10@G # leave blank(default) to extend partition to end of disk
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

#list all disks and partitions
lsblk 

#create physical volume
pvcreate @DiskName:/dev/sda@1 @DiskName:/dev/sda@2

#create physical volume forcefully 
if [ ! $? -eq 0 ]; then
echo y | pvcreate -ff @DiskName:/dev/sda@1
echo y | pvcreate -ff @DiskName:/dev/sda@2
fi

pvdisplay

#create logical volume group
vgcreate @LvmVolumeGroupName:new_vol_group@ @DiskName:/dev/sda@1 @DiskName:/dev/sda@2
vgs

#create logical volume
lvcreate -L@LvmVolumeSize:16@G -n @LvmVolumeName:new_vol@ @LvmVolumeGroupName:new_vol_group@
lvs

echo "Creating mount point"
mkdir /root/LVM-Data1

FS=@FileSystem:XFS@

if [ $FS == XFS ]
then
	mkfs.xfs /dev/@LvmVolumeGroupName:new_vol_group@/@LvmVolumeName:new_vol@
	echo "Formating with XFS fileSystem type"	
	mount /dev/@LvmVolumeGroupName:new_vol_group@/@LvmVolumeName:new_vol@ /root/LVM-Data1
	sed -i -e '$a\#This file has been altered by Image Streamer.' /etc/fstab
	sed -i -e '$a\/dev/@LvmVolumeGroupName:new_vol_group@/@LvmVolumeName:new_vol@ /root/LVM-Data1 xfs defaults 0 0' /etc/fstab	
	
elif  [ $FS == EXT4 ]
then
	mkfs.ext4 /dev/@LvmVolumeGroupName:new_vol_group@/@LvmVolumeName:new_vol@
	echo "Formating with EXT4 fileSystem type"	
	mount /dev/@LvmVolumeGroupName:new_vol_group@/@LvmVolumeName:new_vol@ /root/LVM-Data1
	sed -i -e '$a\#This file has been altered by Image Streamer.' /etc/fstab
	sed -i -e '$a\/dev/@LvmVolumeGroupName:new_vol_group@/@LvmVolumeName:new_vol@ /root/LVM-Data1 ext4 defaults 0 0' /etc/fstab
	
elif  [ $FS == BTRFS ]
then
	mkfs.btrfs 	/dev/@LvmVolumeGroupName:new_vol_group@/@LvmVolumeName:new_vol@
	echo "Formating with BTRFS fileSystem type"
	mount /dev/@LvmVolumeGroupName:new_vol_group@/@LvmVolumeName:new_vol@ /root/LVM-Data1
	sed -i -e '$a\#This file has been altered by Image Streamer.' /etc/fstab
	sed -i -e '$a\/dev/@LvmVolumeGroupName:new_vol_group@/@LvmVolumeName:new_vol@ /root/LVM-Data1 btrfs defaults 0 0' /etc/fstab
	
elif  [ $FS == Disabled ]
then
        echo "Removing mount point"
	rm -rf /root/LVM-Data1	
fi	

echo "LVM configuration completed"


exit 0
END