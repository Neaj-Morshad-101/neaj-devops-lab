# Run Milvus in Kubernetes with Milvus Operator

```
➤ helm install milvus-operator \
        -n milvus-operator --create-namespace \
        --wait --wait-for-jobs \
        https://github.com/zilliztech/milvus-operator/releases/download/v1.3.0/milvus-operator-1.3.0.tgz

NAME: milvus-operator
LAST DEPLOYED: Fri Oct 10 13:10:44 2025
NAMESPACE: milvus-operator
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Milvus Operator Is Starting, use `kubectl get -n milvus-operator deploy/milvus-operator` to check if its successfully installed
Full Installation doc can be found in https://github.com/zilliztech/milvus-operator/blob/main/docs/installation/installation.md
Quick start with `kubectl apply -f https://raw.githubusercontent.com/zilliztech/milvus-operator/main/config/samples/milvus_minimum.yaml`
More samples can be found in https://github.com/zilliztech/milvus-operator/tree/main/config/samples
CRD Documentation can be found in https://github.com/zilliztech/milvus-operator/tree/main/docs/CRD
Administration Documentation can be found in https://github.com/zilliztech/milvus-operator/tree/main/docs/administration


neaj@neaj-pc:~
➤ kubectl get crds | grep milvus
milvusclusters.milvus.io                          2025-10-10T07:10:44Z
milvuses.milvus.io                                2025-10-10T07:10:44Z
milvusupgrades.milvus.io                          2025-10-10T07:10:44Z
```


```
Every 2.0s: kubectl get all,cm,pvc,secrets -n milvus-operator           neaj-pc: Fri Oct 10 14:39:32 2025

NAME                                  READY   STATUS    RESTARTS   AGE
pod/milvus-operator-df576bc68-8pwgl   1/1     Running   0          88m

NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/milvus-operator-metrics-service   ClusterIP   10.96.160.93    <none>        8443/TCP   88m
service/milvus-operator-webhook-service   ClusterIP   10.96.134.164   <none>        443/TCP    88m

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/milvus-operator   1/1     1            1           88m

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/milvus-operator-df576bc68   1         1         1       88m

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      88m

NAME                                           TYPE                 DATA   AGE
secret/sh.helm.release.v1.milvus-operator.v1   helm.sh/release.v1   1      88m











Every 2.0s: kubectl get all,cm,pvc,secrets -n milvus-operator                                                                                               neaj-pc: Fri Oct 10 15:21:52 2025

NAME                                                   READY   STATUS    RESTARTS      AGE
pod/my-release-etcd-0                                  1/1     Running   0             39m
pod/my-release-etcd-1                                  1/1     Running   0             39m
pod/my-release-etcd-2                                  1/1     Running   0             39m
pod/my-release-milvus-datanode-9d4c8988-j4vhq          1/1     Running   0             35m
pod/my-release-milvus-mixcoord-8b9cb9bbb-mwhbh         1/1     Running   0             35m
pod/my-release-milvus-proxy-8b98b5664-q7zw5            1/1     Running   0             35m
pod/my-release-milvus-querynode-0-6bf5c98467-xgn5s     1/1     Running   0             35m
pod/my-release-milvus-streamingnode-77458f8974-g2gw4   1/1     Running   0             35m
pod/my-release-minio-0                                 1/1     Running   0             39m
pod/my-release-minio-1                                 1/1     Running   0             39m
pod/my-release-minio-2                                 1/1     Running   0             39m
pod/my-release-minio-3                                 1/1     Running   0             39m

NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)              AGE
service/my-release-etcd                   ClusterIP   10.96.70.125    <none>        2379/TCP,2380/TCP    39m
service/my-release-etcd-headless          ClusterIP   None            <none>        2379/TCP,2380/TCP    39m
service/my-release-milvus                 ClusterIP   10.96.106.109   <none>        19530/TCP,9091/TCP   35m
service/my-release-minio                  ClusterIP   10.96.56.10     <none>        9000/TCP             39m
service/my-release-minio-svc              ClusterIP   None            <none>        9000/TCP             39m

NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-release-milvus-datanode        1/1     1            1           35m
deployment.apps/my-release-milvus-mixcoord        1/1     1            1           35m
deployment.apps/my-release-milvus-proxy           1/1     1            1           35m
deployment.apps/my-release-milvus-querynode-0     1/1     1            1           35m
deployment.apps/my-release-milvus-querynode-1     0/0     0            0           35m
deployment.apps/my-release-milvus-standalone      0/0     0            0           35m
deployment.apps/my-release-milvus-streamingnode   1/1     1            1           35m

NAME                                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/my-release-milvus-datanode-9d4c8988          1         1         1       35m
replicaset.apps/my-release-milvus-mixcoord-8b9cb9bbb         1         1         1       35m
replicaset.apps/my-release-milvus-proxy-8b98b5664            1         1         1       35m
replicaset.apps/my-release-milvus-querynode-0-6bf5c98467     1         1         1       35m
replicaset.apps/my-release-milvus-querynode-1-5dd84db6bc     0         0         0       35m
replicaset.apps/my-release-milvus-standalone-6fdb8dddff      0         0         0       35m
replicaset.apps/my-release-milvus-standalone-7d5b95f9bc      0         0         0       35m
replicaset.apps/my-release-milvus-streamingnode-77458f8974   1         1         1       35m

NAME                                READY   AGE
statefulset.apps/my-release-etcd    3/3     39m
statefulset.apps/my-release-minio   4/4     39m

NAME                         DATA   AGE
configmap/my-release         1      35m
configmap/my-release-minio   1      39m

NAME                                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/data-my-release-etcd-0      Bound    pvc-0d725484-2ca6-4687-a8d8-3df2b6eaca08   10Gi       RWO            standard       <unset>                 39m
persistentvolumeclaim/data-my-release-etcd-1      Bound    pvc-5eadf0f0-04fa-4713-ab26-e9308e2c14cf   10Gi       RWO            standard       <unset>                 39m
persistentvolumeclaim/data-my-release-etcd-2      Bound    pvc-e306b87b-1188-47dc-9945-18270571cdee   10Gi       RWO            standard       <unset>                 39m
persistentvolumeclaim/export-my-release-minio-0   Bound    pvc-1b83c5e6-c540-4326-b289-d89607f4168e   500Gi      RWO            standard       <unset>                 39m
persistentvolumeclaim/export-my-release-minio-1   Bound    pvc-83b7284e-a9bc-4d7c-8f9b-767d50c45ca0   500Gi      RWO            standard       <unset>                 39m
persistentvolumeclaim/export-my-release-minio-2   Bound    pvc-10256e8c-1025-435e-8ff2-8822ca77ef8d   500Gi      RWO            standard       <unset>                 39m
persistentvolumeclaim/export-my-release-minio-3   Bound    pvc-53110395-224a-427c-8618-9e39a6e65450   500Gi      RWO            standard       <unset>                 39m

NAME                                            TYPE                 DATA   AGE
secret/my-release-minio                         Opaque               2      39m
secret/sh.helm.release.v1.my-release-etcd.v1    helm.sh/release.v1   1      39m
secret/sh.helm.release.v1.my-release-minio.v1   helm.sh/release.v1   1      39m

```





```
➤ kubectl get milvus my-release -n milvus-operator -o yaml
apiVersion: milvus.io/v1beta1
kind: Milvus
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"milvus.io/v1beta1","kind":"Milvus","metadata":{"annotations":{},"labels":{"app":"milvus"},"name":"my-release","namespace":"milvus-operator"},"spec":{"components":{"image":"milvusdb/milvus:v2.6.2"},"config":{},"dependencies":{"msgStreamType":"woodpecker"},"mode":"cluster"}}
    milvus.io/dependency-values-merged: "true"
    milvus.io/pod-service-label-added: "true"
    milvus.io/querynode-current-group-id: "0"
  creationTimestamp: "2025-10-10T08:41:57Z"
  finalizers:
  - milvus.milvus.io/finalizer
  generation: 3
  labels:
    app: milvus
    milvus.io/operator-version: 1.3.0
  name: my-release
  namespace: milvus-operator
  resourceVersion: "3642658"
  uid: 58f2029c-93f5-4f90-85e1-c7a7a9a2ed38
