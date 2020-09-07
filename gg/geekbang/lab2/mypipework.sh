#!/bin/bash

:<< !
ovs-vsctl add-port ubuntu_br first_br
ovs-vsctl add-port ubuntu_br second_br
ovs-vsctl add-port ubuntu_br third_br
ovs-vsctl set Port vnet0 tag=101
ovs-vsctl set Port vnet1 tag=102
ovs-vsctl set Port vnet2 tag=103
ovs-vsctl set Port first_br tag=103
ovs-vsctl clear Port second_br tag
ovs-vsctl set Port third_br trunks=101,102
!
pipework br0 -i eth200 200 192.168.100.200/24@192.168.100.1
pipework br0 -i eth201 201 192.168.100.201/24@192.168.100.1
pipework br1 -i eth202 202 192.168.100.202/24@192.168.100.1
pipework br1 -i eth203 203 192.168.100.203/24@192.168.100.1

#ovs-vsctl add-port br0 first_br -- set Interface first_br type=patch options:peer=first_if
#ovs-vsctl add-port br1 first_if -- set Interface first_if type=patch options:peer=first_br
#ovs-vsctl add-port br1 second_br -- set Interface second_br type=patch options:peer=second_if
#ovs-vsctl add-port br1 second_if -- set Interface second_if type=patch options:peer=second_br
ip link add first_br type veth peer name first_if
ip link set first_br up
ip link set first_if up
#ip link set first_if down
#will delete first_br and first_if
#ip link delete first_if 
ip link add second_br type veth peer name second_if
ip link set second_br up
ip link set second_if up


ovs-vsctl add-bond br0 bond0 first_br second_br
ovs-vsctl add-bond br1 bond1 first_if second_if
#LACP (Link Aggregation Control Protocol)
ovs-vsctl set Port bond0 lacp=active
ovs-vsctl set Port bond1 lacp=active
#port=`ovs-vsctl show | grep -m 1 veth205 | awk -F '"' '{print $2}'`
#ovs-vsctl set Port $port trunks=101,102

#禁止mac地址学习是为了防止干扰实验,可以不运行
#ovs-vsctl set bridge ubuntu_br flood-vlans=101,102,103

ovs-vsctl show
ovs-appctl bond/show
ovs-appctl lacp/show

#默认情况下 bond_mode 是 active-backup 模式
ovs-vsctl set Port bond0 bond_mode=balance-slb
ovs-vsctl set Port bond1 bond_mode=balance-slb
