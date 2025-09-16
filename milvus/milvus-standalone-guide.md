### **Full Guide: Milvus Standalone with Raw Kubernetes Manifests**

#### **Step 1: Create the Manifest Files**

milvus-standalone-config.yaml 
milvus-standalone-dependencies.yaml 
milvus-standalone.yaml


#### **Step 2: Apply the Manifest**

Now that you have the complete "blueprint" in `milvus-standalone.yaml`, tell Kubernetes to build it:

```bash
➤ kubectl apply -f milvus-standalone-config.yaml 
configmap/milvus-config created
neaj@neaj-pc:~/g/s/g/N/y/milvus|main⚡*?
➤ kubectl apply -f milvus-standalone-dependencies.yaml 
service/milvus-etcd-headless created
service/milvus-etcd created
statefulset.apps/milvus-etcd created
service/milvus-minio created
persistentvolumeclaim/minio-pvc created
deployment.apps/milvus-minio created
neaj@neaj-pc:~/g/s/g/N/y/milvus|main⚡*?
➤ kubectl apply -f milvus-standalone.yaml 
service/milvus-standalone-service created
deployment.apps/milvus-standalone created
```

This will create all the defined resources in the `milvus-standalone` namespace.

#### **Step 3: Verify the Deployment**

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
Every 2.0s: kubectl get all,pvc,secrets,cm -n milvus-standalone                                                             neaj-pc: Tue Sep 16 12:04:42 2025

NAME                                     READY   STATUS    RESTARTS   AGE
pod/milvus-etcd-0                        1/1     Running   0          9m37s
pod/milvus-minio-8fcf5bbd5-qm8nv         1/1     Running   0          9m37s
pod/milvus-standalone-565fcb777d-4w5xn   1/1     Running   0          6m5s

NAME                                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE
service/milvus-etcd                 ClusterIP   10.96.130.66   <none>        2379/TCP            9m38s
service/milvus-etcd-headless        ClusterIP   None           <none>        2379/TCP            9m38s
service/milvus-minio                ClusterIP   10.96.6.203    <none>        9000/TCP,9001/TCP   9m37s
service/milvus-standalone-service   ClusterIP   10.96.184.41   <none>        19530/TCP           6m5s

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/milvus-minio        1/1     1            1           9m37s
deployment.apps/milvus-standalone   1/1     1            1           6m5s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/milvus-minio-8fcf5bbd5         1         1         1       9m37s
replicaset.apps/milvus-standalone-565fcb777d   1         1         1       6m5s

NAME                           READY   AGE
statefulset.apps/milvus-etcd   1/1     9m37s

NAME                                            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTES
CLASS   AGE
persistentvolumeclaim/etcd-data-milvus-etcd-0   Bound    pvc-a29027dc-5aa0-4ed4-9d22-42c253334400   10Gi       RWO            standard       <unset>
        9m37s
persistentvolumeclaim/minio-pvc                 Bound    pvc-7787ba74-5208-4aff-a83b-7bc10ebf2456   50Gi       RWO            standard       <unset>
        9m37s

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      27m
configmap/milvus-config      1      9m44s
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
    kubectl delete -f milvus-standalone-dependencies.yaml 
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





