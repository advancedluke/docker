#Build
docker build -t cheese/centos-sd:7 .

#Push to Dockerhub
docker push cheese/centos-sd:7

#Run with host's 2222 port
docker run -d --privileged=true --name centos -h centos -p 2222:22 cheese/centos-sd:7

#Connetc from PC
ssh -p 2222 cheese@localhost
