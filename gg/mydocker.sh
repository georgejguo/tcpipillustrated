#!/bin/bash

#预配置环境
#systemctl stop ufw
#systemctl disable ufw

#/sbin/iptables -P FORWARD ACCEPT

#echo 1 > /proc/sys/net/ipv4/ip_forward
#sysctl -p
#/sbin/iptables -P FORWARD ACCEPT


docker rm $(docker ps -a -q)

imagename='hub.c.163.com/liuchao110119163/ubuntu:tcpip'

echo "create all containers"
docker run --privileged=true --net none --name sun -d ${imagename}
#docker run --privileged=true --net none --name svr4 -d ${imagename}
#docker run --privileged=true --net none --name bsdi -d ${imagename}
#docker run --privileged=true --net none --name slip -d ${imagename}
