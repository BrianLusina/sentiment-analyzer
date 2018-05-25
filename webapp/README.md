# Web app for Sentiment Analysis

Runs a simple server that receives requests from client and forwards them to logic api for sentiment analysis.

## Packaging the application

`gradle build`

## Running the application

`java -jar ./build/libs/webapp.jar --logic.api.url=http://localhost:5000`

## Building the container

`$ docker build -f Dockerfile -t $DOCKER_USER_ID/sentiment-analysis-web-app .`

## Running the container

```bash
docker run -d -p 8080:8080 -e SA_LOGIC_API_URL='http://<container_ip or docker machine ip>:5000' $DOCKER_USER_ID/sentiment-analysis-webapp
```

## Native docker support needs the Container IP

CONTAINER_IP: To forward messages to the sa-logic container we need to get  its IP. To do so execute:

`$ docker container list`

Copy the id of sa-logic container and execute:

`$ docker inspect <container_id>`

The Containers IP address is found under the property NetworkSettings.IPAddress, use it in the RUN command.

## Docker Machine on a VM 

Get Docker Machine IP by executing:

`$ docker-machine ip`

Use this one in the command.

## Pushing the container

`$ docker push $DOCKER_USER_ID/sentiment-analysis-web-app`

## Using Kubernetes

The kubernetes setup instructions for the webapp are in the yaml files provided. The [webapp load balancer](./webapp-service-lb.yaml).

```yaml
apiVersion: v1
kind: Service
metadata:
        name: webapp-load-balancer
spec:
        type: LoadBalancer
        ports:
                - port: 80
                  protocol: TCP
                  targetPort: 8080
        selector:
                app: webapp

```

These instructions define how to build the Client Pod (Smallest compute unit that can run multiple containers).

1. __kind__: A service.
2. __type__: Specification type, we choose LoadBalancer because we want to balance the load between the pods.
3. __port__: Specifies the port in which the service gets requests.
4. __protocol__: Defines the communication.
5. __targetPort__: The port at which incomming requests are forwarded.
6. __selector__: Object that contains properties for selecting pods.
7. __app__: client Defines which pods to target, only pods that are labeled with “app: webapp”

To create this service:

```bash
$ kubectl create -f webapp-service-lb.yaml
service "webapp-load-balancer" created
```

To check that the service is running:

```bash
$ kubectl get svc
NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
webapp-load-balancer   LoadBalancer   10.98.247.33     <pending>     80:30481/TCP   7m
```

The External-IP is in a pending state because we are running locally. Running it in a cloud provider would give us an IP.

To run the application as a deployment, the [webapp-deployment](./webapp-deployment.yaml) file has the following instructions:

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
        name: webapp
spec:
        replicas: 2
        minReadySeconds: 15
        strategy:
                type: RollingUpdate
                rollingUpdate:
                        maxUnavailable: 1
                        maxSurge: 1
        template:
                metadata:
                        labels:
                                app: webapp
                spec:
                        containers:
                                - image: thelusina/sentiment-analysis-webapp
                                  imagePullPolicy: Always
                                  name: webapp
                                  env:
                                          - name: LOGIC_API_URL
                                            value: "http://logic"
                                  ports:
                                          - containerPort: 8080
```

1. __Kind__: A deployment.
2. __Replicas__ is a property of the deployments Spec object that defines how many pods we want to run. So only 2.
3. __Type__ specifies the strategy used in this deployment when moving from the current version to the next. The strategy RollingUpdate ensures Zero Downtime deployments.
4. __MaxUnavailable__ is a property of the RollingUpdate object that specifies the maximum unavailable pods allowed (compared to the desired state) when doing a rolling update. For our deployment which has 2 replicas this means that after terminating one Pod, we would still have one pod running, this way keeping our application accessible.
5. __MaxSurge__ is another property of the RollingUpdate object that defines the maximum amount of pods added to a deployment(compared to the desired state). For our deployment, this means that when moving to a new version we can add one pod, which adds up to 3 pods at the same time.
6. __Template__: specifies the pod template that the Deployment will use to create new pods
7. __app__: `webapp` the label to use for the pods created by this template.
8. __ImagePullPolicy__ when set to Always, it will pull the container images on each redeployment.
9. __env__: this declares an environment variables LOGIC_API_URL with the value `http://logic` inside the pods.

We initialize the LOGIC_API_URL here so that we can access the logic service url from the webapp.

> side note
> KUBE-DNS
> Kubernetes has a special pod the kube-dns. And by default, all Pods use it as the DNS Server. One important property of > kube-dns is that it creates a DNS record for each created service. This means that when you create the service logic it > got an IP address and its name was added as a record (in conjunction with the IP) in kube-dns, this enables all the pods > to translate the logic to the Logic services IP address.

You can run the deployment with:

```bash
$ kubectl apply -f webapp-deployment.yaml --record
deployment.extensions "webapp-deployment" created
```

You can check that it is running with:

```bash
$ kubectl get pods
NAME                                    READY     STATUS    RESTARTS   AGE
webapp-5485d8d99f-bb8mr                 1/1       Running   1          1m
webapp-5485d8d99f-fbdbn                 1/1       Running   1          1m
```