spec:
  components:
    dataNode:
      paused: false
      probes: null
      replicas: 1
    disableMetric: false
    enableRollingUpdate: true
    image: milvusdb/milvus:v2.6.2
    imageUpdateMode: rollingUpgrade
    metricInterval: ""
    mixCoord:
      paused: false
      probes: null
      replicas: 1
    paused: false
    probes: null
    proxy:
      paused: false
      probes: null
      replicas: 1
      serviceType: ClusterIP
    queryNode:
      paused: false
      probes: null
      replicas: 1
    rollingMode: 2
    standalone:
      paused: false
      probes: null
      replicas: 0
      serviceType: ClusterIP
    streamingMode: true
    streamingNode:
      paused: false
      probes: null
      replicas: 1
    targetPortType: string
    updateConfigMapOnly: true
  config:
    dataCoord:
      enableActiveStandby: true
    indexCoord:
      enableActiveStandby: true
    queryCoord:
      enableActiveStandby: true
    rootCoord:
      enableActiveStandby: true
  dependencies:
    customMsgStream: null
    etcd:
      endpoints:
      - my-release-etcd-0.my-release-etcd-headless.milvus-operator:2379
      - my-release-etcd-1.my-release-etcd-headless.milvus-operator:2379
      - my-release-etcd-2.my-release-etcd-headless.milvus-operator:2379
      external: false
      inCluster:
        deletionPolicy: Retain
        values:
          auth:
            rbac:
              enabled: false
          autoCompactionMode: revision
          autoCompactionRetention: "1000"
          enabled: true
          extraEnvVars:
          - name: ETCD_QUOTA_BACKEND_BYTES
            value: "4294967296"
          - name: ETCD_HEARTBEAT_INTERVAL
            value: "500"
          - name: ETCD_ELECTION_TIMEOUT
            value: "2500"
          image:
            pullPolicy: IfNotPresent
            repository: milvusdb/etcd
            tag: 3.5.18-r1
          livenessProbe:
            enabled: true
            timeoutSeconds: 10
          name: etcd
          pdb:
            create: false
          persistence:
            accessMode: ReadWriteOnce
            enabled: true
            size: 10Gi
            storageClass: null
          readinessProbe:
            enabled: true
            periodSeconds: 20
            timeoutSeconds: 10
          replicaCount: 3
          service:
            peerPort: 2380
            port: 2379
            type: ClusterIP
    kafka:
      external: false
    msgStreamType: woodpecker
    natsmq:
      persistence:
        persistentVolumeClaim:
          spec: null
    pulsar:
      endpoint: ""
      external: false
    rocksmq:
      persistence:
        persistentVolumeClaim:
          spec: null
    storage:
      endpoint: my-release-minio.milvus-operator:9000
      external: false
      inCluster:
        deletionPolicy: Retain
        values:
          accessKey: minioadmin
          bucketName: milvus-bucket
          enabled: true
          existingSecret: ""
          iamEndpoint: ""
          image:
            pullPolicy: IfNotPresent
            tag: RELEASE.2024-12-18T13-15-44Z
          livenessProbe:
            enabled: true
            failureThreshold: 5
            initialDelaySeconds: 5
            periodSeconds: 5
            successThreshold: 1
            timeoutSeconds: 5
          mode: distributed
          name: minio
          persistence:
            accessMode: ReadWriteOnce
            enabled: true
            existingClaim: ""
            size: 500Gi
            storageClass: null
          podDisruptionBudget:
            enabled: false
          readinessProbe:
            enabled: true
            failureThreshold: 5
            initialDelaySeconds: 5
            periodSeconds: 5
            successThreshold: 1
            timeoutSeconds: 1
          region: ""
          resources:
            requests:
              memory: 2Gi
          rootPath: file
          secretKey: minioadmin
          service:
            port: 9000
            type: ClusterIP
          startupProbe:
            enabled: true
            failureThreshold: 60
            initialDelaySeconds: 0
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 5
          useIAM: false
          useVirtualHost: false
      secretRef: my-release-minio
      type: MinIO
    tei:
      enabled: false
    woodpecker:
      persistence:
        persistentVolumeClaim:
          spec: null
  hookConfig: null
  mode: cluster
