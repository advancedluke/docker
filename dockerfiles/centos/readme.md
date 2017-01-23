docker build -t cheese/centos-sd:7 .

docker run -d --privileged=true --name cn1 -h cn1 cheese/centos-sd:7
