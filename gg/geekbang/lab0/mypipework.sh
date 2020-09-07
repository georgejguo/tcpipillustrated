#!/bin/bash

pipework br0 -i eth200 200 192.168.200.200/24@192.168.200.1
ip addr add 192.168.200.1/24 dev br0
ip link set br0 up

ovs-vsctl show

#手动开启 IPv4 转发
echo 1 > /proc/sys/net/ipv4/ip_forward

#一步一步配置 iptables 防火墙
ufw disable
##设置默认允许所有INPUT和FORWARD包
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
##清空当前生效的防火墙规则。iptables -Z 重置流量计数器
iptables -F
iptables -t nat -F
iptables -t nat -F POSTROUTING
iptables -Z

#开启 NAT 转发
##第一条规则: 允许转发初始网络包
#iptables -A FORWARD  -s 192.168.200.0/24 -m conntrack --ctstate NEW -j ACCEPT
##第二条规则允许转发已经建立连接后的网络包: 允许任何地址到任何地址的确认包和关联包通过.一定要加这一条
#iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
#iptables -A FORWARD -s 192.168.200.0/24 -j ACCEPT
##MASQUERADE方式：从服务器的网卡(host)enp0s3上自动获取当前IP地址来做SNAT
iptables -t nat -A POSTROUTING -s 192.168.200.0/24 -o enp0s3 -j MASQUERADE

#ref:
#https://www.jianshu.com/p/2cbb812d336f
#https://blog.csdn.net/dhrome/article/details/59111174
