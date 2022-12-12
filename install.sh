#!/bin/bash
# Ubuntu 20.04 LTS - Focal Fossa

# have blank to deploy a spark master / namenode.
#master=""
# fill in host to deploy a worker / datanode
# master="host-192-168-2-112"
master=""

cd /home/ubuntu

sudo apt update -y
# TODO: turn this back on...
#sudo apt upgrade -y

sudo apt install -y \
  net-tools \
  curl \
  openjdk-11-jre-headless \
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

echo HADOOP_HOME=/home/ubuntu/hadoop  | sudo tee -a /etc/environment


curl https://dlcdn.apache.org/spark/spark-3.2.3/spark-3.2.3-bin-hadoop3.2.tgz --output spark.tgz
tar --extract --file spark.tgz
mv spark-3.2.3-bin-hadoop3.2 spark

# Install the Web GUI auth filter...
git clone --depth=1 https://github.com/benblamey/de1-2023.git
sudo cp de1-2023/out/artifacts/de1_2023/de1-2023.jar spark/jars/
echo '
spark.ui.filters      com.benblamey.spark.BasicAuthFilter
'  | sudo tee spark/conf/spark-defaults.conf



# This is a legacy service script, since the linux distro is old...
# TODO start hadoop namenode/datanode
if [ "$master" = "" ];
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
    /home/ubuntu/spark/sbin/start-master.sh
    ;;
  stop)
    /home/ubuntu/spark/sbin/stop-master.sh
    ;;
  restart)
    sudo hostname host-$(hostname -I | awk '\''{$1=$1};1'\'' | sed '\''s/\./-/'\''g) ; hostname
    /home/ubuntu/spark/sbin/stop-master.sh
    /home/ubuntu/spark/sbin/start-master.sh
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
    /home/ubuntu/spark/sbin/start-slave.sh spark://'$master':7077
    ;;
  stop)
    /home/ubuntu/spark/sbin/stop-slave.sh
    ;;
  restart)
    sudo hostname host-$(hostname -I | awk '\''{$1=$1};1'\'' | sed '\''s/\./-/'\''g) ; hostname
    /home/ubuntu/spark/sbin/stop-slave.sh
    /home/ubuntu/spark/sbin/start-slave.sh spark://'$master':7077
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


sudo shutdown -r now