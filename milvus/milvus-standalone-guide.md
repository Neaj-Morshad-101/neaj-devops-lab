### **Full Guide: Milvus Standalone with Raw Kubernetes Manifests**

#### **Step 1: Create the All-in-One Manifest File**

Create a new file named `milvus-standalone.yaml` and paste the entire block of code below into it. I've added extensive comments to explain what each section does.

```yaml
# milvus-standalone.yaml

# This is a best practice for real-world scenarios.
# It creates an isolated space for all our Milvus components.
apiVersion: v1
kind: Namespace
metadata:
  name: milvus-standalone
---
# 1. CONFIGURATION FOR MILVUS
# A ConfigMap holds the milvus.yaml configuration file.
# Milvus will read this to know where to find etcd and minio.
apiVersion: v1
kind: ConfigMap
metadata:
  name: milvus-config
  namespace: milvus-standalone
data:
  milvus.yaml: |
    # Add this new section for common configurations
    common:
      localStorage:
        path: /var/lib/milvus

    etcd:
      endpoints:
        - milvus-etcd:2379  # The name of the etcd service we will create
    minio:
      address: milvus-minio # The name of the minio service we will create
      port: 9000
      accessKeyID: minioadmin
      secretAccessKey: minioadmin
      useSSL: false
---
# 2. DEPENDENCY: ETCD (METADATA STORAGE)
# We use a StatefulSet because etcd needs stable network identity and storage.
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: milvus-etcd
  namespace: milvus-standalone
spec:
  serviceName: milvus-etcd-headless
  replicas: 1
  selector:
    matchLabels:
      app: milvus
      component: etcd
  template:
    metadata:
      labels:
        app: milvus
        component: etcd
    spec:
      containers:
      - name: etcd
        image: quay.io/coreos/etcd:v3.5.5
        command:
        - /usr/local/bin/etcd
        - --name=etcd-0
        - --listen-client-urls=http://0.0.0.0:2379
        - --advertise-client-urls=http://milvus-etcd-0.milvus-etcd-headless:2379
        - --data-dir=/etcd-data
        ports:
        - containerPort: 2379
        volumeMounts:
        - name: etcd-data
          mountPath: /etcd-data
  volumeClaimTemplates:
  - metadata:
      name: etcd-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
---
# Service to give etcd a stable network address.
apiVersion: v1
kind: Service
metadata:
  name: milvus-etcd
  namespace: milvus-standalone
spec:
  selector:
    app: milvus
    component: etcd
  ports:
  - port: 2379
    targetPort: 2379
---
# 3. DEPENDENCY: MINIO (OBJECT STORAGE)
# We use a Deployment as we only need one simple instance for standalone mode.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: milvus-minio
  namespace: milvus-standalone
spec:
  replicas: 1
  selector:
    matchLabels:
      app: milvus
      component: minio
  template:
    metadata:
      labels:
        app: milvus
        component: minio
    spec:
      containers:
      - name: minio
        image: minio/minio:RELEASE.2023-03-20T20-16-18Z
        command:
        - /bin/bash
        - -c
        - minio server /data --console-address :9001
        env:
        - name: MINIO_ROOT_USER
          value: "minioadmin"
        - name: MINIO_ROOT_PASSWORD
          value: "minioadmin"
        ports:
        - containerPort: 9000 # API port
        - containerPort: 9001 # Console port
        volumeMounts:
        - name: minio-data
          mountPath: /data
      volumes:
      - name: minio-data
        persistentVolumeClaim:
          claimName: minio-pvc
---
# Request storage (a PVC) for MinIO's data.
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pvc
  namespace: milvus-standalone
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
---
# Service to give MinIO a stable network address.
apiVersion: v1
kind: Service
metadata:
  name: milvus-minio
  namespace: milvus-standalone
spec:
  selector:
    app: milvus
    component: minio
  ports:
  - name: api
    port: 9000
    targetPort: 9000
  - name: console
    port: 9001
    targetPort: 9001
---
# 4. THE MILVUS STANDALONE DEPLOYMENT
# This is the main application. It's stateless because its state is in etcd and minio.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: milvus-standalone
  namespace: milvus-standalone
spec:
  replicas: 1
  selector:
    matchLabels:
      app: milvus
      component: standalone
  template:
    metadata:
      labels:
        app: milvus
        component: standalone
    spec:
      containers:
      - name: milvus
        image: milvusdb/milvus:v2.6.1
        command: ["/tini", "--", "/milvus/bin/milvus", "run", "standalone"]
        env:
        - name: ETCD_ENDPOINTS
          value: milvus-etcd:2379
        - name: MINIO_ADDRESS
          value: milvus-minio:9000
        ports:
        - containerPort: 19530 # gRPC port
        - containerPort: 9091  # Metrics port
        volumeMounts:
        - name: milvus-config-volume
          mountPath: /milvus/configs/milvus.yaml
          subPath: milvus.yaml
      volumes:
      - name: milvus-config-volume
        configMap:
          name: milvus-config
---
# 5. THE MILVUS SERVICE
# This exposes the Milvus gRPC port so we can connect to it.
apiVersion: v1
kind: Service
metadata:
  name: milvus-standalone-service
  namespace: milvus-standalone
spec:
  selector:
    app: milvus
    component: standalone
  ports:
  - name: grpc
    port: 19530
    targetPort: 19530
```

