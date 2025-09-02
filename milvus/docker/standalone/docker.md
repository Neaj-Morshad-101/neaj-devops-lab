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





(Optional) Update Milvus configurations:
cat << EOF > user.yaml
# Extra config to override default milvus.yaml
proxy:
  healthCheckTimeout: 1000 # ms, the interval that to do component healthy check
EOF


Then restart the service as follows:
$ bash standalone_embed.sh restart




Stop and delete Milvus￼
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
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ source venv/bin/activate
(venv) neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ python python-client.py 
✅ Successfully connected to Milvus!
✅ Milvus server version: 2.6.0
🔌 Disconnected from Milvus.
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
  - Book ID: 621, Distance: 0.1594, Title: 'Book Title 621', Year: 2003
  - Book ID: 1, Distance: 0.2592, Title: 'Book Title 1', Year: 2009
  - Book ID: 121, Distance: 0.2956, Title: 'Book Title 121', Year: 1997
  - Book ID: 368, Distance: 0.3538, Title: 'Book Title 368', Year: 1997
  - Book ID: 398, Distance: 0.3572, Title: 'Book Title 398', Year: 2015

Releasing collection from memory...
🔌 Disconnected from Milvus.
(venv) neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ 












## Stop and delete Milvus￼
Stop Milvus
$ sudo docker compose down

# Delete service data
$ sudo rm -rf volumes