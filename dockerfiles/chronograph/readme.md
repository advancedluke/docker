# Supervisord + SSHD + chronograf

Base OS : Ubuntu 14.04

#### Usage

- Build
~~~
docker build -t chronograf:0.10 .
~~~

- Run
~~~
docker run -d --privileged=true --name chronograf -h chronograf --add-host="chronograf:127.0.1.1" -p 10000:10000 -e "CHRONOGRAF_BIND=0.0.0.0:10000" chronograf:0.10 
~~~

- Web interface
~~~
http://<host_ip>:10000
~~~
