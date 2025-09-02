# Standalone

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