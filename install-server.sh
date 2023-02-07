#!/bin/bash
# Ubuntu 22.04 - 2023.01.07

# deploy a master true/false:
is_master=false

if [ "$is_master" = "true" ];
then
  master=host-$(hostname -I | awk '{$1=$1};1' | sed 's/\./-/'g)
else
  master="host-192-168-2-70"
fi

#####################################################################################


sudo adduser spark
cd /home/spark

sudo apt update -y
# better not to do this, so we all have consistent environment.
#sudo apt upgrade -y

sudo apt install -y \
  net-tools \
  curl \
  openjdk-11-jdk-headless \
  cron

# Spark requires all hosts to have a hostname that other hosts can resolve. There is no DNS in SNIC...
# delete the entries from hosts..
sudo sed -i '/\[192\.168\]/d' /etc/hosts
for i in {1..4};
do
  for j in {1..255};
  do
      echo "192.168.$i.$j host-192-168-$i-$j" | sudo tee -a /etc/hosts
  done
done
sudo hostname host-$(hostname -I | awk '{$1=$1};1' | sed 's/\./-/'g) ; hostname
# It needs to be set each boot... this doesn't seem to work anyway so we put it in the service script also...
echo @reboot hostname host-$(hostname -I | awk '{$1=$1};1' | sed 's/\./-/'g) | sudo tee -a /etc/crontab


curl https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz --output hadoop.tgz
tar --extract --file hadoop.tgz
mv hadoop-3.3.4 hadoop
chown -r spark hadoop

echo HADOOP_HOME=/home/spark/hadoop  | sudo tee -a /etc/environment
echo JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64  | sudo tee -a /etc/environment

export HADOOP_HOME=/home/spark/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

sudo mkdir /home/spark/hadoop/nameNode
sudo mkdir /home/spark/hadoop/dataNode
sudo mkdir /home/spark/hadoop/logs

echo '
<configuration>
    <property>
      <name>fs.defaultFS</name>
      <value>hdfs://'$master':9000</value>
  </property>
</configuration>' | sudo tee /home/spark/hadoop/etc/hadoop/core-site.xml

echo '
<configuration>

<property>
  <name>dfs.namenode.name.dir</name>
  <value>/home/spark/hadoop/nameNode</value>
</property>

<property>
  <name>dfs.datanode.data.dir</name>
  <value>/home/spark/hadoop/dataNode</value>
</property>

<!-- Otherwise we get Datanode denied communication with namenode because hostname cannot be resolved
<property>
  <name>dfs.namenode.datanode.registration.ip-hostname-check</name>
  <value>false</value>
</property>
-->

<property>
  <name>dfs.permissions.enabled</name>
  <value>false</value>
</property>

<property>
  <name>dfs.replication</name>
  <value>3</value>
</property>

<property>
  <name>dfs.namenode.rpc-bind-host</name>
  <value>0.0.0.0</value>
  <description>
    The actual address the RPC server will bind to. If this optional address is
    set, it overrides only the hostname portion of dfs.namenode.rpc-address.
    It can also be specified per name node or name service for HA/Federation.
    This is useful for making the name node listen on all interfaces by
    setting it to 0.0.0.0.
  </description>
</property>
</configuration>' | sudo tee /home/spark/hadoop/etc/hadoop/hdfs-site.xml

sudo chown -R spark /home/spark/hadoop

if [ "$is_master" = "true" ];
then
sudo -H -u spark /bin/bash -c '/home/spark/hadoop/bin/hdfs namenode -format'
fi




curl https://dlcdn.apache.org/spark/spark-3.2.3/spark-3.2.3-bin-hadoop3.2.tgz --output spark.tgz
tar --extract --file spark.tgz
mv spark-3.2.3-bin-hadoop3.2 spark
mkdir spark/logs

# Install the Web GUI auth filter... some of these dont actally apply here...
git clone --depth=1 https://github.com/benblamey/de1-2023.git
sudo cp de1-2023/out/artifacts/de1_2023/de1-2023.jar spark/jars/
echo '
spark.ui.filters                                  com.benblamey.spark.BasicAuthFilter
spark.cores.max                                   8
spark.shuffle.service.enabled                     true
spark.dynamicAllocation.enabled                   true
spark.dynamicAllocation.executorIdleTimeout       120s
spark.dynamicAllocation.shuffleTracking.enabled   true
' | sudo tee spark/conf/spark-defaults.conf

