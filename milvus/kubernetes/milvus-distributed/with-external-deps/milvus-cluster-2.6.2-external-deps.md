Step 1: Create a Central Namespace

kubectl create namespace milvus





Step 2: Deploy a Production-Grade Etcd Cluster with Helm

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install milvus-etcd bitnami/etcd \
  --namespace milvus \
  --set replicaCount=3 \
  --set persistence.enabled=true \
  --set persistence.size=20Gi

kubectl get statefulset -n milvus milvus-etcd
kubectl get service -n milvus milvus-etcd





Step 3: Deploy a Production-Grade MinIO Cluster with Helm


helm install milvus-minio bitnami/minio \
  --namespace milvus \
  --set mode=distributed \
  --set replicas=4 \
  --set persistence.enabled=true \
  --set persistence.size=100Gi

  kubectl get statefulset -n milvus milvus-minio
  kubectl get service -n milvus milvus-minio


Crucially, get the credentials: 

kubectl get secret -n milvus milvus-minio -o jsonpath='{.data.root-user}' | base64 --decode
# Expected output: minio
kubectl get secret -n milvus milvus-minio -o jsonpath='{.data.root-password}' | base64 --decode
# Expected output: minio123




Step 4: Generate and Deploy the Milvus Manifest (Configured for External Dependencies)
helm template my-release zilliztech/milvus \
  --namespace milvus \
  --set cluster.enabled=true \
  --set etcd.enabled=false \
  --set minio.enabled=false \
  --set pulsar.enabled=false \
  --set woodpecker.enabled=true \
  --set streaming.enabled=true \
  --set indexNode.enabled=false \
  --set woodpecker.persistence.enabled=true \
  --set streamingnode.persistence.volumeClaim.size=50Gi \
  --set externalEtcd.enabled=true \
  --set externalEtcd.endpoints[0]="milvus-etcd.milvus.svc.cluster.local:2379" \
  --set externalMinio.enabled=true \
  --set externalMinio.endpoint="milvus-minio.milvus.svc.cluster.local" \
  --set externalMinio.port="9000" \
  --set externalMinio.accessKey="minio" \
  --set externalMinio.secretKey="minio123" \
  > milvus-cluster-components.yaml


  kubectl apply -f milvus-cluster-components.yaml



# milvus-values.yaml for External Dependencies
```
# This values.yaml file configures the Milvus Helm chart to run in cluster mode
# while connecting to externally managed dependencies (Etcd and MinIO).

# 1. Enable Cluster Mode
cluster:
  enabled: true

# 2. Disable Bundled Dependencies
# We are managing these dependencies ourselves, so we disable them in this chart.
etcd:
  enabled: false

minio:
  enabled: false

pulsar:
  enabled: false # Explicitly disable the older Pulsar v2
pulsarV3: # Also disable the newer Pulsar v3, as we're using Woodpecker
  enabled: false

# 3. Enable the Modern Woodpecker/Streaming Architecture
# This is the recommended setup for Milvus 2.6+
woodpecker:
  enabled: true
  # IMPORTANT: Enable persistence for Woodpecker's Write-Ahead Log (WAL)
  # This switches the Streaming Node from a Deployment to a StatefulSet
  persistence:
    enabled: true

streaming:
  enabled: true

# Configure the PVC for the Streaming Node (enabled by woodpecker.persistence)
streamingnode:
  persistence:
    enabled: true # Redundant but safe to include
    volumeClaim:
      size: 50Gi
      # Optional: specify a storage class if you have one
      # storageClassName: "your-fast-ssd-storage-class"

# Disable the legacy Index Node (its function is now part of Data Node)
indexNode:
  enabled: false

# 4. Configure Connection to External Dependencies
# This is the most critical section. It tells Milvus where to find the
# services you deployed separately (e.g., with the Bitnami charts).

# --- External Etcd Configuration ---
externalEtcd:
  enabled: true
  # The full internal DNS name of your Etcd service.
  # Format: <service-name>.<namespace>.svc.cluster.local:<port>
  endpoints:
    - "milvus-etcd.milvus.svc.cluster.local:2379"

# --- External MinIO Configuration ---
externalMinio:
  enabled: true
  # The endpoint and port of your MinIO service.
  endpoint: "milvus-minio.milvus.svc.cluster.local"
  port: "9000"
  # The credentials for your MinIO instance.
  # These must match the credentials of the MinIO you deployed.
  # The Bitnami chart defaults are 'minio' and 'minio123'.
  accessKey: "minio"
  secretKey: "minio123"

# 5. (Optional) Set Image Tag
# It's good practice to pin the version you want to use.
# If you omit this, it will use the chart's default version.
image:
  all:
    tag: v2.6.2 # Or your desired Milvus version
```




Deploy Etcd:
helm install milvus-etcd bitnami/etcd --namespace milvus --create-namespace --set persistence.enabled=true


Deploy MinIO:
helm install milvus-minio bitnami/minio --namespace milvus --set mode=distributed --set persistence.enabled=true



kubectl apply -f milvus-cluster-config.yaml
kubectl apply -f milvus-cluster-components.yaml


