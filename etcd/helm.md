```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update


kubectl create ns etcd


helm install etcd-cluster bitnami/etcd \
  --namespace etcd \
  -f values.yaml





Every 2.0s: kubectl get all,pvc,secrets,cm -n etcd     
NAME                 READY   STATUS             RESTARTS   AGE
pod/etcd-client      0/1     ImagePullBackOff   0          48s
pod/etcd-cluster-0   0/1     ImagePullBackOff   0          2m45s
pod/etcd-cluster-1   0/1     ImagePullBackOff   0          2m45s
pod/etcd-cluster-2   0/1     ImagePullBackOff   0          2m45s

NAME                            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE
service/etcd-cluster            ClusterIP   10.96.153.98   <none>        2379/TCP,2380/TCP   2m45s
service/etcd-cluster-headless   ClusterIP   None           <none>        2379/TCP,2380/TCP   2m45s

NAME                            READY   AGE
statefulset.apps/etcd-cluster   0/3     2m45s

NAME                                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/data-etcd-cluster-0   Bound    pvc-34085f52-8ba1-468b-b750-aa7b37e1c9e9   5Gi        RWO            standard       <unset>                 2m45s
persistentvolumeclaim/data-etcd-cluster-1   Bound    pvc-474af2c2-b1d0-4b0d-9c9f-b48cb0784e12   5Gi        RWO            standard       <unset>                 2m45s
persistentvolumeclaim/data-etcd-cluster-2   Bound    pvc-ba9b16bc-22b9-48a1-b2ac-18022f4639ba   5Gi        RWO            standard       <unset>                 2m45s

NAME                                        TYPE                 DATA   AGE
secret/etcd-cluster                         Opaque               1      2m45s
secret/etcd-cluster-jwt-token               Opaque               1      2m45s
secret/sh.helm.release.v1.etcd-cluster.v1   helm.sh/release.v1   1      2m45s

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      5m28s





Bitnami images are not availble now:
Failed to pull image "docker.io/bitnami/etcd:3.6.4-debian-12-r3": rpc error: code = NotFound desc = failed to pull and unpack image "docker.io/bitnami/etcd:3.6.4-debian-12-r3": failed to resolve reference "docker.io/bitnami/etcd:3.6.4-debian-12-r3": docker.io/bitnami/etcd:3.6.4-debian-12-r3: not found







kubectl run etcd-client --rm -i --tty --image=docker.io/bitnami/etcd:latest \
  --namespace etcd --command -- /bin/sh

# Inside client:
ETCDCTL_API=3 etcdctl --endpoints=http://etcd-cluster.etcd.svc.cluster.local:2379 \
  --user root:StrongPass123 put /hello world
ETCDCTL_API=3 etcdctl --endpoints=http://etcd-cluster.etcd.svc.cluster.local:2379 \
  --user root:StrongPass123 get /hello


```


