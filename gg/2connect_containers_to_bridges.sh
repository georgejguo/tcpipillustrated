#!/bin/bash
echo "connect all containers to bridges"

./pipework net1 aix 140.252.1.92/24
./pipework net1 solaris 140.252.1.32/24
./pipework net1 gemini 140.252.1.11/24
./pipework net1 gateway 140.252.1.4/24
./pipework net1 netb 140.252.1.183/24

./pipework net2 bsdi 140.252.13.35/27
./pipework net2 sun 140.252.13.33/27
./pipework net2 svr4 140.252.13.34/27

ovs-vsctl show
