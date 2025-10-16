
Available WAL Backends: 
Before Milvus 2.6: Pulsar was the default WAL / message storage in cluster mode.
In Milvus 2.6 and later: Woodpecker becomes the preferred / default WAL backend.
The system retains backward compatibility, so you still can use Kafka or Pulsar, but the design is moving toward Woodpecker as the normative choice.

So, we will use Kafka or Woodpacker 






Offline install: 
Default:
helm template my-release zilliztech/milvus > milvus_manifest.yaml
￼


helm template my-release zilliztech/milvus \
  --namespace milvus-cluster \
  --create-namespace \
  --set image.all.tag=v2.6.2 \
  --set pulsarv3.enabled=false \
  --set woodpecker.enabled=true \
  --set streaming.enabled=true \
  --set indexNode.enabled=false \
  > milvus-cluster-manifest.yaml







kubectl apply -f 2.6.2/.




Every 2.0s: kubectl get all,cm,pvc,secrets -n milvus-cluster                                                                                                neaj-pc: Wed Oct 15 20:25:14 2025

NAME                                                   READY   STATUS    RESTARTS       AGE
pod/my-release-etcd-0                                  1/1     Running   0              8m21s
pod/my-release-etcd-1                                  1/1     Running   0              8m21s
pod/my-release-etcd-2                                  1/1     Running   0              8m21s
pod/my-release-milvus-datanode-b85b78d98-26dmb         1/1     Running   1 (8m9s ago)   8m20s
pod/my-release-milvus-mixcoord-c69bff948-q9b4f         1/1     Running   1 (8m9s ago)   8m20s
pod/my-release-milvus-proxy-64f4d5cf64-h4m4p           1/1     Running   1 (8m8s ago)   8m20s
pod/my-release-milvus-querynode-d85d8c967-jwl8v        1/1     Running   1 (8m8s ago)   8m20s
pod/my-release-milvus-streamingnode-579b86477f-sq9qf   1/1     Running   1 (8m8s ago)   8m20s
pod/my-release-minio-0                                 1/1     Running   0              8m20s
pod/my-release-minio-1                                 1/1     Running   0              8m20s
pod/my-release-minio-2                                 1/1     Running   0              8m20s
pod/my-release-minio-3                                 1/1     Running   0              8m20s

NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)              AGE
service/my-release-etcd                   ClusterIP   10.96.8.191     <none>        2379/TCP,2380/TCP    8m21s
service/my-release-etcd-headless          ClusterIP   None            <none>        2379/TCP,2380/TCP    8m21s
service/my-release-milvus                 ClusterIP   10.96.143.120   <none>        19530/TCP,9091/TCP   8m21s
service/my-release-milvus-datanode        ClusterIP   None            <none>        9091/TCP             8m21s
service/my-release-milvus-mixcoord        ClusterIP   10.96.207.232   <none>        9091/TCP             8m21s
service/my-release-milvus-querynode       ClusterIP   None            <none>        9091/TCP             8m21s
service/my-release-milvus-streamingnode   ClusterIP   None            <none>        9091/TCP             8m20s
service/my-release-minio                  ClusterIP   10.96.61.38     <none>        9000/TCP             8m20s
service/my-release-minio-svc              ClusterIP   None            <none>        9000/TCP             8m20s

NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-release-milvus-datanode        1/1     1            1           8m20s
deployment.apps/my-release-milvus-mixcoord        1/1     1            1           8m20s
deployment.apps/my-release-milvus-proxy           1/1     1            1           8m20s
deployment.apps/my-release-milvus-querynode       1/1     1            1           8m20s
deployment.apps/my-release-milvus-streamingnode   1/1     1            1           8m20s

NAME                                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/my-release-milvus-datanode-b85b78d98         1         1         1       8m20s
replicaset.apps/my-release-milvus-mixcoord-c69bff948         1         1         1       8m20s
replicaset.apps/my-release-milvus-proxy-64f4d5cf64           1         1         1       8m20s
replicaset.apps/my-release-milvus-querynode-d85d8c967        1         1         1       8m20s
replicaset.apps/my-release-milvus-streamingnode-579b86477f   1         1         1       8m20s

NAME                                READY   AGE
statefulset.apps/my-release-etcd    3/3     8m21s
statefulset.apps/my-release-minio   4/4     8m20s

