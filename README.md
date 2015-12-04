# Advanced Tips for Docker use


### Docker run options
~~~
docker run -d --privileged=true \
-m 300M \
--memory-reservation=200M \
--memory-swappiness=0 \
--cpu-period=50000 \
--cpu-quota=50000 \
--name cn1 \
-h cn1 \
mcphub/ubuntu-sd:14.04
~~~

-d
--privileged=true
-m
--memory-reservation
--memory-swappiness
--cpu-period
--cpu-quota
--name
-h
