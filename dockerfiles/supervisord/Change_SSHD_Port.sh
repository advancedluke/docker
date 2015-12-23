### Run Containers with hostmode
# docker run -d --privileged=true --net=host --name=cn1 mcphub/ubuntu-sd-apache2:14.04

### Change SSHD port number of supervisord based sshd container
container_name=cn1
new_ssh_port=2222

### Check either the new port is availible or not
sudo nc -z localhost $new_ssh_port
if [ $? != 0 ]; then
     echo -e "The Port is Not in use"
else
     echo -e "Error : The Port is In Use"
     exit 1
fi

### Check current sshd port number
ssh_port=$(docker exec -it $container_name cat /etc/ssh/sshd_config | grep Port | grep -o '[0-9]\+')

### Change port number in sshd configuration file
docker exec -it $container_name sed -i "s/Port $ssh_port/Port $new_ssh_port/g" /etc/ssh/sshd_config

### Restart sshd with supervisorctl
docker exec -it $container_name supervisorctl restart sshd

### Or Restart the container
# docker restart $container_name

exit 0