NAME                          DATA   AGE
configmap/kube-root-ca.crt    1      29d
configmap/my-release-milvus   2      8m21s
configmap/my-release-minio    1      8m20s

NAME                                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/data-my-release-etcd-0      Bound    pvc-a359fc61-c0e8-43a3-9399-1cba49f4c5cf   10Gi       RWO            standard       <unset>                 8m21s
persistentvolumeclaim/data-my-release-etcd-1      Bound    pvc-f46914d9-a36a-4562-bc8c-ff9621bc2ef3   10Gi       RWO            standard       <unset>                 8m21s
persistentvolumeclaim/data-my-release-etcd-2      Bound    pvc-182c4c14-05c2-46f7-9026-eb850dd7a012   10Gi       RWO            standard       <unset>                 8m21s
persistentvolumeclaim/export-my-release-minio-0   Bound    pvc-cbc9af6b-b895-42b3-aa1b-6b2be833a48f   500Gi      RWO            standard       <unset>                 8m20s
persistentvolumeclaim/export-my-release-minio-1   Bound    pvc-91bddf2c-5eca-4d65-a68c-c80feb759831   500Gi      RWO            standard       <unset>                 8m20s
persistentvolumeclaim/export-my-release-minio-2   Bound    pvc-811150e6-955d-4070-a7e5-889808725d7b   500Gi      RWO            standard       <unset>                 8m20s
persistentvolumeclaim/export-my-release-minio-3   Bound    pvc-d2d25b03-7653-42fd-b0dc-65d32f82cf50   500Gi      RWO            standard       <unset>                 8m20s

NAME                      TYPE     DATA   AGE
secret/my-release-minio   Opaque   2      8m20s








➤ kubectl port-forward service/my-release-milvus -n milvus-cluster 19530:19530
Forwarding from 127.0.0.1:19530 -> 19530
Forwarding from [::1]:19530 -> 19530
Handling connection for 19530


(venv) neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/neaj-devops-lab/milvus$ python milvus-python-client.py 
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
  - Book ID: 602, Distance: 0.1668, Title: 'Book Title 602', Year: 2019
  - Book ID: 536, Distance: 0.2648, Title: 'Book Title 536', Year: 1987
  - Book ID: 401, Distance: 0.2951, Title: 'Book Title 401', Year: 1989
  - Book ID: 891, Distance: 0.3157, Title: 'Book Title 891', Year: 2016
  - Book ID: 893, Distance: 0.3779, Title: 'Book Title 893', Year: 2009

Releasing collection from memory...
🔌 Disconnected from Milvus.
(venv) neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/neaj-devops-lab/milvus$ 











# Part 1: Deep Dive into Milvus Components:

# The Three Layers of Milvus

## 1. Access Layer (The Front Desk): Handles client connections, validation, and forwarding.
Proxy (milvus-proxy):
- What it does: The public face of the cluster. It's the only component you connect to directly. It receives all SDK/API requests (like insert, search), performs basic validation (e.g., is the collection name valid?), and then forwards the request to the correct coordinator. After the coordinators do their work, the Proxy gathers the results and returns them to you.
- How it works: It's a stateless gateway. You can have multiple Proxy pods for high availability and load balancing.
- What data it stores: None. It holds no persistent data. It's a traffic cop.



# 2. Coordinator Service: The brain of the cluster. It manages metadata and orchestrates tasks among the worker nodes.
- Root Coordinator (rootcoord):
What it does: The Head for Data Definition Language (DDL) and Data Control Language (DCL). It handles requests like CreateCollection, DropCollection, CreatePartition, and managing user credentials. It also manages timestamps (TSOs) to ensure data consistency.
- How it works: It communicates with Etcd to store and retrieve metadata about collections, partitions, etc.
- What data it stores: None directly. It reads/writes all metadata to Etcd.


# Query Coordinator (querycoord):
- What it does: The "Search Librarian." It manages the state of all Query Nodes. When a search request comes in, it figures out which segments (data files) need to be searched and assigns the search tasks to the appropriate Query Nodes. It also handles loading and releasing segments from memory.
- How it works: It gets segment information from the Data Coordinator and assigns tasks to Query Nodes.
- What data it stores: None directly. It reads/writes all its state to Etcd.

