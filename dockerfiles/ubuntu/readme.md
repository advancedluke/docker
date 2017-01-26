#### Build
    docker build -t cheese/ubuntu-sd:16.04 .

#### Push to Dockerhub
    docker push cheese/ubuntu-sd:16.04

##### Run with host's 2222 port
    docker run -d --privileged=true --name centos -h centos -p 2222:22 cheese/ubuntu-sd:16.04

##### Connetc from PC
    ssh -p 2222 cheese@localhost
