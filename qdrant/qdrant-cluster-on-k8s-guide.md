### [Documentation](https://qdrant.tech/documentation/guides/distributed_deployment/)


### Goal

Our goal is to deploy a **3-node Qdrant cluster** on Kubernetes using raw YAML manifests. This setup will be resilient and scalable, including:
1.  A **ConfigMap** to hold the shared cluster configuration for all Qdrant nodes.
2.  A **StatefulSet** to manage 3 Qdrant pods, each with its own stable identity and persistent storage.
3.  A **Headless Service** for internal pod-to-pod communication and discovery.
4.  A **ClusterIP Service** to provide a single, load-balanced endpoint for clients.

---

### Key Differences from Standalone Mode

Setting up a cluster requires a few extra pieces compared to the standalone setup:

*   **Configuration via ConfigMap:** All nodes must know they are part of a cluster. We'll use a Kubernetes `ConfigMap` to store a configuration file that enables cluster mode.
*   **Peer Discovery:** Nodes need a way to find each other. The headless service provides stable, unique DNS names for each pod (e.g., `qdrant-cluster-0.qdrant-cluster-pods.default.svc.cluster.local`), which Qdrant uses to form the cluster.
*   **P2P Port:** An additional port (`6335` by default) is needed for nodes to synchronize with each other (the "gossip" protocol).
*   **Replicas:** We'll set `replicas: 3` in our `StatefulSet`.

---

### Step 1: Create the Qdrant Cluster Configuration

First, we need to create the configuration file that will tell Qdrant how to operate in a cluster. We will store this in a Kubernetes `ConfigMap` so we can easily mount it into our pods.

Create a file named `qdrant-config.yaml` and paste the following content:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: qdrant-cluster-config
data:
  # This key 'config.yaml' will become a file inside the pod.
  config.yaml: |
    # Log level can be info, debug, trace, etc.
    log_level: INFO

    # Standard service ports
    service:
      http_port: 6333
      grpc_port: 6334

    # Cluster configuration section
    cluster:
      # This enables the cluster mode
      enabled: true
      # Peer-to-peer (P2P) port for internode communication
      p2p:
        port: 6335
      # Configuration related to distributed consensus algorithm
      consensus:
        # How frequently peers should ping each other.
        # Setting this parameter to lower value will allow consensus
        # to detect disconnected nodes earlier, but too frequent
        # tick period may create significant network and CPU overhead.
        # We encourage you NOT to change this parameter unless you know what you are doing.
        tick_period_ms: 100
```




### Step 2: Create the Cluster Manifest (Services & StatefulSet)

Now, let's create the main manifest that defines our services and the 3-replica `StatefulSet`. This is an extension of the standalone manifest.

Create a file named `qdrant-cluster.yaml` and paste the following:

```yaml
# ------------------- Headless Service ------------------- #
# Purpose: Provides stable DNS names for each pod (e.g., qdrant-cluster-0.qdrant-cluster-pods)
# for internal peer discovery.
apiVersion: v1
kind: Service
metadata:
  name: qdrant-cluster-pods
spec:
  clusterIP: None
  selector:
    app: qdrant-cluster
  ports:
    - name: http
      port: 6333
    - name: grpc
      port: 6334
    - name: p2p
      port: 6335

---
# ------------------- ClusterIP Service ------------------- #
# Purpose: Provides a single, load-balanced endpoint for clients to connect to.
apiVersion: v1
kind: Service
metadata:
  name: qdrant-cluster
spec:
  type: ClusterIP
  selector:
    app: qdrant-cluster
  ports:
    - name: http
      port: 6333
      targetPort: 6333
    - name: grpc
      port: 6334
      targetPort: 6334

