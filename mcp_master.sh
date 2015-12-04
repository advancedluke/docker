###############################
# MCP Master Node Configuration
# support@getmcp.com
# Updated on 2015-10-22
###############################

IP=$(hostname -i)
USER=$(id -un)
NET_IF=eth0

# Install Packages
sudo apt-get update && \
sudo apt-get install software-properties-common python-software-properties -y && \
sudo add-apt-repository ppa:gluster/glusterfs-3.7 -y && \
sudo add-apt-repository ppa:webupd8team/java -y && \
sudo add-apt-repository ppa:vbernat/haproxy-1.5 -y && \
sudo apt-get update && \
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && \
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections && \
sudo apt-get install oracle-java8-installer glusterfs-server dnsmasq -y && \
sudo apt-get install openvswitch-switch bridge-utils -y && \
sudo apt-get install haproxy


# Docker Install
wget -qO- https://get.docker.com/ | sh
sudo usermod -aG docker $USER
sudo sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/g' /etc/default/grub
sudo update-grub

# Make Glusterfs backend directory
sudo mkdir /glusterfs -p

# Create Gluster Volume MCP_VOL
sudo gluster volume create mcp_vol $IP:/glusterfs/mcp force
sudo gluster volume start mcp_vol

# Set Volume
sudo gluster volume quota mcp_vol enable
sudo gluster volume set mcp_vol quota-deem-statfs on

# Tunning
sudo gluster volume log rotate mcp_vol
sudo gluster volume set mcp_vol diagnostics.brick-log-level WARNING
sudo gluster volume set mcp_vol diagnostics.client-log-level WARNING
sudo gluster volume set mcp_vol nfs.enable-ino32 on
sudo gluster volume set mcp_vol nfs.addr-namelookup off
sudo gluster volume set mcp_vol nfs.disable on
sudo gluster volume set mcp_vol performance.cache-max-file-size 2MB
sudo gluster volume set mcp_vol performance.cache-refresh-timeout 4
sudo gluster volume set mcp_vol performance.cache-size 256MB
#sudo gluster volume set mcp_vol performance.write-behind-window-size 4M
sudo gluster volume set mcp_vol performance.io-thread-count 32

# MCP_FS Volume mount
sudo mkdir /mcp_fs
sudo sed -i '$ a\localhost:mcp_vol   /mcp_fs   glusterfs       defaults,_netdev        0       0' /etc/fstab
sudo mount -a

# Check Volume Mount
mount | grep "/mcp_fs" || echo "Error - The MCP Volume was not mounted"



# DNS Configuration ( Only in Master Node )
sudo mkdir /mcp_fs/mcp_conf/dns -p
sudo mkdir /mcp_fs/mcp_conf/hosts -p
sudo touch /mcp_fs/mcp_conf/dns/docker-container-hosts
sudo rm -f /etc/dnsmasq.d/mcp-dns && sudo touch /etc/dnsmasq.d/mcp-dns
sudo echo "addn-hosts=/msp_fs/mcp_conf/dns/docker-container-hosts" | sudo tee -a /etc/dnsmasq.d/mcp-dns
sudo echo "interface=$NET_IF" | sudo tee -a /etc/dnsmasq.d/mcp-dns

sudo service dnsmasq restart


# Docker Option Configuration
sudo service docker stop
sudo echo "DOCKER_OPTS=\"--insecure-registry image.mcp --insecure-registry snapshot.mcp\" " |sudo tee -a /etc/default/docker

##### ???
#DOCKER_OPTS="-H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock --storage-driver=devicemapper --storage-opt dm.override_udev_sync_check=true --storage-opt dm.basesize=20G --insecure-registry image.mcp --insecure-registry snapshot.mcp --insecure-registry hub.getmcp.com"
#####


## Install MCP Image Registries

docker run -d -p 5000:5000  --name="image-registry" --restart=always -v /data/mcp/registry/image:/data -e STORAGE_PATH=/data registry
docker run -d -p 5001:5000  --name="snapshot-registry" --restart=always -v /data/mcp/registry/snapshot:/data -e STORAGE_PATH=/data registry