#### **Step 2: Apply the Manifest**

Now that you have the complete "blueprint" in `milvus-standalone.yaml`, tell Kubernetes to build it:

```bash
kubectl apply -f milvus-standalone.yaml
```

This will create all the defined resources in the `milvus-standalone` namespace.

#### **Step 3: Verify the Deployment**

Check that all the pods are up and running. It might take a minute or two for the images to pull and the containers to start.

```bash
kubectl get pods -n milvus-standalone
```

You should see an output similar to this, with all pods eventually reaching `Running` status:

```
NAME                                 READY   STATUS    RESTARTS   AGE
milvus-etcd-0                        1/1     Running   0          90s
milvus-minio-xxxx-xxxx               1/1     Running   0          90s
milvus-standalone-xxxx-xxxx          1/1     Running   0          90s
```

```
Every 2.0s: kubectl get all,pvc,secrets,cm -n milvus-standalone      

NAME                                     READY   STATUS             RESTARTS          AGE
pod/milvus-etcd-0                        1/1     Running            1 (8h ago)        27h
pod/milvus-minio-8fcf5bbd5-8hblp         1/1     Running            1 (8h ago)        27h
pod/milvus-standalone-6986b8b78b-h66x7   0/1     CrashLoopBackOff   156 (2m10s ago)   27h

NAME                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/milvus-etcd                 ClusterIP   10.96.111.222   <none>        2379/TCP            27h
service/milvus-minio                ClusterIP   10.96.48.83     <none>        9000/TCP,9001/TCP   27h
service/milvus-standalone-service   ClusterIP   10.96.159.137   <none>        19530/TCP           27h

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/milvus-minio        1/1     1            1           27h
deployment.apps/milvus-standalone   0/1     1            0           27h

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/milvus-minio-8fcf5bbd5         1         1         1       27h
replicaset.apps/milvus-standalone-6986b8b78b   1         1         0       27h
replicaset.apps/milvus-standalone-845fc46f6f   0         0         0       27h

NAME                           READY   AGE
statefulset.apps/milvus-etcd   1/1     27h

NAME                                            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECL
ASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/etcd-data-milvus-etcd-0   Bound    pvc-bab99921-cde4-4e11-a9f5-091b1ba67040   10Gi       RWO            standard
      <unset>                 27h
persistentvolumeclaim/minio-pvc                 Bound    pvc-49a5b844-8380-4940-9e74-47e5a052d282   50Gi       RWO            standard
      <unset>                 27h

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      27h
configmap/milvus-config      1      27h
```





#### **Step 4: Connect and Test**

Just like with the Helm deployment, the service is only accessible inside the cluster. Use `port-forward` to connect from your local machine.

**Note the new service name and namespace in the command:**

```bash
kubectl port-forward service/milvus-standalone-service 19530:19530 -n milvus-standalone
```

Now, in another terminal, you can run your same Python client script. It will connect to `localhost:19530` and work exactly as it did with the Helm-based deployment.

---

### **Step 5: Cleaning Up**

To delete everything you've created:

1.  **Delete all resources from the manifest file:**
    ```bash
    kubectl delete -f milvus-standalone.yaml
    ```
    This will delete the Namespace, Deployments, StatefulSets, Services, and ConfigMaps.

2.  **Manually delete the Persistent Volume Claims (PVCs):** Kubernetes keeps these by default to prevent accidental data loss.
    ```bash
    # See the PVCs in the namespace
    kubectl get pvc -n milvus-standalone

    # Delete them by name
    kubectl delete pvc etcd-data-milvus-etcd-0 minio-pvc -n milvus-standalone
    ```





