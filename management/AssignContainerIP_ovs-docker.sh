## OVS Bridge Configuration References
# https://gist.github.com/noteed/8656989
# https://wiredcraft.com/blog/multi-host-docker-network/
# http://cloudgeekz.com/400/how-to-use-openvswitch-with-docker.html
# http://www.opencloudblog.com/?p=386
# http://www.openvswitch.org/support/config-cookbooks/vlan-configuration-cookbook/
# http://zcentric.com/2014/07/07/openvswitch-kvm-libvirt-ubuntu-vlans-the-right-way/
# https://pve.proxmox.com/wiki/Open_vSwitch
# http://git.openvswitch.org/cgi-bin/gitweb.cgi?p=openvswitch;a=blob;f=debian/openvswitch-switch.README.Debian;hb=HEAD
# OVS Patch : http://blog.scottlowe.org/2012/11/27/connecting-ovs-bridges-with-patch-ports/
# https://pve.proxmox.com/wiki/Open_vSwitch
# OVS Configuration Samples : http://git.openvswitch.org/cgi-bin/gitweb.cgi?p=openvswitch;a=blob;f=debian/openvswitch-switch.README.Debian;hb=HEAD
# - To temporarily enable IP forwarding, use sysctl -w net.ipv4.ip_forward=1. This will not persist across reboots.
# - To permanently enable IP forwarding, edit sysctl.conf so thatnet.ipv4.ip_forward is set to 1.

## Install OpenVSwitch
sudo add-apt-repository ppa:suawekk/openvswitch
sudo apt-get update
sudo apt-get install openvswitch-switch bridge-utils -y

# Check OVS Running
sudo ovs-vsctl show
ps -ea | grep ovs

## Config OVS Bridge

## Temporary ( for Testing )
default_gateway=192.168.0.254
ovs-vsctl add-br br0
ovs-vsctl add-port br0 eth0
ifconfig eth0 0.0.0.0
ifconfig br0 192.168.50.1/16
ip route add default via $default_gateway

## Perminant Save
## OVS Bridge with Single NIC
# /etc/network/interfaces

allow-ovs br0
iface br0 inet static
        address 192.168.50.1
        netmask 255.255.0.0
        gateway 192.168.0.254
        dns-nameservers 8.8.8.8
        ovs_type OVSBridge
        ovs_ports eth0

allow-br0 eth0
iface eth0 inet manual
        ovs_bridge br0
        ovs_type OVSPort

## Run Docker Container
docker run -d --net='none' --privileged=true --name cn1 -h cn1 mcphub/ubuntu-sd:14.04

## MCP Container Network Configuration
# Custom Variables
container_name=cn1
interface=eth0
ipaddress=192.168.0.201/16
gateway=192.168.0.254
#vlan_id=1                      ; #for vlan support
mtu=1450
# Automatic Variables
bridge=br0
macaddress="02:42:c0:$(dd if=/dev/urandom bs=512 count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\).*$/\1:\2:\3/')"
container_id=$(docker inspect -f '{{.Id}}' $container_name)
# Execute Shell
sudo ovs-docker add-port $bridge $interface $container_id --ipaddress=$ipaddress --gateway=$gateway --macaddress=$macaddress --mtu=$mtu
#sudo ovs-docker set-vlan $bridge $interface $container_id $vlan_id       ; #for vlan support   

## Restart/Stop Container
sudo ovs-docker del-ports $bridge $container_id
docker stop $container_id
