#!/bin/bash

# based on https://github.com/readloud/kali-router

# Interface that we want to monitor on
WIRED_MONITOR_INTERFACE=eth1
# Bridge between the above two interfaces (created on demand)
BRIDGE_INTERFACE=br0
# Interface that is connected to our regular network (e.g. Internet)
INTERNET_INTERFACE=eth0
# Network address range we use for our monitor network
MONITOR_NETWORK=172.16.0.0/12
# The address we assign to our router, dhcp, and dns server.
MONITOR_MAIN=172.16.0.1/24
# configuration directory
CONFIGDIR=./conf
# directory to which to write wireshark dumps
DUMPDIR=./dumps

# It monitors until we hit Ctrl c
trap ctrl_c INT
function ctrl_c(){
    echo Killing processes.
    sudo killall dnsmasq
    echo Bringing down interfaces.
    sudo ifconfig $WIRED_MONITOR_INTERFACE down
    sudo ifconfig $BRIDGE_INTERFACE down
    echo Deleting bridge
    sudo brctl delbr $BRIDGE_INTERFACE
}

# option to run script with " --down" to clear bridge
if [ "$1" = "--down" ];
then
echo Killing processes.
sudo killall dnsmasq
echo Bringing down interfaces.
sudo ifconfig $WIRED_MONITOR_INTERFACE down
sudo ifconfig $BRIDGE_INTERFACE down
echo Deleting bridge
sudo brctl delbr $BRIDGE_INTERFACE

exit 0
fi


# delete all addresses for wired
sudo ip addr flush dev $WIRED_MONITOR_INTERFACE
# bring the ethernet interface up
sudo ip link set dev $WIRED_MONITOR_INTERFACE up
# create bridge interface
sudo brctl addbr $BRIDGE_INTERFACE
# add the wire to the bridge
sudo brctl addif $BRIDGE_INTERFACE $WIRED_MONITOR_INTERFACE
# bring the bridge up
sudo ip link set dev $BRIDGE_INTERFACE up
sudo ip addr add $MONITOR_MAIN dev br0

# configure our DHCP server
sudo rm /tmp/dnsmasq.log
sudo dnsmasq -C $CONFIGDIR/dnsmasq.conf --log-queries --log-facility=/tmp/dnsmasq.log

# Add a forward rule for ipv4 traffic from MONITOR towards INTERNET
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -P FORWARD ACCEPT
sudo iptables -t nat -A POSTROUTING -o $INTERNET_INTERFACE -j MASQUERADE

# Configure tshark (wireshark) to write whatever passes over our monitored interface to a pcap file.
tshark -i $BRIDGE_INTERFACE -w $DUMPDIR/output.pcap -P
