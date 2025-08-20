### Goal

Our goal is to deploy a **standalone Qdrant instance** on Kubernetes using raw YAML manifests. This setup will include:
1.  A **StatefulSet** to ensure our Qdrant pod has a stable identity and persistent storage.
2.  A **Headless Service** (`qdrant-standalone-pods`) for internal discovery by the StatefulSet.
3.  A **ClusterIP Service** (`qdrant-standalone`) to provide a stable endpoint for other applications within the cluster to use.

---

### Understanding the Components (The "Why")

*   **StatefulSet:** We use a `StatefulSet` for databases like Qdrant because it provides guarantees that a regular `Deployment` doesn't. Each pod gets a predictable, stable name (e.g., `qdrant-standalone-0`) and its own persistent storage volume. If the pod restarts, it will come back with the same name and re-attach to the same storage, preserving your data.

*   **Headless Service (`clusterIP: None`):** This service doesn't have a single IP address. Instead, when you query its DNS name, it returns the individual IP addresses of all the pods it selects (in our case, just `qdrant-standalone-0`). The `StatefulSet` requires this type of service to maintain the unique network identity of its pods. Its name **must** match the `serviceName` field in the `StatefulSet` spec.

*   **ClusterIP Service (Normal Service):** This is the standard service type. It gets a single, stable virtual IP address within the cluster. Any application inside your Kubernetes cluster can send requests to this single IP, and the service will automatically load-balance the traffic to the healthy Qdrant pod(s). This is the service your applications will typically connect to.

---

### Step 1: Create the Full Kubernetes Manifest

Let's combine all the required components into a single YAML file. The key additions are the new headless service and ensuring the `serviceName` in the StatefulSet points to it.

Create a file named `qdrant-manifest.yaml` and paste the following content:

```yaml
# ------------------- Headless Service ------------------- #
# Purpose: Required by the StatefulSet for stable pod identity.
# Not used for client connections.
apiVersion: v1
kind: Service
metadata:
  name: qdrant-standalone-pods # The name for the headless service
spec:
  clusterIP: None # This makes it a "headless" service
  selector:
    app: qdrant-standalone # Must match the pod labels
  ports:
    - name: http
      port: 6333
      targetPort: 6333
    - name: grpc
      port: 6334
      targetPort: 6334

---
# ------------------- ClusterIP Service ------------------- #
# Purpose: Provides a stable endpoint for other applications inside the cluster.
apiVersion: v1
kind: Service
metadata:
  name: qdrant-standalone # The name for the client-facing service
spec:
  type: ClusterIP # Default service type
  selector:
    app: qdrant-standalone # Must match the pod labels
  ports:
    - name: http
      port: 6333
      targetPort: 6333
    - name: grpc
      port: 6334
      targetPort: 6334

---
# ------------------- StatefulSet ------------------- #
# Purpose: Manages the Qdrant pod and its persistent storage.
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: qdrant-standalone
spec:
  # This MUST match the name of the Headless Service above
  serviceName: "qdrant-standalone-pods"
  replicas: 1
  selector:
    matchLabels:
      app: qdrant-standalone
  template:
    metadata:
      labels:
        app: qdrant-standalone # The label used by the services' selectors
    spec:
      containers:
        - name: qdrant
          image: qdrant/qdrant:latest
          ports:
            - containerPort: 6333
              name: http
            - containerPort: 6334
              name: grpc
          volumeMounts:
            - name: qdrant-storage # Must match the name in volumeClaimTemplates
              mountPath: /qdrant/storage
  # This template defines the persistent storage for each pod
  volumeClaimTemplates:
    - metadata:
        name: qdrant-storage
      spec:
        accessModes: ["ReadWriteOnce"]
        # IMPORTANT: Your cluster must have a default StorageClass
        # or you must specify one here with 'storageClassName: "your-sc-name"'
        resources:
          requests:
            storage: 5Gi # Request 5 GB of storage
```

### Step 2: Apply the Manifest to Your Cluster

Open your terminal, navigate to where you saved `qdrant-manifest.yaml`, and run:

```bash
kubectl apply -f qdrant-manifest.yaml
```

You should see output indicating that the services and the statefulset have been created.

### Step 3: Verify the Deployment (See Different Status)

Let's check that everything came up correctly.

1.  **Check the StatefulSet:**

    ```bash
    kubectl get statefulset qdrant-standalone
    ```
    *Expected Output:* You should see `READY` as `1/1`.

