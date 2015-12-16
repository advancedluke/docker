#### Reference
https://docs.docker.com/engine/articles/systemd/

#### Docker 환경 설정

/lib/systemd/system/docker.service

~~~
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target docker.socket
Requires=docker.socket

[Service]
EnvironmentFile=-/etc/default/docker
ExecStart=/usr/bin/docker daemon $DOCKER_OPTS -H fd://
MountFlags=slave
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
~~~

sudo systemctl daemon-reload

sudo systemctl start docker 
sudo service docker start

sudo systemctl status docker
sudo service docker status
