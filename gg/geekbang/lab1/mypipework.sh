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
pipework ubuntu_br -i eth200 200 192.168.100.200/24@192.168.100.1 @101
pipework ubuntu_br -i eth201 201 192.168.100.201/24@192.168.100.1 @102
pipework ubuntu_br -i eth202 202 192.168.100.202/24@192.168.100.1 @103
pipework ubuntu_br -i eth203 203 192.168.100.203/24@192.168.100.1 @103
pipework ubuntu_br -i eth204 204 192.168.100.204/24@192.168.100.1
pipework ubuntu_br -i eth205 205 192.168.100.205/24@192.168.100.1

port=`ovs-vsctl show | grep -m 1 veth205 | awk -F '"' '{print $2}'`
ovs-vsctl set Port $port trunks=101,102

#禁止mac地址学习是为了防止干扰实验,可以不运行
#ovs-vsctl set bridge ubuntu_br flood-vlans=101,102,103

ovs-vsctl show
