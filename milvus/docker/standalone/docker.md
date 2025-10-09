# Dcoker (Linux): https://milvus.io/docs/install_standalone-docker.md



### Install Milvus in Docker￼
####  Download the installation script
$ curl -sfL https://raw.githubusercontent.com/milvus-io/milvus/master/scripts/standalone_embed.sh -o standalone_embed.sh

# Start the Docker container
$ bash standalone_embed.sh start




After running the installation script:

A docker container named milvus has been started at port 19530.
An embed etcd is installed along with Milvus in the same container and serves at port 2379. Its configuration file is mapped to embedEtcd.yaml in the current folder.
To change the default Milvus configuration, add your settings to the user.yaml file in the current folder and then restart the service.
The Milvus data volume is mapped to volumes/milvus in the current folder.
You can access Milvus WebUI at http://127.0.0.1:9091/webui/ to learn more about the your Milvus instance. For details, refer to Milvus WebUI.





# Connect to Milvus

neaj@neaj-pc:~/g/s/g/N/y/milvus|main✓
➤ bash
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ source venv/bin/activate
(venv) neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ python milvus-python-client.py 
✅ Successfully connected to Milvus at localhost:19530
🧹 Dropped existing collection: book_recommendations
Creating collection: book_recommendations...
✅ Collection created successfully.

Preparing and inserting data...
✅ Inserted 1000 books into the collection.

Creating index for the vector field...
✅ Index created successfully.

Loading collection into memory for searching...
Performing a vector similarity search...

🔍 Top 5 most similar books found:
  - Book ID: 488, Distance: 0.2136, Title: 'Book Title 488', Year: 1994
  - Book ID: 92, Distance: 0.2227, Title: 'Book Title 92', Year: 2017
  - Book ID: 353, Distance: 0.2440, Title: 'Book Title 353', Year: 2021
  - Book ID: 918, Distance: 0.2606, Title: 'Book Title 918', Year: 2020
  - Book ID: 905, Distance: 0.2913, Title: 'Book Title 905', Year: 2002

Releasing collection from memory...
🔌 Disconnected from Milvus.
(venv) neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ 








 # Access Milvus from inside the container

➤ docker exec -it milvus-standalone bash
root@15e6e6c749d3:/milvus# ls /milvus/configs/
OWNERS  advanced  cert  embedEtcd.yaml  glog.conf  hook.yaml  milvus.yaml  pgo  user.yaml
root@15e6e6c749d3:/milvus# 

root@15e6e6c749d3:/milvus# cd /var/lib/milvus
root@15e6e6c749d3:/var/lib/milvus# ls
data  etcd  rdb_data  rdb_data_meta_kv
root@15e6e6c749d3:/var/lib/milvus# cd data
root@15e6e6c749d3:/var/lib/milvus/data# ls
cache  insert_log  stats_log
root@15e6e6c749d3:/var/lib/milvus/data# 







(Optional) Update Milvus configurations:
cat << EOF > user.yaml
# Extra config to override default milvus.yaml
proxy:
  healthCheckTimeout: 1000 # ms, the interval that to do component healthy check
EOF


Then restart the service as follows:
$ bash standalone_embed.sh restart




# Upgrade Milvus￼
## upgrade Milvus to the latest version
$ bash standalone_embed.sh upgrade



# Stop and delete Milvus￼
You can stop and delete this container as follows

# Stop Milvus
$ bash standalone_embed.sh stop

# Delete Milvus data
$ bash standalone_embed.sh delete












# Docker Compose (Linux): https://milvus.io/docs/install_standalone-docker-compose.md


## Install Milvus: 


Download the configuration file
$ wget https://github.com/milvus-io/milvus/releases/download/v2.6.0/milvus-standalone-docker-compose.yml -O docker-compose.yml

# Start Milvus
$ sudo docker compose up -d

[+] Running 33/33
 ✔ standalone Pulled                                                                                                           220.0s 
 ✔ etcd Pulled                                                                                                                 198.8s 
 ✔ minio Pulled                                                                                                                  9.2s

[+] Running 4/4
 ✔ Network milvus               Created                                                                                          0.0s 
 ✔ Container milvus-etcd        Started                                                                                          3.9s 
 ✔ Container milvus-minio       Started                                                                                          4.0s 
 ✔ Container milvus-standalone  Started  



