#!/bin/bash
#如果我们仔细分析，p2p网络和下面的二层网络不是同一个网络。

#p2p网络的cidr是140.252.13.64/27，而下面的二层网络的cidr是140.252.13.32/27

#所以对于slip来讲，对外访问的默认网关是13.66
docker exec -it slip ip route add default via 140.252.13.66 dev slipside
#root@93c0ae636e7b:/# route
#Kernel IP routing table
#Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
#default         140.252.13.66   0.0.0.0         UG    0      0        0 slipside
#140.252.13.64   *               255.255.255.224 U     0      0        0 slipside


#而对于bsdi来讲，对外访问的默认网关13.33
docker exec -it bsdi ip route add default via 140.252.13.33 dev eth1
#root@bebd516fd152:/# route
#Kernel IP routing table
#Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
#default         140.252.13.33   0.0.0.0         UG    0      0        0 eth1
#140.252.13.32   *               255.255.255.224 U     0      0        0 eth1
#140.252.13.64   *               255.255.255.224 U     0      0        0 bsdiside
#root@bebd516fd152:/# ip a
#1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#    inet 127.0.0.1/8 scope host lo
#       valid_lft forever preferred_lft forever
#21: eth1@if22: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
#    link/ether 1a:70:55:05:b0:0a brd ff:ff:ff:ff:ff:ff
#    inet 140.252.13.35/27 scope global eth1
#       valid_lft forever preferred_lft forever
#27: bsdiside@if28: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
#    link/ether 9e:1b:02:14:1a:79 brd ff:ff:ff:ff:ff:ff
#    inet 140.252.13.66/27 scope global bsdiside
#       valid_lft forever preferred_lft forever



#对于sun来讲，要想访问p2p网络，需要添加下面的路由表
docker exec -it sun ip route add 140.252.13.64/27 via 140.252.13.35 dev eth1
#root@741510da5b69:/# route
#Kernel IP routing table
#Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
#140.252.13.32   *               255.255.255.224 U     0      0        0 eth1
#140.252.13.64   140.252.13.35   255.255.255.224 UG    0      0        0 eth1




#对于svr4来讲，对外访问的默认网关是13.33
docker exec -it svr4 ip route add default via 140.252.13.33 dev eth1

#对于svr4来讲，要访问p2p网关，需要添加下面的路由表
docker exec -it svr4 ip route add 140.252.13.64/27 via 140.252.13.35 dev eth1
#root@01d8238776af:/# route
#Kernel IP routing table
#Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
#default         140.252.13.33   0.0.0.0         UG    0      0        0 eth1
#140.252.13.32   *               255.255.255.224 U     0      0        0 eth1
#140.252.13.64   140.252.13.35   255.255.255.224 UG    0      0        0 eth1


#这个时候，从slip是可以ping的通下面的所有的节点的。
