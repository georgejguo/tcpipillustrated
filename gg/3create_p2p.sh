#!/bin/bash

#添加从slip到bsdi的p2p网络
echo "add p2p from slip to bsdi"
#创建一个peer的两个网卡
ip link add name slipside mtu 1500 type veth peer name bsdiside mtu 1500

#把其中一个塞到slip的网络namespace里面

DOCKERPID1=$(docker inspect '--format={{ .State.Pid  }}' slip)
ln -s /proc/${DOCKERPID1}/ns/net /var/run/netns/${DOCKERPID1}
ip link set slipside netns ${DOCKERPID1}

#把另一个塞到bsdi的网络的namespace里面
DOCKERPID2=$(docker inspect '--format={{ .State.Pid  }}' bsdi)
ln -s /proc/${DOCKERPID2}/ns/net /var/run/netns/${DOCKERPID2}
ip link set bsdiside netns ${DOCKERPID2}

#给slip这面的网卡添加IP地址
docker exec -it slip ip addr add 140.252.13.65/27 dev slipside
docker exec -it slip ip link set slipside up

#给bsdi这面的网卡添加IP地址
docker exec -it bsdi ip addr add 140.252.13.66/27 dev bsdiside
docker exec -it bsdi ip link set bsdiside up



####################################################################################################
:<<
这里需要注意的是，上面的P2P 网络和下面的二层网络不是同一个网络。P2P 网络的 CIDR 是 140.252.13.64/27，
而下面的二层网络的 CIDR 是 140.252.13.32/27。如果按照 /24，看起来是一个网络，但是 /27 就不是了.
查看下svr4：
root@01d8238776af:/# route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
140.252.13.32   *               255.255.255.224 U     0      0        0 eth1


查看下slip：
root@93c0ae636e7b:/# route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
140.252.13.64   *               255.255.255.224 U     0      0        0 slipside


查看下bsdi：
root@bebd516fd152:/# route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
140.252.13.32   *               255.255.255.224 U     0      0        0 eth1
140.252.13.64   *               255.255.255.224 U     0      0        0 bsdiside

结论就是svr4与slip不通，因为从route看起来是不同的。但是bsdi与svr4可以通，与slip也可以通,因为iface有
两个。
!
####################################################################################################
