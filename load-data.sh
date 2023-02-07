# https://www.kaggle.com/datasets/cityofLA/los-angeles-parking-citations
scp ./parking-citations.csv.gz 130.238.28.98:/home/ubuntu

sudo hostname host-$(hostname -I | awk '{$1=$1};1' | sed 's/\./-/'g) ; hostname

gunzip parking-citations.csv.gz
sudo mv /home/ubuntu/parking-citations.csv /home/spark
sudo chown spark /home/spark/parking-citations.csv

# Now switch to HDFS user...
sudo -H -u spark /bin/bash
cd /home/spark

hadoop/bin/hdfs dfs -put parking-citations.csv /

wget https://www.statmt.org/europarl/v7/bg-en.tgz
wget https://www.statmt.org/europarl/v7/cs-en.tgz
wget https://www.statmt.org/europarl/v7/da-en.tgz
wget https://www.statmt.org/europarl/v7/de-en.tgz
wget https://www.statmt.org/europarl/v7/el-en.tgz
wget https://www.statmt.org/europarl/v7/es-en.tgz
wget https://www.statmt.org/europarl/v7/et-en.tgz
wget https://www.statmt.org/europarl/v7/fi-en.tgz
wget https://www.statmt.org/europarl/v7/fr-en.tgz
wget https://www.statmt.org/europarl/v7/hu-en.tgz
wget https://www.statmt.org/europarl/v7/it-en.tgz
wget https://www.statmt.org/europarl/v7/lt-en.tgz
wget https://www.statmt.org/europarl/v7/lv-en.tgz
wget https://www.statmt.org/europarl/v7/nl-en.tgz
wget https://www.statmt.org/europarl/v7/pl-en.tgz
wget https://www.statmt.org/europarl/v7/pt-en.tgz
wget https://www.statmt.org/europarl/v7/ro-en.tgz
wget https://www.statmt.org/europarl/v7/sk-en.tgz
wget https://www.statmt.org/europarl/v7/sl-en.tgz
wget https://www.statmt.org/europarl/v7/sv-en.tgz

find . -name "*.tgz" -exec tar -xvf {} \;
mkdir europarl
mv europarl-v7.* europarl
hadoop/bin/hdfs dfs -put europarl /

rm parking-citations.csv
rm -rf europarl