2.  **Check the Pod:**

    ```bash
    kubectl get pods -l app=qdrant-standalone
    ```
    *Expected Output:* You'll see a pod named `qdrant-standalone-0` with a `STATUS` of `Running`.

3.  **Check the Services:**

    ```bash
    kubectl get svc
    ```
    *Expected Output:* You will see both services. Note the difference in `CLUSTER-IP`:
    *   `qdrant-standalone` will have a cluster IP address.
    *   `qdrant-standalone-pods` will have `<none>`, because it's headless.

4.  **Check the Persistent Volume Claim (PVC):** This confirms that storage was successfully provisioned.

    ```bash
    kubectl get pvc
    ```
    *Expected Output:* You'll see a PVC named `qdrant-storage-qdrant-standalone-0` with a `STATUS` of `Bound`.
    > **Troubleshooting:** If the status is `Pending`, it usually means your Kubernetes cluster doesn't have a default `StorageClass` configured. You may need to create one or specify an existing one in the YAML.

5.  **Check the Pod Logs:** This is useful for debugging if something goes wrong.

    ```bash
    kubectl logs qdrant-standalone-0
    ```
    *Expected Output:* You should see Qdrant's startup logs, ending with lines indicating it's ready to accept connections.

### Step 4: Interact with Qdrant (Insert and Query Sample Data)

The easiest way to connect to Qdrant from your local machine for testing is using `port-forward`.

1.  **Open a NEW terminal** and run the following command. This will keep running, creating a tunnel from your local port `6333` to the Qdrant pod's port `6333`.

    ```bash
    kubectl port-forward svc/qdrant-standalone 6333:6333
    ```
    > We are forwarding to the `qdrant-standalone` service. This is a robust way to do it, as the service will always point to the correct pod.

2.  **Now, let's use a Python script to add and search for data.**
    *   First, make sure you have the required libraries installed:
        ```bash
        pip install qdrant-client numpy
        ```
    *   Create a Python file named `test_qdrant.py` and paste this code:

    ```python
    import numpy as np
    from qdrant_client import QdrantClient, models

    # Connect to the Qdrant instance we are port-forwarding to
    client = QdrantClient(host="localhost", port=6333)

    COLLECTION_NAME = "my_first_collection"

    # --- 1. Create a new collection ---
    # We will use a vector size of 4, and a cosine distance metric
    print(f"Creating collection: {COLLECTION_NAME}")
    client.recreate_collection(
        collection_name=COLLECTION_NAME,
        vectors_config=models.VectorParams(size=4, distance=models.Distance.COSINE),
    )
    print("Collection created successfully.")

    # --- 2. Insert some sample data (vectors) ---
    print("\nInserting sample vectors...")
    client.upsert(
        collection_name=COLLECTION_NAME,
        wait=True,
        points=[
            models.PointStruct(id=1, vector=[0.9, 0.1, 0.1, 0.2], payload={"color": "red"}),
            models.PointStruct(id=2, vector=[0.1, 0.9, 0.1, 0.1], payload={"color": "green"}),
            models.PointStruct(id=3, vector=[0.1, 0.1, 0.9, 0.1], payload={"color": "blue"}),
            models.PointStruct(id=4, vector=[0.8, 0.2, 0.2, 0.2], payload={"color": "light-red"}),
        ],
    )
    print("Vectors inserted.")

    # --- 3. Check the status of the collection ---
    collection_info = client.get_collection(collection_name=COLLECTION_NAME)
    print(f"\nCollection info: {collection_info.points_count} points total.")

    # --- 4. Perform a search ---
    # Let's find vectors that are most similar to [0.85, 0.15, 0.1, 0.1]
    query_vector = np.array([0.85, 0.15, 0.1, 0.1])
    print(f"\nSearching for vectors similar to: {query_vector}")

    search_result = client.search(
        collection_name=COLLECTION_NAME,
        query_vector=query_vector,
        limit=2 # Get the top 2 closest results
    )

    print("Search results:")
    for result in search_result:
        print(f"  - Point ID: {result.id}, Score: {result.score:.4f}, Payload: {result.payload}")

    ```
3.  **Run the script:**
    ```bash
    python test_qdrant.py
    ```

    You will see output showing the collection being created, data being inserted, and finally the search results. The results should show that Point ID 1 and 4 are the closest matches, which makes sense as their vectors are numerically very similar to our query vector.

### Step 5: Cleaning Up

Once you are finished, you can remove all the Kubernetes resources you created with a single command:

```bash
kubectl delete -f qdrant-manifest.yaml
```

