

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

    # Peer-to-peer (P2P) port for internode communication
    p2p:
      port: 6335

    # Cluster configuration section
    cluster:
      # This enables the cluster mode
      enabled: true
      # This is the crucial part for peer discovery.
      # It tells a new node where to find the first node (the bootstrap peer)
      # to join the cluster. It uses the stable DNS name provided by our
      # Headless Service and StatefulSet.
      bootstrap_uri: "http://qdrant-cluster-0.qdrant-cluster-pods:6335"
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
            - "./qdrant"
            - "--config-path"
            - "/qdrant/config/config.yaml"
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
            storage: 5Gi
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
    **Expected Output:** This is the most important command. It shows you the health of your cluster.
    ```json
    {
      "result": {
        "status": "enabled", // Confirms cluster mode is active
        "peer_id": 1234567890, // The unique ID of the node we're talking to (qdrant-cluster-0)
        "peers": { // Information about all members of the cluster
          "1234567890": { // This node (the leader)
            "uri": "http://10.244.0.10:6335" // Internal pod IP
          },
          "2345678901": { // Another peer
            "uri": "http://10.244.0.11:6335"
          },
          "3456789012": { // The third peer
            "uri": "http://10.244.0.12:6335"
          }
        },
        "raft_info": { // Information about the consensus protocol
          "term": 2,
          "commit": 15,
          "leader": 1234567890, // The ID of the current leader node
          "role": "Leader" // The role of the current node
        }
      },
      "status": "ok",
      "time": 0.0001
    }
    ```
    From this output, you can see **all cluster members**, their internal URIs, and **which node is the current leader**.

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

### Step 6: Cleaning Up

When you're done, you can delete all the resources you created:
```bash
kubectl delete -f qdrant-cluster.yaml
kubectl delete -f qdrant-config.yaml
```