# Data Coordinator (datacoord):
W- hat it does: The "Acquisitions and Cataloging Librarian." It manages the state of all Data Nodes. It handles incoming data from the message queue, assigns data to segments, triggers flushing of data from memory to object storage, and manages compaction tasks.
- How it works: It's the master of the data pipeline, writing metadata about segments and binlogs to Etcd.
- What data it stores: None directly. It reads/writes all its state to Etcd.


# Index Coordinator (indexcoord):
- What it does: The "Indexing Specialist." It manages the state of all Index Nodes. It receives requests to build indexes on sealed segments, assigns these tasks to Index Nodes, and tracks their progress.
- How it works: It assigns index-building tasks to worker nodes.
- What data it stores: None directly. It reads/writes all its state to Etcd.




# 3. Worker Nodes (The Library Staff): The "muscle" of the cluster. These nodes execute the tasks assigned by the coordinators.
# Query Node (querynode):
- What it does: The "Reader in the Reading Room." This is where the actual searching happens. It loads sealed segments from object storage (MinIO) into its memory and performs the high-speed vector similarity searches on them. It also subscribes to the message queue to get real-time data for "time travel" queries.
- How it works: It's a compute- and memory-intensive worker. You scale these up to handle more search traffic.
- What data it stores: In-memory cache of segments. This data is considered ephemeral. If a Query Node dies, the Query Coordinator will simply assign its segments to another Query Node to load.
Needs PVC? No.

# Data Node (datanode):
- What it does: The "Stocker who puts new books on the shelf." It subscribes to the DML (Data Manipulation Language) channels in the message queue, consumes new data as it's inserted, buffers it in memory, and periodically flushes this data into log files (binlogs) in MinIO.
- How it works: It's a data pipeline worker that moves data from the temporary message queue to permanent object storage.
- What data it stores: In-memory buffer of new data. This is temporary before being flushed.
- Needs PVC? No.

# Index Node (indexnode):
- What it does: The "Bookbinder who creates the index." It pulls a sealed segment from MinIO, builds a vector index file for it (e.g., HNSW, IVF_FLAT), and writes the new index file back to MinIO.
- How it works: A highly CPU-intensive worker that is only active when building indexes.
- What data it stores: Temporary data during index building.
Needs PVC? No.




# Part 2: The Critical Dependencies
This is where persistence is crucial. None of the Milvus components above store permanent data themselves. They rely on these three external services.

## Etcd:
- Role: Metadata Storage. The "Library's Card Catalog."
- What data it stores: All the "small but critical" information: collection schemas, segment IDs and their locations, index definitions, user roles, progress of tasks, etc. Without Etcd, Milvus is completely blind and doesn't know what data it has or where it is.
- Needs PVC? YES, ABSOLUTELY. If Etcd loses its data, your entire Milvus instance becomes unusable and you effectively lose your data structure (even though the raw files are still in MinIO).

## MinIO (or S3):
- Role: Object Storage. The "Library's Main Shelves/Warehouse."
- What data it stores: All the "large" data files:
Insert Logs (binlogs): Files containing the raw vector and scalar data you inserted.
Delete Logs (deltalogs): Files tracking which entities have been deleted.
Index Files: The large, pre-computed index structures that make searches fast.
Statistics Files: Information about the data distribution within segments.
- Needs PVC? YES, ABSOLUTELY. If MinIO loses its data, you lose all your vectors, scalars, and indexes. This is the core of your database.

Pulsar (or Kafka, or Woodpecker):
- Role: Message Queue / Log Broker. The "Library's conveyor belt and short-term holding area."
- How it works: When you insert data, the Proxy writes it as a message to a Pulsar topic. The Data Node then reads from this topic. This decouples the components and provides a reliable, ordered stream of operations. It also allows Query Nodes to see "live" data that hasn't been flushed to MinIO yet.
- What data it stores: A temporary buffer of recent insert/delete operations. Data is only kept here for a short, configurable period of time before being consumed and persisted to MinIO.
- Needs PVC? YES. Pulsar needs to persist its message logs to disk so that it can survive restarts without losing messages that haven't been consumed yet. While the data is "temporary" in the grand scheme, losing it would mean losing recent writes.



Summary of Persistence:
You need PVCs for Etcd, MinIO, and your chosen Message Queue (Pulsar/Kafka). The Milvus components themselves are all stateless.

Woodpecker and the Streaming Node it works with absolutely require a PersistentVolumeClaim (PVC).