docker run -d -p 6000:5000  --name="image-registry-2" --restart=always -v /data/mcp/registry2/image:/data -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data -e REGISTRY_STORAGE_DELETE_ENABLED=true registry:2
docker run -d -p 6001:5000  --name="snapshot-registry-2" --restart=always -v /data/mcp/registry2/snapshot:/data -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data -e REGISTRY_STORAGE_DELETE_ENABLED=true registry:2

curl -X GET http://image.mcp/v2/
curl -X GET http://image.mcp/v2/_catalog

curl -X GET http://localhost:6000/v2/search?q=ubuntu


## Setting HA Proxy



## Pull & Push Defatul MCP Images

docker pull mcphub/ubuntu-sd:14.04
docker pull mcphub/ubuntu-sd-apache2:14.04
docker pull mcphub/ubuntu-sd-tomcat7:14.04
docker tag mcphub/ubuntu-sd:14.04 image.mcp/ubuntu-sd:14.04
docker tag mcphub/ubuntu-sd-apache2:14.04 image.mcp/ubuntu-sd-apache2:14.04
docker tag mcphub/ubuntu-sd-tomcat7:14.04 image.mcp/ubuntu-sd-tomcat7:14.04
docker push image.mcp/ubuntu-sd:14.04
docker push image.mcp/ubuntu-sd-apache2:14.04
docker push image.mcp/ubuntu-sd-tomcat7:14.04
docker pull mcphub/centos-sd:7
docker tag mcphub/centos-sd:7 image.mcp/centos-sd:7
docker push image.mcp/centos-sd:7


## Install MCP Components

docker run -d -p 3306:3306 -m 2g --memory-swappiness=0 --cpu-period=50000 --cpu-quota=50000 --restart=always --name mcp-mariadb -e MYSQL_ROOT_PASSWORD=mcpprod! -e TERM=dumb -d mcphub/mariadb-utf8:10.0
docker run -d -p 18080:8080 -p 222:22 -m 1g --memory-swappiness=0 --cpu-period=50000 --cpu-quota=50000 --privileged=true --restart=always --name mcp-webconsole --link mcp-mariadb:mcp-mariadb mcphub/ubuntu-sd-java-8-tomcat7:14.04
docker run -d -p 5672:5672 -p 15672:15672 -p 3222:22 -m 2g --memory-swappiness=0 --cpu-period=50000 --cpu-quota=50000 --privileged=true --restart=always --name mcp-queue mcphub/mcp-queue


wget https://s3-ap-northeast-1.amazonaws.com/getmcp/Portal.sql
docker cp Portal.sql mcp-mariadb:Portal.sql

docker exec mcp-mariadb mysql -u root --password=mcpprod! -e "CREATE DATABASE IF NOT EXISTS portal;"
docker exec mcp-mariadb sh -c "mysql -u root --password=mcpprod! portal < Portal.sql"
rm Portal.sql

docker exec mcp-webconsole mkdir /data/deploy/webapps -p
docker exec mcp-webconsole mkdir /data/deploy/logs -p
docker exec mcp-webconsole chown tomcat7. /data/deploy -R
docker exec mcp-webconsole sed -i -e 's/\"webapps\"/\"\/data\/deploy\/webapps\"/g' -i -e 's/logs/\/data\/deploy\/logs/g' /var/lib/tomcat7/conf/server.xml
docker exec mcp-webconsole deluser --remove-home ubuntu

docker exec mcp-webconsole wget https://s3-ap-northeast-1.amazonaws.com/getmcp/Portal.war
#docker exec mcp-webconsole wget https://s3-ap-northeast-1.amazonaws.com/getmcp/keybox.war
docker exec mcp-webconsole mv Portal.war /data/deploy/webapps/ROOT.war
docker exec mcp-webconsole service tomcat7 restart
