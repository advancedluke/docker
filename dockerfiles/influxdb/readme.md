# Supervisord + SSHD + influxdb

Base OS : Ubuntu 14.04

#### Usage

~~~
docker build -t influxdb:0.10 .
~~~

~~~
docker run -d --privileged=true --name influxdb -h influxdb --add-host="infuxdb:127.0.1.1" -p 8083:8083 -p 8086:8086 -p 8088:8088 -p 8091:8091 influxdb:0.10 
~~~
