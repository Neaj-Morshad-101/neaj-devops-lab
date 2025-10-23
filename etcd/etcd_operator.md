kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.2/cert-manager.yaml


neaj@neaj-pc:~/g/s/g/e/etcd-operator|main✓
➤ make docker-build docker-push IMG=neajmorshad/etcd-operator:1.0.0
docker build -t neajmorshad/etcd-operator:1.0.0 .
[+] Building 130.3s (19/19) FINISHED     



neaj@neaj-pc:~/g/s/g/e/etcd-operator|main✓
➤ make install

neaj@neaj-pc:~/g/s/g/e/etcd-operator|main⚡*
➤ kubectl get crd | grep etc
etcdclusters.operator.etcd.io                     2025-10-23T05:27:41Z
etcdversions.catalog.kubedb.com                   2025-09-30T11:54:35Z


neaj@neaj-pc:~/g/s/g/e/etcd-operator|main⚡*
➤ make deploy IMG=neajmorshad/etcd-operator:1.0.0



Every 2.0s: kubectl get all,cm,pvc,secrets,deploy -n etcd-operator-system            

NAME                                                    READY   STATUS    RESTARTS     AGE
pod/etcd-operator-controller-manager-77c7974d6b-6zt8l   1/1     Running   2 (8h ago)   8h

NAME                                                       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
service/etcd-operator-controller-manager-metrics-service   ClusterIP   10.96.1.76   <none>        8443/TCP   8h

NAME                                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/etcd-operator-controller-manager   1/1     1            1           8h

NAME                                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/etcd-operator-controller-manager-77c7974d6b   1         1         1       8h

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      8h




Apply and Create Etcd Cluster: 

neaj@neaj-pc:~/g/s/g/e/etcd-operator|main⚡*
➤ kubectl apply -k config/samples/





Every 2.0s: kubectl get all,cm,pvc,secrets,deploy        

NAME                       READY   STATUS    RESTARTS   AGE
pod/etcdcluster-sample-0   1/1     Running   0          8h
pod/etcdcluster-sample-1   1/1     Running   0          8h
pod/etcdcluster-sample-2   1/1     Running   0          8h

NAME                         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/etcdcluster-sample   ClusterIP   None         <none>        <none>    8h
service/kubernetes           ClusterIP   10.96.0.1    <none>        443/TCP   37d

NAME                                  READY   AGE
statefulset.apps/etcdcluster-sample   3/3     8h

NAME                                 DATA   AGE
configmap/etcdcluster-sample-state   3      8h
configmap/kube-root-ca.crt           1      37d








Client Connection:

neaj@neaj-pc:~/go/src/github.com/etcd-io/etcd-operator$ NAMESPACE=default
neaj@neaj-pc:~/go/src/github.com/etcd-io/etcd-operator$ POD=etcdcluster-sample-0
neaj@neaj-pc:~/go/src/github.com/etcd-io/etcd-operator$ echo $NAMESPACE
default

neaj@neaj-pc:~/go/src/github.com/etcd-io/etcd-operator$ kubectl -n $NAMESPACE exec $POD -- /usr/local/bin/etcdctl --version
Error: unknown flag: --version
NAME:
	etcdctl - A simple command line client for etcd3.

USAGE:
	etcdctl [flags]

VERSION:
	3.5.21

API VERSION:
	3.5

command terminated with exit code 1


neaj@neaj-pc:~/go/src/github.com/etcd-io/etcd-operator$ kubectl -n $NAMESPACE exec $POD -- /usr/local/bin/etcdctl --endpoints=http://127.0.0.1:2379 endpoint health
http://127.0.0.1:2379 is healthy: successfully committed proposal: took = 1.022465ms

neaj@neaj-pc:~/go/src/github.com/etcd-io/etcd-operator$ kubectl -n $NAMESPACE exec $POD -- /usr/local/bin/etcdctl --endpoints=http://127.0.0.1:2379 member list
41f5beba5f42189a, started, etcdcluster-sample-0, http://etcdcluster-sample-0.etcdcluster-sample.default.svc.cluster.local:2380, http://etcdcluster-sample-0.etcdcluster-sample.default.svc.cluster.local:2379, false
77d066c50a342883, started, etcdcluster-sample-1, http://etcdcluster-sample-1.etcdcluster-sample.default.svc.cluster.local:2380, http://etcdcluster-sample-1.etcdcluster-sample.default.svc.cluster.local:2379, false
dc427cfd0c2542e1, started, etcdcluster-sample-2, http://etcdcluster-sample-2.etcdcluster-sample.default.svc.cluster.local:2380, http://etcdcluster-sample-2.etcdcluster-sample.default.svc.cluster.local:2379, false



neaj@neaj-pc:~/go/src/github.com/etcd-io/etcd-operator$ kubectl -n $NAMESPACE exec $POD -- /usr/local/bin/etcdctl --endpoints=http://127.0.0.1:2379 put foo bar
OK
neaj@neaj-pc:~/go/src/github.com/etcd-io/etcd-operator$ kubectl -n $NAMESPACE exec $POD -- /usr/local/bin/etcdctl --endpoints=http://127.0.0.1:2379 get foo
foo
bar












Build Intaller: 
neaj@neaj-pc:~/g/s/g/e/etcd-operator|main⚡*
➤ make build-installer IMG=neajmorshad/etcd-operator:1.0.0


