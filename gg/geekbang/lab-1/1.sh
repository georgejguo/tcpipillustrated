# ip netns add ns1 // ip netns del ns1
# ip netns pids ns1 //显示为空,ns1没有与任何进程绑定

# echo $$
1764
# ip netns exec ns1 bash
# echo $$
5454
# exit

# ip a
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:8f:75:7f brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 47056sec preferred_lft 47056sec
    inet6 fe80::a00:27ff:fe8f:757f/64 scope link
       valid_lft forever preferred_lft forever
# ip netns exec ns1 ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00


# ip link set enp0s3 netns ns1
# ip netns exec ns1 ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp0s3: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 08:00:27:8f:75:7f brd ff:ff:ff:ff:ff:ff

# ip netns exec ns1 bash
# ifconfig enp0s3 10.0.2.15/24
# ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:8f:75:7f brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe8f:757f/64 scope link
       valid_lft forever preferred_lft forever
# ping 10.10.3.110
connect: Network is unreachable
# route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.2.0        0.0.0.0         255.255.255.0   U     0      0        0 enp0s3
# ip route
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15
# route add default gw 10.0.2.2
# route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         10.0.2.2        0.0.0.0         UG    0      0        0 enp0s3
10.0.2.0        0.0.0.0         255.255.255.0   U     0      0        0 enp0s3
# ip  route
default via 10.0.2.2 dev enp0s3
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15
# ping 10.10.3.110 -c 2
PING 10.10.3.110 (10.10.3.110) 56(84) bytes of data.
64 bytes from 10.10.3.110: icmp_seq=1 ttl=62 time=1.85 ms
64 bytes from 10.10.3.110: icmp_seq=2 ttl=62 time=0.859 ms
# exit
****************************************************************************************************
# 将接口移出网络命名空间
# ip netns exec ns1 ip link set enp0s3 netns 1
# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:8f:75:7f brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 86397sec preferred_lft 86397sec
    inet6 fe80::a00:27ff:fe8f:757f/64 scope link
       valid_lft forever preferred_lft forever
# ip netns exec ns1 bash
# ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
