#!/bin/bash
ovs-vsctl del-br net1
ovs-vsctl del-br net2

echo "create bridges"
ovs-vsctl add-br net1
ip link set net1 up
ovs-vsctl add-br net2
ip link set net2 up

ovs-vsctl show
