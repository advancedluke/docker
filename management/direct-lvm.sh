### 1. LVM Install and Partitioning
# https://www.howtoforge.com/linux_lvm
# http://www.davelachapelle.ca/guides/ubuntu-lvm-guide/
# http://www.howtogeek.com/howto/40702/how-to-manage-and-use-lvm-logical-volume-management-in-ubuntu/
###

apt-get install lvm2 xfsprogs 
sudo apt-get install thin-provisioning-tools

sudo lvm version

sudo parted -l

sudo fdisk -l

sudo fdisk /dev/sdb
## n -> p -> enter -> enter -> enter -> t ->8e -> w

### 2. Docker Direct LVM Preperation
# https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/
# https://jpetazzo.github.io/2014/01/29/docker-device-mapper-resize/
# http://developerblog.redhat.com/2014/09/30/overview-storage-scalability-docker/
# https://raw.githubusercontent.com/dotcloud/docker/master/contrib/check-config.sh
###

sudo service docker stop
sudo rm -rf /var/lib/docker

### 3. Create Physical Volume
sudo pvcreate /dev/sdb1

## Remove Physical Volume
#sudo pvcremove /dev/sdb1

sudo pvdisplay

sudo vgscan
sudo vgdisplay

### 4. Create Volume Group as "direct-lvm"
sudo vgcreate direct-lvm /dev/sdb1

## Rename Volume Group
#sudo vgrename test-lvm direct-lvm

## Remove Volume Group
#sudo vgremove direct-lvm

sudo vgdisplay

### 5. Create Logical Volume
sudo lvscan
sudo lvdisplay

sudo lvcreate -n data direct-lvm -l 99%VG
sudo lvcreate -n metadata direct-lvm -l 100%FREE
#sudo lvcreate -n data direct-lvm -L 100G
#sudo lvcreate -n metadata direct-lvm -l 10G

## Rename Logical Volume
#sudo lvrename test-data data

## Remove Logical Volume
#sudo lvremove /dev/direct-lvm/data

sudo lvdisplay

### 6. Check Logical Volume Structures
sudo lsblk

### 7. Run Docker for function test
## Backend Storage Type : xfs
sudo docker daemon -D -s devicemapper --storage-opt dm.datadev=/dev/direct-lvm/data --storage-opt dm.metadatadev=/dev/direct-lvm/metadata --storage-opt dm.fs=xfs --storage-opt dm.basesize=5G

## Backend Storage Type : ext4
#sudo docker daemon -D -s devicemapper --storage-opt dm.datadev=/dev/direct-lvm/data --storage-opt dm.metadatadev=/dev/direct-lvm/metadata --storage-opt dm.fs=ext4 --storage-opt dm.basesize=5G

#sudo service docker start

### 8. Create and run test container
docker run -d --privileged=true --name cn1 -h cn1 mcphub/ubuntu-sd:14.04

### 9. Check Container Volume Test
docker exec -it cn1 apt-get update
docker exec -it cn1 apt-get install sysstat
docker exec -it cn1 dd if=/dev/zero of=outfile bs=1M count=2000 oflag=direct && iostat -x 1|grep sdc

### 10. Enlarge Container Size 
CNAME=cn1
SIZE=15
CID=$(exec docker inspect --format '{{ .GraphDriver.Data.DeviceName }}' $CNAME)
DEV=$(sudo basename $(echo /dev/mapper/$CID))
sudo dmsetup table $DEV |sudo sed "s/0 [0-9]* thin/0 $(($SIZE*1024*1024*1024/512)) thin/" | sudo dmsetup load $DEV
sudo dmsetup resume $DEV
## if backend storage type : xfs
sudo xfs_growfs /dev/mapper/$DEV
sudo xfs_info /dev/mapper/$DEV

## if backend storage type : ext4
#sudo resize2fs /dev/mapper/$DEV

## Check Container IP Address
exec docker inspect --format '{{ .NetworkSettings.IPAddress }}' cn1

### 11. LVM Management References

## Logical Volume Size Management Reference
#sudo lvdisplay
#sudo lvextend -L25G /dev/direct-lvm/data
#sudo lvextend -L+3G /dev/direct-lvm/data
#sudo lvreduce -L25G /dev/direct-lvm/data
#sudo lvreduce -L-2G /dev/direct-lvm/data

## Attach New Hard Drive Reference
#pvcreate /dev/sdc1
#vgextend direct-lvm /dev/sdc1
#pvmove /dev/sdb1 /dev/sdc1
#vgreduce direct-lvm /dev/sdb1
#pvremove /dev/sdb1
