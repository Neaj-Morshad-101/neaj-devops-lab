kubectl create namespace milvus


helm repo add zilliztech https://zilliztech.github.io/milvus-helm/
helm repo update



Deploy a Milvus Standalone: 
```
helm install my-release zilliztech/milvus \
  --namespace milvus \
  --set image.all.tag=v2.6.2 \
  --set cluster.enabled=false \
  --set pulsarv3.enabled=false \
  --set standalone.messageQueue=woodpecker \
  --set woodpecker.enabled=true \
  --set streaming.enabled=true

```

Note: Standalone mode uses Woodpecker as the default message queue and enables the Streaming Node component. For details, refer to the Architecture Overview and Use Woodpecker.





Every 2.0s: kubectl get all,cm,pvc,secrets -n milvus                                                                                                        neaj-pc: Fri Oct 10 19:42:18 2025

NAME                                                READY   STATUS    RESTARTS        AGE
pod/my-release-etcd-0                               1/1     Running   0               3m59s
pod/my-release-etcd-1                               1/1     Running   0               3m59s
pod/my-release-etcd-2                               1/1     Running   0               3m59s
pod/my-release-milvus-standalone-77597f789c-7j2h7   1/1     Running   1 (3m41s ago)   3m59s
pod/my-release-minio-0                              1/1     Running   0               3m59s
pod/my-release-minio-1                              1/1     Running   0               3m59s
pod/my-release-minio-2                              1/1     Running   0               3m59s
pod/my-release-minio-3                              1/1     Running   0               3m59s

NAME                               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)              AGE
service/my-release-etcd            ClusterIP   10.96.49.53     <none>        2379/TCP,2380/TCP    4m
service/my-release-etcd-headless   ClusterIP   None            <none>        2379/TCP,2380/TCP    4m
service/my-release-milvus          ClusterIP   10.96.191.47    <none>        19530/TCP,9091/TCP   4m
service/my-release-minio           ClusterIP   10.96.254.109   <none>        9000/TCP             4m
service/my-release-minio-svc       ClusterIP   None            <none>        9000/TCP             4m

NAME                                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-release-milvus-standalone   1/1     1            1           3m59s

NAME                                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/my-release-milvus-standalone-77597f789c   1         1         1       3m59s

NAME                                READY   AGE
statefulset.apps/my-release-etcd    3/3     3m59s
statefulset.apps/my-release-minio   4/4     3m59s

NAME                          DATA   AGE
configmap/my-release-milvus   2      4m
configmap/my-release-minio    1      4m

NAME                                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/data-my-release-etcd-0      Bound    pvc-6698808f-479d-402d-9810-6310de5ee4d6   10Gi       RWO            standard       <unset>                 3m59s
persistentvolumeclaim/data-my-release-etcd-1      Bound    pvc-9fda0091-49cc-4769-a77c-ebd45ba1f973   10Gi       RWO            standard       <unset>                 3m59s
persistentvolumeclaim/data-my-release-etcd-2      Bound    pvc-5ad61cef-7662-4836-a74f-c44015b9810a   10Gi       RWO            standard       <unset>                 3m59s
persistentvolumeclaim/export-my-release-minio-0   Bound    pvc-acd614d5-d189-4872-983f-bb2e95ff678b   500Gi      RWO            standard       <unset>                 3m59s
persistentvolumeclaim/export-my-release-minio-1   Bound    pvc-6f5a9d46-b629-42ec-a8ff-ebe8199df3d1   500Gi      RWO            standard       <unset>                 3m59s
persistentvolumeclaim/export-my-release-minio-2   Bound    pvc-d3bbd5de-1405-40a7-82d2-89d5ab0dc427   500Gi      RWO            standard       <unset>                 3m59s
persistentvolumeclaim/export-my-release-minio-3   Bound    pvc-bb2f49ab-bf55-448a-883e-a92680c84747   500Gi      RWO            standard       <unset>                 3m59s
persistentvolumeclaim/my-release-milvus           Bound    pvc-f13c6bdf-b65b-4855-b88d-7b511ed768ad   50Gi       RWO            standard       <unset>                 4m

NAME                                      TYPE                 DATA   AGE
secret/my-release-minio                   Opaque               2      4m
secret/sh.helm.release.v1.my-release.v1   helm.sh/release.v1   1      4m







➤ kubectl port-forward service/my-release-milvus -n milvus 19530:19530
Forwarding from 127.0.0.1:19530 -> 19530
Forwarding from [::1]:19530 -> 19530
Handling connection for 19530




neaj@neaj-pc:~/g/s/g/N/y/milvus|main⚡*?
➤ bash
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
  - Book ID: 114, Distance: 0.1242, Title: 'Book Title 114', Year: 1993
  - Book ID: 962, Distance: 0.1571, Title: 'Book Title 962', Year: 1998
  - Book ID: 403, Distance: 0.1643, Title: 'Book Title 403', Year: 1987
  - Book ID: 949, Distance: 0.1750, Title: 'Book Title 949', Year: 1995
  - Book ID: 440, Distance: 0.1798, Title: 'Book Title 440', Year: 1999

Releasing collection from memory...
🔌 Disconnected from Milvus.
(venv) neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ 






