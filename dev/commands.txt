Local setup with docker compose:

npm install



Build and Run with Docker Compose: From the project root, execute the following command. The --build flag tells Docker Compose to build the images from your Dockerfiles.
docker compose up --build
You will see logs from all three containers (database, backend, frontend) in your terminal.



Verify the Application:
Open your web browser and navigate to http://localhost:3000.
The frontend application should load.


Test functionality:
Click "Sign up" and create a new account.
Log in with your new account.
Create a "New Post".
If you can do all of this, it confirms that:
The frontend container is serving the React app.
The frontend is successfully proxying API requests to the backend container.
The backend is successfully connecting to the database container and persisting data.
Stopping the Application:
To stop the application, press Ctrl+C in the terminal where Docker Compose is running.










To remove the containers and network, run:
docker compose down
If you want to remove the database volume as well (deleting all data), run:
docker compose down -v







kubernetes:

# Build the backend image
docker build -t realworld-backend:v1 -f Dockerfile .

# Build the frontend image
docker build -t realworld-frontend:v1 -f Dockerfile .




kind load docker-image realworld-backend:v1
kind load docker-image realworld-frontend:v1


# Create the secret for PostgreSQL credentials
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_USER=myuser \
  --from-literal=POSTGRES_PASSWORD=mypassword \
  --from-literal=POSTGRES_DB=realworld_db

# Create the secret for the backend's JWT key
kubectl create secret generic backend-secret \
  --from-literal=JWT_SECRET='your-super-secret-jwt-key'


helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace


kubectl delete -f k8s/.
kubectl apply -f k8s/.





Every 2.0s: kubectl get deploy,pods,pvc,svc,pv,secret,cm                                          laptop: Sat Sep 13 16:25:44 2025

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend-deployment    2/2     2            2           59s
deployment.apps/frontend-deployment   2/2     2            2           45s
deployment.apps/postgres-deployment   1/1     1            1           66s

NAME                                       READY   STATUS    RESTARTS   AGE
pod/backend-deployment-586fdc9d5c-rvg9r    1/1     Running   0          59s
pod/backend-deployment-586fdc9d5c-wkxfr    1/1     Running   0          59s
pod/frontend-deployment-56bfdc7d8f-c9vtl   1/1     Running   0          45s
pod/frontend-deployment-56bfdc7d8f-q4gqc   1/1     Running   0          45s
pod/postgres-deployment-b8db89985-mfw2m    1/1     Running   0          66s

NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS
VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/postgres-pvc   Bound    pvc-69ecf223-5230-401d-b1f2-252d81eef821   1Gi        RWO            standard
<unset>                 66s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/backend        ClusterIP   10.96.73.17     <none>        3001/TCP       59s
service/frontend-svc   NodePort    10.96.130.24    <none>        80:32348/TCP   45s
service/kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        11m
service/postgres-svc   ClusterIP   10.96.227.218   <none>        5432/TCP       66s

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM
     STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pvc-69ecf223-5230-401d-b1f2-252d81eef821   1Gi        RWO            Delete           Bound    default/postgres-p
vc   standard       <unset>                          64s

NAME                     TYPE     DATA   AGE
secret/backend-secret    Opaque   1      10m
secret/postgres-secret   Opaque   3      10m

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      11m


