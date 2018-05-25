# Client for Sentiment Analyser

Front facing part of application.

## Starting the Web App Locally

`$ yarn start`

## Building the application

`$ yarn build`

## Building the container

`$ docker build -f Dockerfile -t $DOCKER_USER_ID/sentiment-analysis-client .`

## Running the container

`$ docker run -d -p 80:80 $DOCKER_USER_ID/sentiment-analysis-client`

## Pushing the container

`$ docker push $DOCKER_USER_ID/sentiment-analysis-client`

### Kubernetes

The kubernetes setup instructions for the client are in the yaml files provided. The [client-pod](./client-pod.yaml).

```yaml
apiVersion: v1
kind: Pod
metadata:
        name: client
        labels:
                app: client
spec:
        containers:
                - image: thelusina/sentiment-analysis-client
                  name: client
                  ports:
                          - containerPort: 80

```

These instructions define how to build the Client Pod (Smallest compute unit that can run multiple containers).

1. __kind__: specifies the kind of the Kubernetes Resource that we want to create. In our case, a Pod.
2. __name__: (in the metadata block) defines the name for the resource. We named it client. Feel free to give it another name.
3. __labels__: (in metatdata block) defines an organized way to define Kubernetes resources and is used by services to target specific resources (more on this below).
4. __spec__ is the object that defines the desired state for the resource. The most important property of a Pods Spec is the Array of containers.
5. __image__ is the container image we want to start in this pod. You can use the name of the image you used to push to docker hub (as above).
6. __name__ (in the containers block) is the unique name for a container in a pod.
7. __containerPort__:is the port at which the container is listening. This is just an indicator for the reader (dropping the port doesn’t restrict access).

You can create the pod with:

```bash
$ kubectl create -f client-pod.yaml
pod "client" created
```

To check if the pod is running:

```bash
$ kubectl get pods
NAME                    READY     STATUS    RESTARTS   AGE
client                   1/1       Running   0          7s
```

To access the application externally:

```bash
$ kubectl port-forward client 88:80
Forwarding from 127.0.0.1:88 -> 80
```

Open your browser in 127.0.0.1:88 and you will get to the react application.

To check the contents of the running pod

```bash
$ kubectl exect -it client -- /bin/bash
root@client:/#
$ root@client:/# ls /usr/share/nginx/html/
50x.html             favicon.ico  manifest.json      static
asset-manifest.json  index.html   service-worker.js
```

This confirms that our pod has all the resources to run the application.

To fetch all pods labeled `client`

```bash
$ kubectl get pod -l app=client
NAME      READY     STATUS    RESTARTS   AGE
client    1/1       Running   0          8m
```

The [client-service-lb](./client-service-lb.yaml) defines the load balancer service that is used to balance the load for running client pods:

```yaml
apiVersion: v1
kind: Service
metadata:
        name: client-load-balancer
spec:
        type: LoadBalancer
        ports:
                - port: 80
                  protocol: TCP
                  targetPort: 80
        selector:
                app: client

```

1. __kind__: A service.
2. __type__: Specification type, we choose LoadBalancer because we want to balance the load between the pods.
3. __port__: Specifies the port in which the service gets requests.
4. __protocol__: Defines the communication.
5. __targetPort__: The port at which incomming requests are forwarded.
6. __selector__: Object that contains properties for selecting pods.
7. __app__: client Defines which pods to target, only pods that are labeled with “app: client”

To create this service:

```bash
$ kubectl create -f client-service-lb.yaml
service "client-load-balancer" created
```

To check that the service is running:

```bash
$ kubectl get svc
NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
client-load-balancer   LoadBalancer   10.98.247.33     <pending>     80:30481/TCP   7m
```

The External-IP is in a pending state because we are running locally. Running it in a cloud provider would give us an IP to access. In order to get an external IP to use locally, minikube has an API we can use:

```bash
$ minikube service client-load-balancer
Opening kubernetes service default/client-load-balancer in default browser...
```

This will open up the application in a browser window pointing to the services IP. After the Service receives the request, it will forward the call to one of the pods (which one doesn’t matter). This abstraction enables us to see and act with the numerous pods as one unit, using the Service as an entry point.
