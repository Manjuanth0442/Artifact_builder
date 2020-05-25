# (C) Copyright 2018-2019 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

upload -<<END /EFI/HPE/isdeploy/scripts/03ibftTbonding-configuration.bash
echo "deployment nic's bonding script started"

cat <<'CONF'> /etc/init.d/ibftT
#! /bin/bash
# chkconfig: 345 99 10
# description: enable nic teaming for ibft interfaces

case "$1" in
start)

modprobe bonding

sleep 20
echo +ibftTeam > /sys/class/net/bonding_masters
echo 1 > /sys/class/net/ibftTeam/bonding/mode

FOUNDibft0=`grep "ibft0" /proc/net/dev`
FOUNDibft1=`grep "ibft1" /proc/net/dev`
echo "ibft0 : $FOUNDibft0"
echo "ibft1 : $FOUNDibft1"

if  [ -n "$FOUNDibft0" ]; then
ibftIP=`ip addr list ibft0 |grep -w "inet" |cut -d' ' -f6|cut -d'/' -f1`
Netmask=`ip addr list ibft0 |grep -w "inet" |cut -d' ' -f6|cut -d'/' -f2`
echo $ibftIP
echo $Netmask
else
ibftIP=`ip addr list ibft1 |grep -w "inet" |cut -d' ' -f6|cut -d'/' -f1`
Netmask=`ip addr list ibft1 |grep -w "inet" |cut -d' ' -f6|cut -d'/' -f2`
echo $ibftIP
echo $Netmask
fi

ip addr add $ibftIP/$Netmask dev ibftTeam


if [ -n "$FOUNDibft0" ]; then
ip addr flush dev ibft0
ip link set down ibft0
echo +ibft0 > /sys/class/net/ibftTeam/bonding/slaves
ip link set up ibftTeam
ip link set up ibft0
fi

if [ -n "$FOUNDibft1" ]; then
ip addr flush dev ibft1
ip link set down ibft1
echo +ibft1 > /sys/class/net/ibftTeam/bonding/slaves
ip link set up ibftTeam
ip link set up ibft1
fi


echo 100 > /sys/class/net/ibftTeam/bonding/miimon

iscsiadm -P 1 -m session

sleep 10

ip link set up ibft0
ip link set up ibft1
ip addr flush dev ibft0
ip addr flush dev ibft1

systemctl restart NetworkManager

;;
*)
echo "Usage: /sbin/service new-service {start|stop}"
exit 1
esac
exit 0


CONF

chmod 755 /etc/init.d/ibftT
chkconfig --add ibftT
systemctl enable ibftT
service ibftT start
systemctl start ibftT.service

echo "deployment nic bonding script ended"


END