---
# ------------------- StatefulSet ------------------- #
# Purpose: Manages the 3 Qdrant pods and their persistent storage.

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: qdrant-cluster
spec:
  serviceName: "qdrant-cluster-pods"
  replicas: 3
  selector:
    matchLabels:
      app: qdrant-cluster
  template:
    metadata:
      labels:
        app: qdrant-cluster
    spec:
      containers:
        - name: qdrant
          image: qdrant/qdrant:latest
          # This command tells Qdrant to use our custom config file.
          command:
            - /bin/sh
            - -c
            - |
              set -e
              # Full DNS for this pod (use your actual namespace if not 'default')
              MY_URI="http://${POD_NAME}.qdrant-cluster-pods.${POD_NAMESPACE}.svc.cluster.local:6335"
              # Bootstrap from first node
              BOOTSTRAP_URI="http://qdrant-cluster-0.qdrant-cluster-pods.${POD_NAMESPACE}.svc.cluster.local:6335"

              echo "MY_URI: $MY_URI"
              echo "BOOTSTRAP_URI: $BOOTSTRAP_URI"
              
              if [ "${POD_NAME}" = "qdrant-cluster-0" ]; then
                echo "Bootstrapping as first node with BOOTSTRAP_URI: $BOOTSTRAP_URI"
                echo "Executing command: ./qdrant --config-path /qdrant/config/config.yaml --uri \"$MY_URI\" --bootstrap \"$MY_URI\""
                exec ./qdrant --config-path /qdrant/config/config.yaml --uri "$MY_URI" --bootstrap "$MY_URI"
              else
                # Other nodes: bootstrap from first node
                echo "Joining cluster with URI: $MY_URI, bootstrap: $BOOTSTRAP_URI"
                echo "Executing command: ./qdrant --config-path /qdrant/config/config.yaml --uri \"$MY_URI\" --bootstrap \"$BOOTSTRAP_URI\""
                exec ./qdrant --config-path /qdrant/config/config.yaml --uri "$MY_URI" --bootstrap "$BOOTSTRAP_URI"
              fi
            # - "./qdrant"
            # - "--config-path"
            # - "/qdrant/config/config.yaml"
            # - "--uri"
            # - "qdrant-cluster-0.qdrant-cluster-pods:6335"
          # Environment variables for dynamic pod identity
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          ports:
            - containerPort: 6333
              name: http
            - containerPort: 6334
              name: grpc
            - containerPort: 6335
              name: p2p
          volumeMounts:
            - name: qdrant-storage
              mountPath: /qdrant/storage
            # Mount the ConfigMap as a volume.
            - name: qdrant-config-volume
              mountPath: /qdrant/config
      volumes:
        # Define the volume based on our ConfigMap.
        - name: qdrant-config-volume
          configMap:
            name: qdrant-cluster-config
  volumeClaimTemplates:
    - metadata:
        name: qdrant-storage
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 10Gi
```





### Step 3: Apply the Manifests

Apply both files. It's important to apply the `ConfigMap` first so it exists when the `StatefulSet` tries to mount it.

```bash
# Apply the configuration
kubectl apply -f qdrant-config.yaml

