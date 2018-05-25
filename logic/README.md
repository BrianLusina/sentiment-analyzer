# Logic for Sentiment Analysis

Logic handling actual sentiment analysis

## Running the application locally

Before running the application, create a virtual environment to install required dependencies.

```bash
virtualenv venv -p python3
```

> creates a virtual environment based off of python 3

Ensure you have installed all the requirements.

```bash
pip install -r requirements.txt
```

> Installs the requirements to the venv directory

If using [pipenv](https://github.com/pypa/pipenv)

```bash
pipenv install
```

> This will setup the venv and install dependencies from the [Pipfile.lock](./Pipfile.lock)

Run the application with

``` bash
python -m textblob.download_corpora
python sentiment_analysis.py
```

> Runs the application on http:0.0.0.0:5000

Now you can send POST requests to http:0.0.0.0:5000/analyse/sentiment with body:

```bash
{
    "sentence": "I adore pets!"
}
```

## Building the Docker Container

``` bash
docker build -f Dockerfile -t $DOCKER_USER_ID/sentiment-analysis-logic .
```

## Running the Docker Container

``` bash
docker run -d -p 5050:5000 $DOCKER_USER_ID/sentiment-analysis-logic
```

The app is listening by default on port 5000. The 5050 port of the host machine is mapped to the port 5000 of the container.

-p 5050:5000 i.e.

```-p <hostPort>:<containerPort>```

### Verifying that it works

Execute a POST on endpoint

`localhost:5050/analyse/sentiment` or

`<docker-machine ip>:5050/analyse/sentiment` Docker-machine ip has to be used if your OS doesn't provide native docker support.

Request body:

``` json

{
    "sentence": "I hate you!"
}

```

## Pushing to Docker Hub

``` bash

docker push $DOCKER_USER_ID/sentiment-analysis-logic

```

## Using Kubernetes

The kubernetes setup instructions for the logic are in the yaml files provided. The [logic-service](./logic-service.yaml).

```yaml

apiVersion: v1
kind: Service
metadata:
        name: logic-service
spec:
        ports:
                - port: 80
                  protocol: TCP
                  targetPort: 5000

        selector:
                app: logic

```

These instructions define how to build the Client Pod (Smallest compute unit that can run multiple containers).

1. __kind__: specifies the kind of the Kubernetes Resource that we want to create. In our case, a service.
2. __name__: (in the metadata block) defines the name for the resource. We named it logic-service. Feel free to give it another name.
3. __spec__ is the object that defines the desired state for the resource. The most important property of a Service Spec is the selector.
4. __app__: (in the selectors block) is the unique name for the pod the service will direct traffic to.

You can create the service with:

```bash

$ kubectl apply -f logic-service.yaml --record
service "logic" created

```

The service will act as an entry point to the Python Pods running. The reason for using a service is that our Kotlin application (running in WebApp) depends on the sentiment analysis done by the Python Application. But now, in contrast when we were running everything locally, we don’t have 1 python application listening to one port, we have 3 pods and if needed we could have countless pods running and listening for requests. “The Kubernetes Service resource acts as the entry point to a set of pods that provide the same functional service”, this means that we can use the Service Logic as the entry point to all the Logic pods.

The [logic-deployment](./logic-deployment.yaml) defines the deployment for the logic service:

```yaml

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
        name: logic-deployment
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
                                app: logic
                spec:
                        containers:
                                - image: thelusina/sentiment-analysis-logic
                                  imagePullPolicy: Always
                                  name: logic
                                  ports:
                                          - containerPort: 5000

```

1. __Kind__: A deployment.
2. __Replicas__ is a property of the deployments Spec object that defines how many pods we want to run. So only 2.
3. __Type__ specifies the strategy used in this deployment when moving from the current version to the next. The strategy RollingUpdate ensures Zero Downtime deployments.
4. __MaxUnavailable__ is a property of the RollingUpdate object that specifies the maximum unavailable pods allowed (compared to the desired state) when doing a rolling update. For our deployment which has 2 replicas this means that after terminating one Pod, we would still have one pod running, this way keeping our application accessible.
5. __MaxSurge__ is another property of the RollingUpdate object that defines the maximum amount of pods added to a deployment(compared to the desired state). For our deployment, this means that when moving to a new version we can add one pod, which adds up to 3 pods at the same time.
6. __Template__: specifies the pod template that the Deployment will use to create new pods
7. __app__: `logic` the label to use for the pods created by this template.
8. __ImagePullPolicy__ when set to Always, it will pull the container images on each redeployment.

You can run the deployment with:

```bash

$ kubectl apply -f logic-deployment.yaml
deployment.extensions "logic-deployment" created

```

You can check that it is running with:

```bash

$ kubectl get pods
NAME                                    READY     STATUS    RESTARTS   AGE
logic-deployment-cf8ff4494-j4wdd        1/1       Running   1          1m
logic-deployment-cf8ff4494-tcb9j        1/1       Running   1          1m

```
