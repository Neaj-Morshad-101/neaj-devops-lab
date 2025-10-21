Deploy Milvus cluster:

The following command deploys a Milvus cluster with optimized settings for v2.6.2, using Woodpecker as the recommended message queue:

helm install my-release zilliztech/milvus \
  --namespace milvus \
  --set image.all.tag=v2.6.2 \
  --set pulsarv3.enabled=false \
  --set woodpecker.enabled=true \
  --set streaming.enabled=true \
  --set indexNode.enabled=false








What this command does:

Uses Woodpecker as the message queue (recommended for reduced maintenance)
Enables the new Streaming Node component for improved performance
Disables the legacy Index Node (functionality is now handled by Data Node)
Disables Pulsar to use Woodpecker instead


Architecture Changes in Milvus 2.6.x:

Message Queue: Woodpecker is now recommended (reduces infrastructure maintenance compared to Pulsar)
New Component: Streaming Node is introduced and enabled by default
Merged Components: Index Node and Data Node are combined into a single Data Node
For complete architecture details, refer to the Architecture Overview.




If you prefer to use Pulsar (traditional choice) instead of Woodpecker:
helm install my-release zilliztech/milvus \
  --set image.all.tag=v2.6.2 \
  --set streaming.enabled=true \
  --set indexNode.enabled=false








Every 2.0s: kubectl get all,cm,pvc,secrets -n milvus                                                                                                                                                       neaj-pc: Fri Oct 10 19:49:10 2025

NAME                                                 READY   STATUS    RESTARTS        AGE
pod/my-release-etcd-0                                1/1     Running   0               3m13s
pod/my-release-etcd-1                                1/1     Running   0               3m13s
pod/my-release-etcd-2                                1/1     Running   0               3m13s
pod/my-release-milvus-datanode-8494959574-8gpfg      1/1     Running   2 (2m50s ago)   3m13s
pod/my-release-milvus-mixcoord-56d789f9c6-x5jq7      1/1     Running   2 (2m50s ago)   3m13s
pod/my-release-milvus-proxy-549559878d-s9vxt         1/1     Running   2 (2m50s ago)   3m13s
pod/my-release-milvus-querynode-676d9468cf-6w6fj     1/1     Running   2 (2m50s ago)   3m13s
pod/my-release-milvus-streamingnode-bb757f5f-2qk4f   1/1     Running   2 (2m50s ago)   3m13s
pod/my-release-minio-0                               1/1     Running   0               3m13s
pod/my-release-minio-1                               1/1     Running   0               3m13s
pod/my-release-minio-2                               1/1     Running   0               3m13s
pod/my-release-minio-3                               1/1     Running   0               3m13s

NAME                                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)              AGE
service/my-release-etcd                   ClusterIP   10.96.59.117   <none>        2379/TCP,2380/TCP    3m13s
service/my-release-etcd-headless          ClusterIP   None           <none>        2379/TCP,2380/TCP    3m13s
service/my-release-milvus                 ClusterIP   10.96.77.104   <none>        19530/TCP,9091/TCP   3m13s
service/my-release-milvus-datanode        ClusterIP   None           <none>        9091/TCP             3m13s
service/my-release-milvus-mixcoord        ClusterIP   10.96.187.83   <none>        9091/TCP             3m13s
service/my-release-milvus-querynode       ClusterIP   None           <none>        9091/TCP             3m13s
service/my-release-milvus-streamingnode   ClusterIP   None           <none>        9091/TCP             3m13s
service/my-release-minio                  ClusterIP   10.96.125.40   <none>        9000/TCP             3m13s
service/my-release-minio-svc              ClusterIP   None           <none>        9000/TCP             3m13s

NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-release-milvus-datanode        1/1     1            1           3m13s
deployment.apps/my-release-milvus-mixcoord        1/1     1            1           3m13s
deployment.apps/my-release-milvus-proxy           1/1     1            1           3m13s
deployment.apps/my-release-milvus-querynode       1/1     1            1           3m13s
deployment.apps/my-release-milvus-streamingnode   1/1     1            1           3m13s

NAME                                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/my-release-milvus-datanode-8494959574      1         1         1       3m13s
replicaset.apps/my-release-milvus-mixcoord-56d789f9c6      1         1         1       3m13s
replicaset.apps/my-release-milvus-proxy-549559878d         1         1         1       3m13s
replicaset.apps/my-release-milvus-querynode-676d9468cf     1         1         1       3m13s
replicaset.apps/my-release-milvus-streamingnode-bb757f5f   1         1         1       3m13s

NAME                                READY   AGE
statefulset.apps/my-release-etcd    3/3     3m13s
statefulset.apps/my-release-minio   4/4     3m13s

NAME                          DATA   AGE
configmap/kube-root-ca.crt    1      12m
configmap/my-release-milvus   2      3m13s
configmap/my-release-minio    1      3m13s