status:
  componentsDeployStatus:
    datanode:
      generation: 1
      image: milvusdb/milvus:v2.6.2
      status:
        availableReplicas: 1
        conditions:
        - lastTransitionTime: "2025-10-10T08:47:48Z"
          lastUpdateTime: "2025-10-10T08:47:48Z"
          message: Deployment has minimum availability.
          reason: MinimumReplicasAvailable
          status: "True"
          type: Available
        - lastTransitionTime: "2025-10-10T08:45:57Z"
          lastUpdateTime: "2025-10-10T08:47:48Z"
          message: ReplicaSet "my-release-milvus-datanode-9d4c8988" has successfully
            progressed.
          reason: NewReplicaSetAvailable
          status: "True"
          type: Progressing
        observedGeneration: 1
        readyReplicas: 1
        replicas: 1
        updatedReplicas: 1
    mixcoord:
      generation: 1
      image: milvusdb/milvus:v2.6.2
      status:
        availableReplicas: 1
        conditions:
        - lastTransitionTime: "2025-10-10T08:47:48Z"
          lastUpdateTime: "2025-10-10T08:47:48Z"
          message: Deployment has minimum availability.
          reason: MinimumReplicasAvailable
          status: "True"
          type: Available
        - lastTransitionTime: "2025-10-10T08:45:57Z"
          lastUpdateTime: "2025-10-10T08:47:48Z"
          message: ReplicaSet "my-release-milvus-mixcoord-8b9cb9bbb" has successfully
            progressed.
          reason: NewReplicaSetAvailable
          status: "True"
          type: Progressing
        observedGeneration: 1
        readyReplicas: 1
        replicas: 1
        updatedReplicas: 1
    proxy:
      generation: 1
      image: milvusdb/milvus:v2.6.2
      status:
        availableReplicas: 1
        conditions:
        - lastTransitionTime: "2025-10-10T08:47:48Z"
          lastUpdateTime: "2025-10-10T08:47:48Z"
          message: Deployment has minimum availability.
          reason: MinimumReplicasAvailable
          status: "True"
          type: Available
        - lastTransitionTime: "2025-10-10T08:45:57Z"
          lastUpdateTime: "2025-10-10T08:47:48Z"
          message: ReplicaSet "my-release-milvus-proxy-8b98b5664" has successfully
            progressed.
          reason: NewReplicaSetAvailable
          status: "True"
          type: Progressing
        observedGeneration: 1
        readyReplicas: 1
        replicas: 1
        updatedReplicas: 1
    querynode:
      generation: 2
      image: milvusdb/milvus:v2.6.2
      status:
        availableReplicas: 1
        conditions:
        - lastTransitionTime: "2025-10-10T08:45:57Z"
          lastUpdateTime: "2025-10-10T08:45:57Z"
          message: ReplicaSet "my-release-milvus-querynode-0-6bf5c98467" has successfully
            progressed.
          reason: NewReplicaSetAvailable
          status: "True"
          type: Progressing
        - lastTransitionTime: "2025-10-10T08:48:04Z"
          lastUpdateTime: "2025-10-10T08:48:04Z"
          message: Deployment has minimum availability.
          reason: MinimumReplicasAvailable
          status: "True"
          type: Available
        observedGeneration: 2
        readyReplicas: 1
        replicas: 1
        updatedReplicas: 1
    standalone:
      generation: 2
      image: milvusdb/milvus:v2.6.2
      status:
        conditions:
        - lastTransitionTime: "2025-10-10T08:45:57Z"
          lastUpdateTime: "2025-10-10T08:45:57Z"
          message: Deployment has minimum availability.
          reason: MinimumReplicasAvailable
          status: "True"
          type: Available
        - lastTransitionTime: "2025-10-10T08:45:57Z"
          lastUpdateTime: "2025-10-10T08:45:57Z"
          message: ReplicaSet "my-release-milvus-standalone-6fdb8dddff" has successfully
            progressed.
          reason: NewReplicaSetAvailable
          status: "True"
          type: Progressing
        observedGeneration: 2
    streamingnode:
      generation: 1
      image: milvusdb/milvus:v2.6.2
      status:
        availableReplicas: 1
        conditions:
        - lastTransitionTime: "2025-10-10T08:47:48Z"
          lastUpdateTime: "2025-10-10T08:47:48Z"
          message: Deployment has minimum availability.
          reason: MinimumReplicasAvailable
          status: "True"
          type: Available
        - lastTransitionTime: "2025-10-10T08:45:57Z"
          lastUpdateTime: "2025-10-10T08:47:48Z"
          message: ReplicaSet "my-release-milvus-streamingnode-77458f8974" has successfully
            progressed.
          reason: NewReplicaSetAvailable
          status: "True"
          type: Progressing
        observedGeneration: 1
        readyReplicas: 1
        replicas: 1
        updatedReplicas: 1
  conditions:
  - lastTransitionTime: "2025-10-10T08:48:16Z"
    message: All Milvus components are healthy
    reason: ReasonMilvusHealthy
    status: "True"
    type: MilvusReady
  - lastTransitionTime: "2025-10-10T08:48:16Z"
    message: Milvus components are all updated
    reason: MilvusComponentsUpdated
    status: "True"
    type: MilvusUpdated
  - lastTransitionTime: "2025-10-10T08:42:49Z"
    message: Etcd endpoints is healthy
    reason: EtcdReady
    status: "True"
    type: EtcdReady
  - lastTransitionTime: "2025-10-10T08:45:57Z"
    reason: StorageReady
    status: "True"
    type: StorageReady
  - lastTransitionTime: "2025-10-10T08:42:49Z"
    reason: MsgStreamReady
    status: "True"
    type: MsgStreamReady
  currentImage: milvusdb/milvus:v2.6.2
  endpoint: my-release-milvus.milvus-operator:19530
  ingress:
    loadBalancer: {}
  observedGeneration: 3
  rollingModeVersion: 2
  status: Healthy