sudo chown -R spark /home/spark/spark






# This is a legacy service script, since the linux distro is old...
if [ "$is_master" = "true" ];
then
echo '#!/bin/sh
### BEGIN INIT INFO
# Required-Start:
# Required-Start:    $remote_fs $syslog $network
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

case "$1" in
  start)
    sudo hostname host-$(hostname -I | awk '\''{$1=$1};1'\'' | sed '\''s/\./-/'\''g) ; hostname
    sudo -H -u spark /bin/bash -c '\''/home/spark/hadoop/bin/hdfs --daemon start namenode'\''
    sudo -H -u spark /bin/bash -c '\''/home/spark/spark/sbin/start-master.sh'\''
    ;;
  stop)
    sudo -H -u spark /bin/bash -c '\''/home/spark/hadoop/bin/hdfs --daemon stop namenode'\''
    sudo -H -u spark /bin/bash -c '\''/home/spark/spark/sbin/stop-master.sh'\''
    ;;
  restart)
    sudo hostname host-$(hostname -I | awk '\''{$1=$1};1'\'' | sed '\''s/\./-/'\''g) ; hostname
    sudo -H -u spark /bin/bash -c '\''/home/spark/hadoop/bin/hdfs --daemon stop namenode'\''
    sudo -H -u spark /bin/bash -c '\''/home/spark/spark/sbin/stop-master.sh'\''
    sudo -H -u spark /bin/bash -c '\''/home/spark/hadoop/bin/hdfs --daemon start namenode'\''
    sudo -H -u spark /bin/bash -c '\''/home/spark/spark/sbin/start-master.sh'\''
    ;;
  *)
    exit 1
esac
exit $?' | sudo tee /etc/init.d/sparkdaemon
else
echo '#!/bin/sh
### BEGIN INIT INFO
# Required-Start:
# Required-Start:    $remote_fs $syslog $network
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

case "$1" in
  start)
    sudo hostname host-$(hostname -I | awk '\''{$1=$1};1'\'' | sed '\''s/\./-/'\''g) ; hostname
    sudo -H -u spark /bin/bash -c '\''/home/spark/hadoop/bin/hdfs --daemon start datanode'\''
    sudo -H -u spark /bin/bash -c '\''/home/spark/spark/sbin/start-slave.sh spark://'$master':7077'\''
    ;;
  stop)
    sudo -H -u spark /bin/bash -c '\''/home/spark/hadoop/bin/hdfs --daemon stop datanode'\''
    sudo -H -u spark /bin/bash -c '\''/home/spark/spark/sbin/stop-slave.sh'\''
    ;;
  restart)
    sudo hostname host-$(hostname -I | awk '\''{$1=$1};1'\'' | sed '\''s/\./-/'\''g) ; hostname
    sudo -H -u spark /bin/bash -c '\''/home/spark/hadoop/bin/hdfs --daemon stop datanode'\''
    sudo -H -u spark /bin/bash -c '\''/home/spark/spark/sbin/stop-slave.sh'\''
    sudo -H -u spark /bin/bash -c '\''/home/spark/hadoop/bin/hdfs --daemon start datanode'\''
    sudo -H -u spark /bin/bash -c '\''/home/spark/spark/sbin/start-slave.sh spark://'$master':7077'\''
    ;;
  *)
    exit 1
esac
exit $?' | sudo tee /etc/init.d/sparkdaemon
fi

sudo systemctl daemon-reload
sudo chmod +x /etc/init.d/sparkdaemon
sudo chown root:root /etc/init.d/sparkdaemon
sudo update-rc.d sparkdaemon defaults
sudo update-rc.d sparkdaemon enable
sudo service sparkdaemon start

#sudo service sparkdaemon restart
#sudo systemctl status sparkdaemon.service

# reboot
sudo shutdown -r now