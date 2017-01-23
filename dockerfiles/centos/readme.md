docker build -t cheese/centos-sd:7 .

docker run -d --privileged=true --name centos -h centos cheese/centos-sd:7
