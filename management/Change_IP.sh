# Custom Variables
container_name=cn1
new_ip=192.168.200.1
new_ip_prefix=16
vlan_id=10
default_gateway=192.168.20.1

# Automatic Variables
MACADDR="02:42:c0:$(dd if=/dev/urandom bs=512 count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\).*$/\1:\2:\3/')"
pid=$(docker inspect -f '{{.State.Pid}}' $container_name)
ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$@" $container_name)
ip_prefix=$(docker inspect --format '{{ .NetworkSettings.IPPrefixLen }}' "$@" $container_name)
hosts_path=$(docker inspect --format '{{ .HostsPath }}' "$@" $container_name)

# Execute Shell
sudo mkdir -p /var/run/netns
sudo ln -s /proc/$pid/ns/net /var/run/netns/$pid
sudo ip netns exec $pid ip link set eth0 down
sudo ip netns exec $pid ip addr del $ip/$ip_prefix dev eth0
sudo ip netns exec $pid ip addr add $new_ip/$new_ip_prefix dev eth0
#sudo ip netns exec $pid ip link add link eth0 name eth0.$vlan_id type vlan id $vlan_id
sudo ip netns exec $pid ip link set eth0 address $MACADDR
sudo ip netns exec $pid ip link set eth0 up
sudo ip netns exec $pid ip route add default via $default_gateway
sudo rm /var/run/netns/$pid
sudo cp $hosts_path /tmp/${container_name}_hosts
sudo sed -i "s/$ip/$new_ip/g" /tmp/${container_name}_hosts
docker exec -i $container_name bash -c 'cat > /etc/hosts' sudo rm -rf /tmp/${container_name}_hosts
sudo find -L /var/run/netns -type f -delete