```






# Forward a local port to Milvus

```
➤ kubectl port-forward service/my-release-milvus 19530 -n milvus-operator 
Forwarding from 127.0.0.1:19530 -> 19530
Forwarding from [::1]:19530 -> 19530




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
  - Book ID: 140, Distance: 0.1505, Title: 'Book Title 140', Year: 2006
  - Book ID: 560, Distance: 0.2278, Title: 'Book Title 560', Year: 1993
  - Book ID: 812, Distance: 0.2355, Title: 'Book Title 812', Year: 2021
  - Book ID: 260, Distance: 0.3266, Title: 'Book Title 260', Year: 1980
  - Book ID: 980, Distance: 0.3340, Title: 'Book Title 980', Year: 1992

Releasing collection from memory...
🔌 Disconnected from Milvus.
(venv) neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/milvus$ 

```




# Access Milvus WebUI￼

```
➤ kubectl port-forward service/my-release-milvus -n milvus-operator 9091:9091
Forwarding from 127.0.0.1:9091 -> 9091
Forwarding from [::1]:9091 -> 9091
```


Now, you can access Milvus Web UI at http://localhost:9091.
`Getting, 404 page not found`




# Uninstall Milvus
`kubectl delete milvus my-release`


# Uninstall Milvus Operator
`helm -n milvus-operator uninstall milvus-operator`
