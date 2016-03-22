# Supervisord + SSHD 

Base OS : Ubuntu 14.04

#### Usage

- Build
~~~
docker build -t ubuntu-sd:14.04
~~~

- Run Container
~~~
docker run -d --privileged=true -m 300M --memory-reservation=200M --memory-swappiness=0 --cpu-period=50000 --cpu-quota=50000 --name cn1 -h cn1 mcphub/ubuntu-sd:14.04
~~~
