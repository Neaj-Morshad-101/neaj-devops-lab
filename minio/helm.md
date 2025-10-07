```bash
➤ helm repo add minio https://operator.min.io/
"minio" has been added to your repositories

➤ helm repo update minio
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "minio" chart repository
Update Complete. ⎈Happy Helming!⎈


➤ helm upgrade --install --namespace "minio-operator" --create-namespace "minio-operator" minio/operator --set operator.replicaCount=1
Release "minio-operator" does not exist. Installing it now.
NAME: minio-operator
LAST DEPLOYED: Mon Oct  6 17:25:28 2025
NAMESPACE: minio-operator
STATUS: deployed
REVISION: 1
TEST SUITE: None


➤ kubectl get pods -A
minio-operator       minio-operator-57b9ccf48c-tt9zh              1/1     Running   0                11s

➤ kubectl get deploy -A
NAMESPACE            NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
minio-operator       minio-operator            1/1     1            1           24s



➤ helm ls -A
NAME              	NAMESPACE     	REVISION	UPDATED                                	STATUS  	CHART                     	APP VERSION
minio-operator    	minio-operator	1       	2025-10-06 17:25:28.496000666 +0600 +06	deployed	operator-7.1.1            	v7.1.1     




➤ helm upgrade --install --namespace "demo" --create-namespace milvus-minio minio/tenant \
      --set tenant.pools[0].servers=1 \
      --set tenant.pools[0].volumesPerServer=1 \
      --set tenant.pools[0].size=1Gi \
      --set tenant.certificate.requestAutoCert=false \
      --set tenant.buckets[0].name="milvus" \
      --set tenant.pools[0].name="default"
Release "milvus-minio" does not exist. Installing it now.
NAME: milvus-minio
LAST DEPLOYED: Mon Oct  6 17:31:30 2025
NAMESPACE: demo
STATUS: deployed
REVISION: 1
TEST SUITE: None


➤ kubectl view-secret myminio-env-configuration -n demo
Viewing only available key: config.env
export MINIO_ROOT_USER="minio"
export MINIO_ROOT_PASSWORD="minio123"




Every 2.0s: kubectl get all,pvc,secrets,cm -n minio-operator                                          neaj-pc: Mon Oct  6 20:55:52 2025

NAME                                  READY   STATUS    RESTARTS   AGE
pod/minio-operator-57b9ccf48c-tt9zh   1/1     Running   0          3h30m

NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/operator   ClusterIP   10.96.49.185   <none>        4221/TCP   3h30m
service/sts        ClusterIP   10.96.1.142    <none>        4223/TCP   3h30m

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/minio-operator   1/1     1            1           3h30m

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/minio-operator-57b9ccf48c   1         1         1       3h30m

NAME                                          TYPE                 DATA   AGE
secret/sh.helm.release.v1.minio-operator.v1   helm.sh/release.v1   1      3h30m
secret/sts-tls                                Opaque               2      3h30m

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      3h30m





Every 2.0s: kubectl get all,pvc,secrets,cm -n demo                                                                                                          neaj-pc: Mon Oct  6 20:55:58 2025

NAME                    READY   STATUS    RESTARTS   AGE
pod/myminio-default-0   2/2     Running   0          3h24m

NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/minio                 ClusterIP   10.96.82.71     <none>        80/TCP              3h24m
service/myminio-console       ClusterIP   10.96.187.42    <none>        9090/TCP            3h24m
service/myminio-hl            ClusterIP   None            <none>        9000/TCP            3h24m
service/mysql-proxy843        ClusterIP   10.96.127.236   <none>        6033/TCP            6d2h
service/mysql-proxy843-pods   ClusterIP   None            <none>        6032/TCP,6033/TCP   6d2h
service/mysql-proxy9          ClusterIP   10.96.63.239    <none>        6033/TCP            6d2h
service/mysql-proxy9-pods     ClusterIP   None            <none>        6032/TCP,6033/TCP   6d2h

NAME                               READY   AGE
statefulset.apps/myminio-default   1/1     3h24m

NAME                                 VERSION        STATUS     AGE
proxysql.kubedb.com/mysql-proxy843   2.7.3-debian   NotReady   6d2h
proxysql.kubedb.com/mysql-proxy9     3.0.1-debian   NotReady   6d2h

NAME                                            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/data-standalone2-0        Bound    pvc-fc54a516-c79e-47d6-b9c0-b43b158c4d23   1Gi        RWO            standard       <unset>                 6d2h
persistentvolumeclaim/data0-myminio-default-0   Bound    pvc-5013c550-065d-41e4-9eee-d820e0b6488f   1Gi        RWO            standard       <unset>                 3h24m

NAME                                        TYPE                 DATA   AGE
secret/mssql-auth                           Opaque               2      6d5h
secret/mssqlserver-ca                       kubernetes.io/tls    2      10d
secret/myminio-env-configuration            Opaque               1      3h24m
secret/sh.helm.release.v1.milvus-minio.v1   helm.sh/release.v1   1      3h24m

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      10d

```