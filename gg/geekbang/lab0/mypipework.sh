#!/bin/bash

pipework br0 -i eth200 200 192.168.100.200/24@192.168.100.1
ip addr add 192.168.100.1/24 dev br0
ip link set br0 up

ovs-vsctl show
