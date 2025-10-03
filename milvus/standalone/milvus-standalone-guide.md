### **Full Guide: Milvus Standalone with Raw Kubernetes Manifests**

#### **Step 1: Create and Apply the Manifest Files**

```bash
➤ kubectl apply -f milvus-standalone-config.yaml 
configmap/milvus-config created

➤ kubectl apply -f milvus-standalone-etcd.yaml
service/milvus-etcd-headless created
service/milvus-etcd created
statefulset.apps/milvus-etcd created

➤ kubectl apply -f milvus-standalone-minio.yaml 
service/milvus-minio created
persistentvolumeclaim/minio-pvc created
deployment.apps/milvus-minio created

➤ kubectl apply -f milvus-standalone.yaml
service/milvus-standalone-service created
deployment.apps/milvus-standalone created
```


This will create all the defined resources in the `milvus-standalone` namespace.

#### **Step 2: Verify the Deployment**

Check that all the pods are up and running. It might take a minute or two for the images to pull and the containers to start.

```bash
➤ kubectl get pods -n milvus-standalone
NAME                                 READY   STATUS    RESTARTS   AGE
milvus-etcd-0                        1/1     Running   0          9m11s
milvus-minio-8fcf5bbd5-qm8nv         1/1     Running   0          9m11s
milvus-standalone-565fcb777d-4w5xn   1/1     Running   0          5m39s
```

You should see an output similar to this, with all pods eventually reaching `Running` status:


```
Every 2.0s: kubectl get all,pvc,secrets,cm -n milvus-standalone                                                          

NAME                                     READY   STATUS    RESTARTS   AGE
pod/milvus-etcd-0                        1/1     Running   0          4h35m
pod/milvus-minio-8fcf5bbd5-vcrc6         1/1     Running   0          4m19s
pod/milvus-standalone-565fcb777d-qxhf8   1/1     Running   0          3m27s

NAME                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/milvus-etcd                 ClusterIP   10.96.102.248   <none>        2379/TCP            4h35m
service/milvus-etcd-headless        ClusterIP   None            <none>        2379/TCP            4h35m
service/milvus-minio                ClusterIP   10.96.152.220   <none>        9000/TCP,9001/TCP   4m19s
service/milvus-standalone-service   ClusterIP   10.96.249.245   <none>        19530/TCP           3m27s

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/milvus-minio        1/1     1            1           4m19s
deployment.apps/milvus-standalone   1/1     1            1           3m27s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/milvus-minio-8fcf5bbd5         1         1         1       4m19s
replicaset.apps/milvus-standalone-565fcb777d   1         1         1       3m27s

NAME                           READY   AGE
statefulset.apps/milvus-etcd   1/1     4h35m

NAME                                            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTES
CLASS   AGE
persistentvolumeclaim/etcd-data-milvus-etcd-0   Bound    pvc-a29027dc-5aa0-4ed4-9d22-42c253334400   10Gi       RWO            standard       <unset>
        17d
persistentvolumeclaim/minio-pvc                 Bound    pvc-c80cdf9a-da54-4e98-9b83-93ba9e6c4389   50Gi       RWO            standard       <unset>
        4m19s

NAME                         DATA   AGE
configmap/milvus-config      1      4h35m

```





#### **Step 4: Connect and Test**

Just like with the Helm deployment, the service is only accessible inside the cluster. Use `port-forward` to connect from your local machine.

**Note the new service name and namespace in the command:**

```bash
➤ kubectl port-forward service/milvus-standalone-service 19530:19530 -n milvus-standalone
Forwarding from 127.0.0.1:19530 -> 19530
Forwarding from [::1]:19530 -> 19530
Handling connection for 19530
```

Now, in another terminal, you can run your same Python client script. It will connect to `localhost:19530` and work exactly as it did with the Helm-based deployment.

```
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
  - Book ID: 555, Distance: 0.1327, Title: 'Book Title 555', Year: 2024
  - Book ID: 801, Distance: 0.1607, Title: 'Book Title 801', Year: 1992
  - Book ID: 834, Distance: 0.2082, Title: 'Book Title 834', Year: 2017
  - Book ID: 657, Distance: 0.2204, Title: 'Book Title 657', Year: 2017
  - Book ID: 136, Distance: 0.2215, Title: 'Book Title 136', Year: 1991

Releasing collection from memory...
🔌 Disconnected from Milvus.
(venv) neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ 
```


---

### **Step 5: Cleaning Up**

To delete everything you've created:

1.  **Delete all resources from the manifest file:**
    ```bash
    kubectl delete -f milvus-standalone-etcd.yaml 
    kubectl delete -f milvus-standalone-minio.yaml 
    kubectl delete -f milvus-standalone.yaml
    kubectl delete -f milvus-standalone-config.yaml
    ```
    This will delete the Deployments, StatefulSets, Services, and ConfigMaps.

2.  **Manually delete the Persistent Volume Claims (PVCs):** Kubernetes keeps these by default to prevent accidental data loss.
    ```bash
    # See the PVCs in the namespace
    kubectl get pvc -n milvus-standalone

    # Delete them by name
    kubectl delete pvc etcd-data-milvus-etcd-0 minio-pvc -n milvus-standalone
    ```