# Apply the services and statefulset
kubectl apply -f qdrant-cluster.yaml
```

The pods will start up one by one. The first pod (`qdrant-cluster-0`) will start, and then the other two (`-1` and `-2`) will discover it using the `bootstrap_uri` and form a cluster. This may take a minute or two.






### Step 4: Verify the Cluster Deployment

Let's check every component.

1.  **Check the Pods:**
    ```bash
    kubectl get pods -l app=qdrant-cluster -o wide
    ```
    *Expected Output:* You'll see three pods: `qdrant-cluster-0`, `qdrant-cluster-1`, and `qdrant-cluster-2`, all in the `Running` state, each with its own unique IP address.

2.  **Check the StatefulSet:**
    ```bash
    kubectl get statefulset qdrant-cluster
    ```
    *Expected Output:* You should see `READY` as `3/3`.

3.  **Check the Persistent Volume Claims (PVCs):**
    ```bash
    kubectl get pvc
    ```
    *Expected Output:* You will now see **three** PVCs, one for each pod, all `Bound`.
    *   `qdrant-storage-qdrant-cluster-0`
    *   `qdrant-storage-qdrant-cluster-1`
    *   `qdrant-storage-qdrant-cluster-2`




### Step 5: Interact with the Cluster via CLI (`curl`)

This is where things get interesting. You can interact with **any** node in the cluster, and it will coordinate with the others.

1.  **Set up Port Forwarding:** Let's forward to the first pod.
    ```bash
    # Open a new terminal for this and keep it running
    kubectl port-forward pod/qdrant-cluster-0 6333:6333
    ```

2.  **Check the Cluster Status:** Qdrant has a specific API endpoint for this.
    ```bash
    # In another new terminal
    curl -X GET http://localhost:6333/cluster | jq
    ```
    **Output:** 
    ```json
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   669  100   669    0     0   124k      0 --:--:-- --:--:-- --:--:--  130k
{
  "result": {
    "status": "enabled",
    "peer_id": 1903200026991620,
    "peers": {
      "3388008540355016": {
        "uri": "http://qdrant-cluster-2.qdrant-cluster-pods.default.svc.cluster.local:6335/"
      },
      "1903200026991620": {
        "uri": "http://qdrant-cluster-0.qdrant-cluster-pods.default.svc.cluster.local:6335/"
      },
      "7301051252924645": {
        "uri": "http://qdrant-cluster-1.qdrant-cluster-pods.default.svc.cluster.local:6335/"
      }
    },
    "raft_info": {
      "term": 1,
      "commit": 9,
      "pending_operations": 0,
      "leader": 1903200026991620,
      "role": "Leader",
      "is_voter": true
    },
    "consensus_thread_status": {
      "consensus_thread_status": "working",
      "last_update": "2025-08-22T13:40:19.131988194Z"
    },
    "message_send_failures": {}
  },
  "status": "ok",
  "time": 0.000021843
}
    ```
From this output, you can see **all cluster members**, their internal URIs, and **which node is the current leader**.






**Some Other Commands**
3.  **Create a Collection with Replication:**
    When creating a collection in a cluster, we should specify a `replication_factor`. A factor of `2` means every piece of data will be stored on 2 different nodes for redundancy.

    ```bash
    COLLECTION_NAME="my_cluster_collection"

    curl -X PUT "http://localhost:6333/collections/${COLLECTION_NAME}" \
         -H "Content-Type: application/json" \
         --data '{
            "vectors": { "size": 4, "distance": "Cosine" },
            "replication_factor": 2
         }' \
         | jq
    ```

4.  **Insert Data (Same as before):**
    You send the request to one node, and Qdrant's leader ensures the data is replicated correctly across the cluster according to the `replication_factor`.
    ```bash
    curl -X PUT "http://localhost:6333/collections/${COLLECTION_NAME}/points?wait=true" \
         -H "Content-Type: application/json" \
         --data '{
            "points": [
                {"id": 1, "vector": [0.9, 0.1, 0.1, 0.2], "payload": {"color": "red"}}
            ]
         }' \
         | jq
    ```

5.  **Search Data (and Demonstrate High Availability):**
    Now for the magic. We inserted the data while connected to `qdrant-cluster-0`. Let's see if we can read it from a *different* node.

    *   **Stop** the current `port-forward` command (Ctrl+C).
    *   **Start a new port-forward to a different pod**, like `qdrant-cluster-1`:
        ```bash
        kubectl port-forward pod/qdrant-cluster-1 6333:6333
        ```
    *   Now, run the **same search command** in your other terminal:
        ```bash
        curl -X POST "http://localhost:6333/collections/${COLLECTION_NAME}/points/search" \
             -H "Content-Type: application/json" \
             --data '{
                "vector": [0.85, 0.15, 0.1, 0.1],
                "limit": 1,
                "with_payload": true
             }' \
             | jq
        ```
    **Expected Output:**
    ```json
    {
      "result": [
        {
          "id": 1,
          "version": 1,
          "score": 0.9984123,
          "payload": { "color": "red" }
        }
      ],
      "status": "ok",
      "time": 0.0005
    }
    ```
    **It works!** Even though we're now connected to a completely different pod (`qdrant-cluster-1`), we can still read the data we wrote via `qdrant-cluster-0`. This proves that the data was successfully replicated across the cluster.


neaj@neaj-pc:~/g/s/g/N/y/qdrant|main⚡*?
➤ bash
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/qdrant$ COLLECTION_NAME="my_cluster_collection"
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/qdrant$ curl -X PUT "http://localhost:6333/collections/${COLLECTION_NAME}" \
         -H "Content-Type: application/json" \
         --data '{
            "vectors": { "size": 4, "distance": "Cosine" },
            "replication_factor": 2
         }' \
         | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   156  100    48  100   108     26     59  0:00:01  0:00:01 --:--:--    85
{
  "result": true,
  "status": "ok",
  "time": 1.818687831
}
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/qdrant$ curl -X PUT "http://localhost:6333/collections/${COLLECTION_NAME}/points?wait=true" \
         -H "Content-Type: application/json" \
         --data '{
            "points": [
                {"id": 1, "vector": [0.9, 0.1, 0.1, 0.2], "payload": {"color": "red"}}
            ]
         }' \
         | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   220  100    83  100   137   2920   4821 --:--:-- --:--:-- --:--:--  7857
{
  "result": {
    "operation_id": 0,
    "status": "completed"
  },
  "status": "ok",
  "time": 0.024132704
}
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/qdrant$ curl -X POST "http://localhost:6333/collections/${COLLECTION_NAME}/points/search" \
             -H "Content-Type: application/json" \
             --data '{
                "vector": [0.85, 0.15, 0.1, 0.1],
                "limit": 1,
                "with_payload": true
             }' \
             | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   241  100   110  100   131  11252  13400 --:--:-- --:--:-- --:--:-- 26777
{
  "result": [
    {
      "id": 1,
      "version": 0,
      "score": 0.9928753,
      "payload": {
        "color": "red"
      }
    }
  ],
  "status": "ok",
  "time": 0.006270731
}


### Another Example


neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/qdrant$ # In another terminal
COLLECTION_NAME="cities"

neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/qdrant$ curl -X PUT "http://localhost:6333/collections/${COLLECTION_NAME}" \
     -H "Content-Type: application/json" \
     --data '{
        "vectors": { "size": 4, "distance": "Euclid" },
        "replication_factor": 2,
        "shard_number": 3
     }' \
     | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   171  100    48  100   123     26     69  0:00:01  0:00:01 --:--:--    96
{
  "result": true,
  "status": "ok",
  "time": 1.776738657
}
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/qdrant$ curl -X PUT "http://localhost:6333/collections/${COLLECTION_NAME}/points?wait=true" \
     -H "Content-Type: application/json" \
     --data '{
        "points": [
            {"id": 1, "vector": [52.52, 13.40, 9.6, 4000], "payload": {"name": "Berlin", "country": "Germany"}},
            {"id": 2, "vector": [51.50, -0.12, 11.3, 5600], "payload": {"name": "London", "country": "UK"}},
            {"id": 3, "vector": [40.71, -74.00, 12.9, 11000], "payload": {"name": "New York", "country": "USA"}},
            {"id": 4, "vector": [35.68, 139.69, 15.4, 6100], "payload": {"name": "Tokyo", "country": "Japan"}},
            {"id": 5, "vector": [1.35, 103.81, 27.0, 8000], "payload": {"name": "Singapore", "country": "Singapore"}},
            {"id": 6, "vector": [-33.86, 151.20, 17.7, 400], "payload": {"name": "Sydney", "country": "Australia"}}
        ]
     }' \
     | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   804  100    83  100   721   5344  46429 --:--:-- --:--:-- --:--:-- 53600
{
  "result": {
    "operation_id": 0,
    "status": "completed"
  },
  "status": "ok",
  "time": 0.012710247
}
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/qdrant$ curl -X POST "http://localhost:6333/collections/${COLLECTION_NAME}/points/search" \
     -H "Content-Type: application/json" \
     --data '{
        "vector": [34.05, -118.24, 18.6, 3000],
        "limit": 3,
        "with_payload": true
     }' \
     | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   407  100   302  100   105  63021  21911 --:--:-- --:--:-- --:--:--   99k
{
  "result": [
    {
      "id": 1,
      "version": 0,
      "score": 1008.8366,
      "payload": {
        "country": "Germany",
        "name": "Berlin"
      }
    },
    {
      "id": 2,
      "version": 0,
      "score": 2602.7505,
      "payload": {
        "name": "London",
        "country": "UK"
      }
    },
    {
      "id": 6,
      "version": 0,
      "score": 2614.806,
      "payload": {
        "name": "Sydney",
        "country": "Australia"
      }
    }
  ],
  "status": "ok",
  "time": 0.001157935
}
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/qdrant$ 






### Demonstrate High Availability (Simulating a Node Failure)

➤ kubectl delete pod qdrant-cluster-0 
pod "qdrant-cluster-0" deleted
neaj@neaj-pc:~/g/s/g/N/y/qdrant|main⚡✚*
➤ bash
neaj@neaj-pc:~/go/src/github.com/Neaj-Morshad-101/yamls/qdrant$ curl -X POST "http://localhost:6333/collections/${COLLECTION_NAME}/points/search" \
     -H "Content-Type: application/json" \
     --data '{
        "vector": [34.05, -118.24, 18.6, 3000],
        "limit": 3,
        "with_payload": true
     }' \
     | jq

Result: You get the exact same successful response!




### You should also see the new leader is pod-1, and previous leader pod-0 is now a follower. 


➤ kubectl port-forward pod/qdrant-cluster-0 6333:6333

Forwarding from 127.0.0.1:6333 -> 6333
Forwarding from [::1]:6333 -> 6333
Handling connection for 6333
^C⏎                                                                                                                                                    



➤ curl -X GET http://localhost:6333/cluster | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   671  100   671    0     0   183k      0 --:--:-- --:--:-- --:--:--  218k
{
  "result": {
    "status": "enabled",
    "peer_id": 1903200026991620,
    "peers": {
      "3388008540355016": {
        "uri": "http://qdrant-cluster-2.qdrant-cluster-pods.default.svc.cluster.local:6335/"
      },
      "7301051252924645": {
        "uri": "http://qdrant-cluster-1.qdrant-cluster-pods.default.svc.cluster.local:6335/"
      },
      "1903200026991620": {
        "uri": "http://qdrant-cluster-0.qdrant-cluster-pods.default.svc.cluster.local:6335/"
      }
    },
    "raft_info": {
      "term": 2,
      "commit": 24,
      "pending_operations": 0,
      "leader": 7301051252924645,
      "role": "Follower",
      "is_voter": true
    },
    "consensus_thread_status": {
      "consensus_thread_status": "working",
      "last_update": "2025-08-22T13:56:43.326781916Z"
    },
    "message_send_failures": {}
  },
  "status": "ok",
  "time": 0.00001048
}


      neaj@neaj-pc:~/g/s/g/N/yamls|main⚡✚*
➤ kubectl port-forward pod/qdrant-cluster-1 6333:6333

Forwarding from 127.0.0.1:6333 -> 6333
Forwarding from [::1]:6333 -> 6333
Handling connection for 6333
^C⏎                                                                                                                                                    


neaj@neaj-pc:~/g/s/g/N/y/qdrant|main⚡✚*
➤ curl -X GET http://localhost:6333/cluster | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   670  100   670    0     0   157k      0 --:--:-- --:--:-- --:--:--  163k
{
  "result": {
    "status": "enabled",
    "peer_id": 7301051252924645,
    "peers": {
      "3388008540355016": {
        "uri": "http://qdrant-cluster-2.qdrant-cluster-pods.default.svc.cluster.local:6335/"
      },
      "7301051252924645": {
        "uri": "http://qdrant-cluster-1.qdrant-cluster-pods.default.svc.cluster.local:6335/"
      },
      "1903200026991620": {
        "uri": "http://qdrant-cluster-0.qdrant-cluster-pods.default.svc.cluster.local:6335/"
      }
    },
    "raft_info": {
      "term": 2,
      "commit": 24,
      "pending_operations": 0,
      "leader": 7301051252924645,
      "role": "Leader",
      "is_voter": true
    },
    "consensus_thread_status": {
      "consensus_thread_status": "working",
      "last_update": "2025-08-22T13:57:03.370734703Z"
    },
    "message_send_failures": {}
  },
  "status": "ok",
  "time": 0.000012373
}


      neaj@neaj-pc:~/g/s/g/N/yamls|main⚡✚*
➤ kubectl port-forward pod/qdrant-cluster-2 6333:6333

Forwarding from 127.0.0.1:6333 -> 6333
Forwarding from [::1]:6333 -> 6333
Handling connection for 6333
Handling connection for 6333


neaj@neaj-pc:~/g/s/g/N/y/qdrant|main⚡✚*
➤ curl -X GET http://localhost:6333/cluster | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1075  100  1075    0     0   244k      0 --:--:-- --:--:-- --:--:--  209k
{
  "result": {
    "status": "enabled",
    "peer_id": 3388008540355016,
    "peers": {
      "1903200026991620": {
        "uri": "http://qdrant-cluster-0.qdrant-cluster-pods.default.svc.cluster.local:6335/"
      },
      "3388008540355016": {
        "uri": "http://qdrant-cluster-2.qdrant-cluster-pods.default.svc.cluster.local:6335/"
      },
      "7301051252924645": {
        "uri": "http://qdrant-cluster-1.qdrant-cluster-pods.default.svc.cluster.local:6335/"
      }
    },
    "raft_info": {
      "term": 2,
      "commit": 24,
      "pending_operations": 0,
      "leader": 7301051252924645,
      "role": "Follower",
      "is_voter": true
    },
    "consensus_thread_status": {
      "consensus_thread_status": "working",
      "last_update": "2025-08-22T13:57:21.517474090Z"
    },
    "message_send_failures": {
      "http://qdrant-cluster-0.qdrant-cluster-pods.default.svc.cluster.local:6335/": {
        "count": 2,
        "latest_error": "Error in closure supplied to transport channel pool: status: Unavailable, message: \"error trying to connect: dns error: failed to lookup address information: Name or service not known\", details: [], metadata: MetadataMap { headers: {} }",
        "latest_error_timestamp": "2025-08-22T13:53:34.551697066Z"
      }
    }
  },
  "status": "ok",
  "time": 0.000019788
}





### Step 6: Cleaning Up

When you're done, you can delete all the resources you created:
```bash
kubectl delete -f qdrant-cluster.yaml
kubectl delete -f qdrant-config.yaml
```