```
➤ docker ps
CONTAINER ID   IMAGE                                      COMMAND                  CREATED         STATUS                        PORTS                                                                                          NAMES
53231dfea95a   milvusdb/milvus:v2.6.0                     "/tini -- milvus run…"   2 minutes ago   Up About a minute (healthy)   0.0.0.0:9091->9091/tcp, [::]:9091->9091/tcp, 0.0.0.0:19530->19530/tcp, [::]:19530->19530/tcp   milvus-standalone
de897a9b52e9   minio/minio:RELEASE.2024-12-18T13-15-44Z   "/usr/bin/docker-ent…"   2 minutes ago   Up About a minute (healthy)   0.0.0.0:9000-9001->9000-9001/tcp, [::]:9000-9001->9000-9001/tcp                                milvus-minio
19328b95a980   quay.io/coreos/etcd:v3.5.18                "etcd -advertise-cli…"   2 minutes ago   Up About a minute (healthy)   2379-2380/tcp                                                                                  milvus-etcd
```


```
➤ sudo docker compose ps
WARN[0000] /home/neaj/go/src/github.com/Neaj-Morshad-101/yamls/milvus/docker/standalone/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
NAME                IMAGE                                      COMMAND                  SERVICE      CREATED         STATUS                   PORTS
milvus-etcd         quay.io/coreos/etcd:v3.5.18                "etcd -advertise-cli…"   etcd         2 minutes ago   Up 2 minutes (healthy)   2379-2380/tcp
milvus-minio        minio/minio:RELEASE.2024-12-18T13-15-44Z   "/usr/bin/docker-ent…"   minio        2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:9000-9001->9000-9001/tcp, [::]:9000-9001->9000-9001/tcp
milvus-standalone   milvusdb/milvus:v2.6.2                     "/tini -- milvus run…"   standalone   2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:9091->9091/tcp, [::]:9091->9091/tcp, 0.0.0.0:19530->19530/tcp, [::]:19530->19530/tcp
warning: could not open directory 'milvus/docker/standalone/volumes/etcd/member/': Permission denied

```


After starting up Milvus,

Containers named milvus-standalone, milvus-minio, and milvus-etcd are up.
The milvus-etcd container does not expose any ports to the host and maps its data to volumes/etcd in the current folder.
The milvus-minio container serves ports 9090 and 9091 locally with the default authentication credentials and maps its data to volumes/minio in the current folder.
The milvus-standalone container serves ports 19530 locally with the default settings and maps its data to volumes/milvus in the current folder.







(Optional) Update Milvus configurations: 

To update Milvus configuration to suit your needs, you need to modify the /milvus/configs/user.yaml file within the milvus-standalone container.

- Access the milvus-standalone container.
➤ docker exec -it milvus-standalone bash
root@53231dfea95a:/milvus# 

- Add extra configurations to override the default ones. The following assumes that you need to override the default proxy.healthCheckTimeout.
cat << EOF > /milvus/configs/user.yaml
# Extra config to override default milvus.yaml
proxy:
  healthCheckTimeout: 1000 # ms, the interval that to do component healthy check
EOF

- Restart the milvus-standalone container to apply the changes.
docker restart milvus-standalone
￼









## Connect 
```
neaj@neaj-pc:~/g/s/g/N/y/m/d/standalone|main⚡✚?
➤ bash 
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus/docker/standalone$ cd ../
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus/docker$ ls
cluster  standalone
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus/docker$ cd ..
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ source venv/bin/activate
(venv) neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ python milvus-python-client.py 
✅ Successfully connected to Milvus at localhost:19530
Creating collection: book_recommendations...
✅ Collection created successfully.

Preparing and inserting data...
✅ Inserted 1000 books into the collection.

Creating index for the vector field...
✅ Index created successfully.

Loading collection into memory for searching...
Performing a vector similarity search...

🔍 Top 5 most similar books found:
  - Book ID: 818, Distance: 0.1155, Title: 'Book Title 818', Year: 1981
  - Book ID: 382, Distance: 0.2265, Title: 'Book Title 382', Year: 1996
  - Book ID: 638, Distance: 0.2347, Title: 'Book Title 638', Year: 1993
  - Book ID: 243, Distance: 0.3032, Title: 'Book Title 243', Year: 1995
  - Book ID: 82, Distance: 0.3302, Title: 'Book Title 82', Year: 2015

Releasing collection from memory...
🔌 Disconnected from Milvus.
(venv) neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ 

```











## Stop and delete Milvus￼
Stop Milvus
$ sudo docker compose down

# Delete service data
$ sudo rm -rf volumes