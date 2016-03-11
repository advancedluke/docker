Telegraf Data Collector 

#### Install
~~~
wget http://get.influxdb.org/telegraf/telegraf_0.10.4.1-1_amd64.deb
sudo dpkg -i telegraf_0.10.4.1-1_amd64.deb
~~~

#### Configuration
~~~
telegraf -sample-config | sudo tee /etc/telegraf/telegraf.conf
~~~
