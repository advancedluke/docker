# Advanced Tips for Docker use

### Docker Install
~~~
wget -qO- https://get.docker.com/ | sh

sudo usermod -aG docker $(id -un)
sudo sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/g' /etc/default/grub
sudo update-grub
~~~

#### Change Docker Version (option)
~~~
wget https://get.docker.com/builds/Linux/x86_64/docker-<new_version>
sudo service docker stop
sudo mv /usr/bin/docker /usr/bin/docker-<old_version>
sudo mv docker-<new_version> /usr/bin/docker
sudo chmod +x /usr/bin/docker
~~~

### Docker run
~~~
docker run -d -p 80:80 --name my_image nginx
~~~

### Docker run - extra options
~~~
docker run -d \
--privileged=true \
-m 300M \
--memory-reservation=200M \
--memory-swappiness=0 \
--cpu-period=50000 \
--cpu-quota=50000 \
--name cn1 \
-h cn1 \
--restart=always
mcphub/ubuntu-sd:14.04
~~~

http://docs.docker.com/engine/reference/commandline/run/
