# Run Containers with hostmode
# docker run -d --privileged=true --net=host --name=cn1 mcphub/ubuntu-sd-apache2:14.04

### Change SSHD port number of supervisord based sshd container
container_name=cn1
new_ssh_port=2222

# Check current sshd port number
ssh_port=$(docker exec -it $container_name cat /etc/ssh/sshd_config | grep Port | grep -o '[0-9]\+')

# Change port number in sshd configuration file
docker exec -it $container_name sed -i "s/Port $ssh_port/Port $new_ssh_port/g" /etc/ssh/sshd_config

# Restart the container
docker exec -it $container_name supervisorctl restart sshd
# docker restart $container_name
