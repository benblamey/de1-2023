#!/bin/bash
# Ubuntu 22.04 - 2023.01.07
#####################################################################################

# A3 instructions based on this...


sudo apt update -y
sudo apt install -y \
  python3-pip \
  net-tools \
  curl \
  openjdk-11-jdk-headless \

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
echo "sudo hostname host-$(hostname -I | awk '{$1=$1};1' | sed 's/\./-/'g)" | sudo tee -a /home/ubuntu/.profile

echo JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64  | sudo tee -a /etc/environment
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# This must match the exact version on the server:
pip3 install pyspark==3.2.3 notebook

python3 -m notebook -ip=*