NAME                                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/data-my-release-etcd-0      Bound    pvc-0270d053-6462-4e25-8524-367e42684dc4   10Gi       RWO            standard       <unset>                 3m13s
persistentvolumeclaim/data-my-release-etcd-1      Bound    pvc-ae48cd88-7b6e-4233-b75f-239d90ed2a9d   10Gi       RWO            standard       <unset>                 3m13s
persistentvolumeclaim/data-my-release-etcd-2      Bound    pvc-f0eb6046-9da1-405a-9f69-a56f084f201c   10Gi       RWO            standard       <unset>                 3m13s
persistentvolumeclaim/export-my-release-minio-0   Bound    pvc-d974c60b-f9b1-42c6-aa62-8e354e7792da   500Gi      RWO            standard       <unset>                 3m13s
persistentvolumeclaim/export-my-release-minio-1   Bound    pvc-b3f995b9-93a4-4bf1-9b34-acdcdedcf9bb   500Gi      RWO            standard       <unset>                 3m13s
persistentvolumeclaim/export-my-release-minio-2   Bound    pvc-66f5f1fd-6a51-489a-a7d0-d575b61bbbb7   500Gi      RWO            standard       <unset>                 3m13s
persistentvolumeclaim/export-my-release-minio-3   Bound    pvc-7cf4362f-c5a3-4e61-98aa-89fb302b35ad   500Gi      RWO            standard       <unset>                 3m13s

NAME                                      TYPE                 DATA   AGE
secret/my-release-minio                   Opaque               2      3m13s
secret/sh.helm.release.v1.my-release.v1   helm.sh/release.v1   1      3m13s








➤ kubectl port-forward service/my-release-milvus -n milvus 19530:19530
Forwarding from 127.0.0.1:19530 -> 19530
Forwarding from [::1]:19530 -> 19530
Handling connection for 19530








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
  - Book ID: 569, Distance: 0.1078, Title: 'Book Title 569', Year: 2023
  - Book ID: 281, Distance: 0.1568, Title: 'Book Title 281', Year: 2009
  - Book ID: 366, Distance: 0.1770, Title: 'Book Title 366', Year: 2009
  - Book ID: 249, Distance: 0.1965, Title: 'Book Title 249', Year: 1984
  - Book ID: 445, Distance: 0.2125, Title: 'Book Title 445', Year: 1986

Releasing collection from memory...
🔌 Disconnected from Milvus.
(venv) neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ 








# How to Enable the PVC for Woodpecker Using the Helm Chart? 

Enabling persistence for Woodpecker (and by extension, the Streaming Node) is a straightforward process. You simply need to set the correct values when you run helm install or helm upgrade.

Method 1: Using --set Flags (The Quick Way)

helm install my-release zilliztech/milvus \
  --namespace milvus \
  --set image.all.tag=v2.6.2 \
  --set pulsarv3.enabled=false \
  --set woodpecker.enabled=true \
  --set streaming.enabled=true \
  --set indexNode.enabled=false \
  --set streamingnode.persistence.enabled=true \
  --set streamingnode.persistence.volumeClaim.size=50Gi


The Last two lines (--set streamingnode.persistence) will configure the streaming node with PVC. 





Method 2: Using a values.yaml File (The Production Way)

The best practice is to create a custom values.yaml file that contains all your overrides.
1. Create a file named my-values.yaml:
```
# my-values.yaml

# Use the new Woodpecker architecture
pulsarv3:
  enabled: false
woodpecker:
  enabled: true
streaming:
  enabled: true
indexNode:
  enabled: false

# --- THIS IS THE KEY SECTION ---
# Enable persistence for the Streaming Node
streamingnode:
  persistence:
    enabled: true
    volumeClaim:
      size: 50Gi
      # You can optionally specify a StorageClass here if needed
      # storageClassName: "your-fast-ssd-storage-class"

# It's also best practice to manage other persistence here too
etcd:
  persistence:
    size: 20Gi

minio:
  persistence:
    size: 100Gi # Let's give MinIO more space
```

Install or upgrade using this file:
helm install my-release zilliztech/milvus -n milvus -f my-values.yaml
or
helm upgrade my-release zilliztech/milvus -n milvus -f my-values.yaml



Checked first two option: no PVC attached to streamming node. 


The Last Option:

Manually attach a PVC via volumes/volumeMounts. The Helm chart supports adding custom volumes globally. You can define a PVC and mount it at /var/lib/milvus by using the volumes and volumeMounts fields in your values. For example, add to your values.yaml:
```
volumes:
- name: woodpecker
  persistentVolumeClaim:
    claimName: <your-pvc-name>
volumeMounts:
- name: woodpecker
  mountPath: /var/lib/milvus
```
This will override the default emptyDir and use your PVC for the Woodpecker directory. (Make sure your PVC has at least 50Gi and uses ReadWriteOnce storage.) This approach effectively “inserts” your PV into the streaming node pod.
Chart version or custom chart. If you prefer a built-in solution, note that newer Helm chart versions may expose more persistence settings. You might consider upgrading to a later chart or filing a patch/issue. As of 5.0.4, the streaming node PVC isn’t auto-created by any dedicated flag, so custom volumes are the workaround.
In summary, the Milvus Helm chart defaults to ephemeral WAL storage for the streaming node. To get a persistent volume, you must explicitly configure it – either by ensuring the messageQueue.persistence setting takes effect or by manually mounting a PVC to /var/lib/milvus. This will guarantee the streaming node’s WAL survives pod restarts, as recommended for production deployments.
.