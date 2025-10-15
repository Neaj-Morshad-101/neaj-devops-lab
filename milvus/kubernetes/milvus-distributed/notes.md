
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
