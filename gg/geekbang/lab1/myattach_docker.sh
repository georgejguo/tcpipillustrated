#!/bin/bash
#$1为第几个dockr, docker name依次为200，201，202，203，204，205
var="NR==7-$1{print}"
id=$(docker ps -a -q |  awk $var)
docker exec -it $id /bin/bash
