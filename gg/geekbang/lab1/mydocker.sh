#!/bin/bash

#预配置环境
#systemctl stop ufw
#systemctl disable ufw

#/sbin/iptables -P FORWARD ACCEPT

#echo 1 > /proc/sys/net/ipv4/ip_forward
#sysctl -p
#/sbin/iptables -P FORWARD ACCEPT

ovs-vsctl del-br ubuntu_br
ovs-vsctl add-br ubuntu_br
ovs-vsctl show

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

imagename='hub.c.163.com/liuchao110119163/ubuntu:tcpip'

echo "create all containers"
docker run --privileged=true --net none --name 200 -d ${imagename}
docker run --privileged=true --net none --name 201 -d ${imagename}
docker run --privileged=true --net none --name 202 -d ${imagename}
docker run --privileged=true --net none --name 203 -d ${imagename}
docker run --privileged=true --net none --name 204 -d ${imagename}
docker run --privileged=true --net none --name 205 -d ${imagename}
