#!/bin/bash

#预配置环境
#systemctl stop ufw
#systemctl disable ufw

#/sbin/iptables -P FORWARD ACCEPT

#echo 1 > /proc/sys/net/ipv4/ip_forward
#sysctl -p
#/sbin/iptables -P FORWARD ACCEPT

ovs-vsctl add-br br0
ovs-vsctl show

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

imagename='hub.c.163.com/liuchao110119163/ubuntu:tcpip'

echo "create all containers"
docker run --privileged=true --net none --name 200 -d ${imagename}
