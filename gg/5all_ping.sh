#!/bin/bash
#添加从sun到netb的点对点网络
echo "add p2p from sun to netb"
#创建一个peer的网卡对
ip link add name sunside mtu 1500 type veth peer name netbside mtu 1500

#一面塞到sun的网络namespace里面
DOCKERPID3=$(docker inspect '--format={{ .State.Pid  }}' sun)
ln -s /proc/${DOCKERPID3}/ns/net /var/run/netns/${DOCKERPID3}
ip link set sunside netns ${DOCKERPID3}

#另一面塞到netb的网络的namespace里面
DOCKERPID4=$(docker inspect '--format={{ .State.Pid  }}' netb)
ln -s /proc/${DOCKERPID4}/ns/net /var/run/netns/${DOCKERPID4}
ip link set netbside netns ${DOCKERPID4}

#给sun里面的网卡添加地址
docker exec -it sun ip addr add 140.252.1.29/24 dev sunside
docker exec -it sun ip link set sunside up

#在sun里面，对外访问的默认路由是1.4
docker exec -it sun ip route add default via 140.252.1.4 dev sunside

#root@741510da5b69:/# route
#Kernel IP routing table
#Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
#default         140.252.1.4     0.0.0.0         UG    0      0        0 sunside
#140.252.1.0     *               255.255.255.0   U     0      0        0 sunside
#140.252.13.32   *               255.255.255.224 U     0      0        0 eth1
#140.252.13.64   140.252.13.35   255.255.255.224 UG    0      0        0 eth1
#root@741510da5b69:/# ip a
#1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#    inet 127.0.0.1/8 scope host lo
#       valid_lft forever preferred_lft forever
#23: eth1@if24: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
#    link/ether f2:36:37:8a:d0:79 brd ff:ff:ff:ff:ff:ff
#    inet 140.252.13.33/27 scope global eth1
#       valid_lft forever preferred_lft forever
#30: sunside@if29: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
#    link/ether de:90:24:8a:40:19 brd ff:ff:ff:ff:ff:ff
#    inet 140.252.1.29/24 scope global sunside
#       valid_lft forever preferred_lft forever



#在netb里面，对外访问的默认路由是1.4
docker exec -it netb ip route add default via 140.252.1.4 dev eth1

#在netb里面，p2p这面可以没有IP地址，但是需要配置路由规则，访问到下面的二层网络
docker exec -it netb ip link set netbside up
docker exec -it netb ip route add 140.252.1.29/32 dev netbside
docker exec -it netb ip route add 140.252.13.32/27 via 140.252.1.29 dev netbside
docker exec -it netb ip route add 140.252.13.64/27 via 140.252.1.29 dev netbside
#root@35e5dca815fe:/# ip a
#1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#    inet 127.0.0.1/8 scope host lo
#       valid_lft forever preferred_lft forever
#19: eth1@if20: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
#    link/ether ae:31:c9:80:6b:1c brd ff:ff:ff:ff:ff:ff
#    inet 140.252.1.183/24 scope global eth1
#       valid_lft forever preferred_lft forever
#29: netbside@if30: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
#    link/ether 3a:45:6f:95:45:07 brd ff:ff:ff:ff:ff:ff
#root@35e5dca815fe:/# route
#Kernel IP routing table
#Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
#default         140.252.1.4     0.0.0.0         UG    0      0        0 eth1
#140.252.1.0     *               255.255.255.0   U     0      0        0 eth1
#140.252.1.29    *               255.255.255.255 UH    0      0        0 netbside
#140.252.13.32   140.252.1.29    255.255.255.224 UG    0      0        0 netbside
#140.252.13.64   140.252.1.29    255.255.255.224 UG    0      0        0 netbside

#对于netb，配置arp proxy
echo "config arp proxy for netb"

#对于netb来讲，不是一个普通的路由器，因为netb两边是同一个二层网络，所以需要配置arp proxy，将同一个二层网络隔离成为两个。

#配置proxy_arp为1

docker exec -it netb bash -c "echo 1 > /proc/sys/net/ipv4/conf/eth1/proxy_arp"
docker exec -it netb bash -c "echo 1 > /proc/sys/net/ipv4/conf/netbside/proxy_arp"

#通过一个脚本proxy-arp脚本设置arp响应

#设置proxy-arp.conf
#eth1 140.252.1.29
#netbside 140.252.1.92
#netbside 140.252.1.32
#netbside 140.252.1.11
#netbside 140.252.1.4

#将配置文件添加到docker里面
docker cp proxy-arp.conf netb:/etc/proxy-arp.conf
docker cp proxy-arp netb:/root/proxy-arp

#在docker里面执行脚本proxy-arp
docker exec -it netb chmod +x /root/proxy-arp
docker exec -it netb /root/proxy-arp start

#配置上面的二层网络里面所有机器的路由
echo "config all routes"

#在aix里面，默认外网访问路由是1.4
docker exec -it aix ip route add default via 140.252.1.4 dev eth1

#在aix里面，可以通过下面的路由访问下面的二层网络
docker exec -it aix ip route add 140.252.13.32/27 via 140.252.1.29 dev eth1
docker exec -it aix ip route add 140.252.13.64/27 via 140.252.1.29 dev eth1

#同理配置solaris
docker exec -it solaris ip route add default via 140.252.1.4 dev eth1
docker exec -it solaris ip route add 140.252.13.32/27 via 140.252.1.29 dev eth1
docker exec -it solaris ip route add 140.252.13.64/27 via 140.252.1.29 dev eth1

#同理配置gemini
docker exec -it gemini ip route add default via 140.252.1.4 dev eth1
docker exec -it gemini ip route add 140.252.13.32/27 via 140.252.1.29 dev eth1
docker exec -it gemini ip route add 140.252.13.64/27 via 140.252.1.29 dev eth1

#通过配置路由可以连接到下面的二层网络
docker exec -it gateway ip route add 140.252.13.32/27 via 140.252.1.29 dev eth1
docker exec -it gateway ip route add 140.252.13.64/27 via 140.252.1.29 dev eth1

#到此为止，上下的二层网络都能相互访问了
