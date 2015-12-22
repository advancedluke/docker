### Change SSHD port number of supervisord based sshd container

container_name=cn1
new_ssh_port=2222

# Check current sshd port number
ssh_port=$(docker exec -it $container_name netstat -apt | grep sshd | grep -v 'tcp6' | awk '{print $4}' | grep -o '[0-9]\+')

# Change port number in sshd configuration file
docker exec -it $container_name sed -i "s/Port $ssh_port/Port $new_ssh_port/g" /etc/ssh/sshd_config

# Restart the container
docker restart $container_name