This will delete the StatefulSet, the Services, the Pod, and the PersistentVolumeClaim. Your underlying PersistentVolume might need to be cleaned up separately depending on your cluster's configuration.
















Interacting with Qdrant using curl: 

Step 1: Create a Collection

curl -X PUT "http://localhost:6333/collections/"my_cli_collection"" \
     -H "Content-Type: application/json" \
     --data '{
        "vectors": {
            "size": 4,
            "distance": "Cosine"
        }
     }' \
     | jq



  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   142  100    47  100    95    620   1255 --:--:-- --:--:-- --:--:--  1893
{
  "result": true,
  "status": "ok",
  "time": 0.06857313
}
neaj@laptop ~/g/s/g/N/yamls (main)> 




Step 2: Insert Data (Points)

curl -X PUT "http://localhost:6333/collections/"my_cli_collection"/points?wait=true" \
     -H "Content-Type: application/json" \
     --data '{
        "points": [
            {"id": 1, "vector": [0.9, 0.1, 0.1, 0.2], "payload": {"color": "red"}},
            {"id": 2, "vector": [0.1, 0.9, 0.1, 0.1], "payload": {"color": "green"}},
            {"id": 3, "vector": [0.1, 0.1, 0.9, 0.1], "payload": {"color": "blue"}},
            {"id": 4, "vector": [0.8, 0.2, 0.2, 0.2], "payload": {"color": "light-red"}}
        ]
     }' \
     | jq


  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   465  100    83  100   382   6939  31937 --:--:-- --:--:-- --:--:-- 42272
{
  "result": {
    "operation_id": 0,
    "status": "completed"
  },
  "status": "ok",
  "time": 0.005530035
}





Step 3: Verify the Collection Status ("Get" Status)


curl -X GET "http://localhost:6333/collections/"my_cli_collection"" | jq


  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   815  100   815    0     0   150k      0 --:--:-- --:--:-- --:--:--  159k
{
  "result": {
    "status": "green",
    "optimizer_status": "ok",
    "indexed_vectors_count": 0,
    "points_count": 4,
    "segments_count": 8,
    "config": {
      "params": {
        "vectors": {
          "size": 4,
          "distance": "Cosine"
        },
        "shard_number": 1,
        "replication_factor": 1,
        "write_consistency_factor": 1,
        "on_disk_payload": true
      },
      "hnsw_config": {
        "m": 16,
        "ef_construct": 100,
        "full_scan_threshold": 10000,
        "max_indexing_threads": 0,
        "on_disk": false
      },
      "optimizer_config": {
        "deleted_threshold": 0.2,
        "vacuum_min_vector_number": 1000,
        "default_segment_number": 0,
        "max_segment_size": null,
        "memmap_threshold": null,
        "indexing_threshold": 10000,
        "flush_interval_sec": 5,
        "max_optimization_threads": null
      },
      "wal_config": {
        "wal_capacity_mb": 32,
        "wal_segments_ahead": 0,
        "wal_retain_closed": 1
      },
      "quantization_config": null,
      "strict_mode_config": {
        "enabled": false
      }
    },
    "payload_schema": {}
  },
  "status": "ok",
  "time": 0.000352035
}







Step 4: Search for Data ("Get" by Similarity)

curl -X POST "http://localhost:6333/collections/"my_cli_collection"/points/search" \
     -H "Content-Type: application/json" \
     --data '{
        "vector": [0.85, 0.15, 0.1, 0.1],
        "limit": 2,
        "with_payload": true
     }' \
     | jq


  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   281  100   182  100    99  26426  14374 --:--:-- --:--:-- --:--:-- 46833
{
  "result": [
    {
      "id": 1,
      "version": 0,
      "score": 0.9928753,
      "payload": {
        "color": "red"
      }
    },
    {
      "id": 4,
      "version": 0,
      "score": 0.98361176,
      "payload": {
        "color": "light-red"
      }
    }
  ],
  "status": "ok",
  "time": 0.002636054
}




Bonus Step: Retrieve a Single Point by ID ("Get" by ID)
# Retrieve the point with ID=3
curl -X GET "http://localhost:6333/collections/"my_cli_collection"/points/3" | jq


  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   133  100   133    0     0  21647      0 --:--:-- --:--:-- --:--:-- 22166
{
  "result": {
    "id": 3,
    "payload": {
      "color": "blue"
    },
    "vector": [
      0.10910895,
      0.10910895,
      0.9819805,
      0.10910895
    ]
  },
  "status": "ok",
  "time": 0.000552538
}