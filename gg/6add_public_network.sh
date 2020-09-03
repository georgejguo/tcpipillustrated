#!/bin/bash
#配置外网访问,所以这里使用的网卡必须可以ping通外网
publiceth='enp0s3'

echo "add public network"
#创建一个peer的网卡对
ip link add name gatewayin mtu 1500 type veth peer name gatewayout mtu 1500

ip addr add 140.252.104.1/24 dev gatewayout
ip link set gatewayout up

#一面塞到gateway的网络的namespace里面
DOCKERPID5=$(docker inspect '--format={{ .State.Pid  }}' gateway)
ln -s /proc/${DOCKERPID5}/ns/net /var/run/netns/${DOCKERPID5}
ip link set gatewayin netns ${DOCKERPID5}

#给gateway里面的网卡添加地址
docker exec -it gateway ip addr add 140.252.104.2/24 dev gatewayin
docker exec -it gateway ip link set gatewayin up

#在gateway里面，对外访问的默认路由是140.252.104.1/24
docker exec -it gateway ip route add default via 140.252.104.1 dev gatewayin

iptables -t nat -A POSTROUTING -o ${publiceth} -j MASQUERADE
ip route add 140.252.13.32/27 via 140.252.104.2 dev gatewayout
ip route add 140.252.13.64/27 via 140.252.104.2 dev gatewayout
ip route add 140.252.1.0/24 via 140.252.104.2 dev gatewayout

#执行本脚本之前的sun
#root@741510da5b69:/# route
#Kernel IP routing table
#Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
#default         140.252.1.4     0.0.0.0         UG    0      0        0 sunside
#140.252.1.0     *               255.255.255.0   U     0      0        0 sunside
#140.252.13.32   *               255.255.255.224 U     0      0        0 eth1
#140.252.13.64   140.252.13.35   255.255.255.224 UG    0      0        0 eth1
#
#执行本脚本之后的sun
#root@741510da5b69:/# route
#Kernel IP routing table
#Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
#default         cisco-asr.tuc.n 0.0.0.0         UG    0      0        0 sunside
#140.252.1.0     *               255.255.255.0   U     0      0        0 sunside
#140.252.13.32   *               255.255.255.224 U     0      0        0 eth1
#140.252.13.64   pipen15.tuc.noa 255.255.255.224 UG    0      0        0 eth1

#查看网关命令:
#root@741510da5b69:/# netstat -rn
#Kernel IP routing table
#Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
#0.0.0.0         140.252.1.4     0.0.0.0         UG        0 0          0 sunside
#140.252.1.0     0.0.0.0         255.255.255.0   U         0 0          0 sunside
#140.252.13.32   0.0.0.0         255.255.255.224 U         0 0          0 eth1
#140.252.13.64   140.252.13.35   255.255.255.224 UG        0 0          0 eth1
