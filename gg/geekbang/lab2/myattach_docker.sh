#!/bin/bash
#$1(0, 1, 2, 3, 4, 5)为第几个dockr, docker name依次对应为200，201，202，203，204，205
n=`docker ps -a -q | wc -l` 
var="NR==$n-$1{print}"
id=$(docker ps -a -q |  awk $var)
docker exec -it $id /bin/bash
