export container=cn1
export user=ubuntu
export password=changeme!!@@

## Create User
docker exec $container useradd $user -m -s /bin/bash

## Change Password
docker exec $container sh -c "echo $user':'$password | chpasswd"

## Give user a sudoer permission
docker exec $container sh -c "echo $user ALL='('ALL')' NOPASSWD':'ALL > /etc/sudoers.d/$user"
docker exec $container chmod 0440 /etc/sudoers.d/$user

## Remove User
docker exec $container userdel -r $user
