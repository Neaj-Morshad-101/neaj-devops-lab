helm install kubedb oci://ghcr.io/appscode-charts/kubedb \
        --version v2023.12.28 \
        --namespace kubedb --create-namespace \
        --set-file global.license=/path/to/the/license.txt \
        --wait --burst-limit=10000 --debug \
        --set kubedb-kubestash-catalog.enabled=true

helm install kubestash oci://ghcr.io/appscode-charts/kubestash \
  --version v2023.12.28 \
  --namespace kubestash --create-namespace \
  --set-file global.license=/path/to/the/license.txt \
  --wait --burst-limit=10000 --debug