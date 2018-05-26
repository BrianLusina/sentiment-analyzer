# Sentiment Analysis App

[![Build Status](https://travis-ci.org/BrianLusina/sentiment-analyzer.svg?branch=master)](https://travis-ci.org/BrianLusina/sentiment-analyzer)

A micro-serviced sentiment analysis application with a [React](https://reactjs.org/) frontend, [Kotlin](https://kotlinlang.org/) webapp and [Flask/Python](http://flask.pocoo.org/) logic.

This simply analyses sentences from user and returns the sentiment analysis to the user.

## Running the application

### Running each application seperately

Each service can be run seperately i.e. the [logic](./logic), [webapp](./webapp) and [client](./client). Instructions
are outlined in the containing README files in each service.

#### Running the client

The client application is the front end of the application that allows a user to enter a sentence and get back the polarity of the sentiment (whether positive or negative).

Running the client application requires the installation of dependencies either using [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/en/). Ensure you have these package managers installed before continuing.

```bash
cd client
npm run install
# or if using yarn
yarn install
# afterwards, you can start up the client app
yarn start
```

This will start up the client application after installing all dependencies.

You can then create a production build with:

```bash
yarn build
```

And start up the production build with [serve](https://www.npmjs.com/package/serve) or [http-server](https://github.com/indexzero/http-server).

```bash
serve -s build
# if using http-server
http-server ./build
```

#### Running the webapp

This piece of the application communicates with the logic and sends data back to the client with the Polarity of the given sentence sent from the client application.

Running the webapp requires installation of [gradle](https://gradle.org/) which is the build tool used. Luckily the [gradle wrapper](./webapp/gradlew) will setup the installation of the dependencies needed for running the web app.

You will also need to install [java](https://java.com/en/download/) which can be done using [sdkman](http://sdkman.io/).

```bash
cd webapp
./gradlew run
```

This will run the web app application.

You can create a production build with:

```bash
./gradlew build
```

And run the application with:

```bash
java -server -Xms4g -Xmx4g -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+UseStringDeduplication -jar ./build/libs/webapp.jar
```

#### Running the logic

The logic handles the actual processing of the sentence and returning back the polarity which determines the sentiment.
This is done in Python using a minimal [Flask](http://flask.pocoo.org) server. Before running the application you will
need to install the dependencies in a virtual environment. To do this you can either use [virtualenv](https://virtualenv.pypa.io/en/stable/) to create a virtual environment or use [pipenv](https://github.com/pypa/pipenv).

Important, ensure you have [pip](https://pypi.org/project/pip/) installed.

```bash
cd logic
# this will set up a virtualenv based in Python 3.x
virtualenv -p python3 venv

# you can use Python 2
virtualenv venv

# or if using pipenv
# creates a venv in your home directory and installs the dependencies from the Pipfile
# read more https://docs.pipenv.org/
pipenv shell

# Afterwards you will need to download nltk data, this is needed by the TextBlob dependency
python -m textblob.download_corpora

# aftwerwards, you can run the logic application
python sentiment_analysis.py
```

### Running the application with Docker

Running the application with docker is simple. Simply use [docker-compose](https://docs.docker.com/compose/) to build up the containers for each piece and start it up. All instructions are available in the [docker-compose](./docker-compose.yml) file.

```bash
docker-compose build
```

Running this command in the root of the project will build up the containers for each service.

```bash
docker-compose up
```

Will start up the docker network for the sentiment analysis application.

### Running the application with Kubenetes (Minikube)

Running the application in kubernetes locally will require you to download [minikube](https://github.com/kubernetes/minikube) and download [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

Afterwards you should be able to start up minikube:

```bash
minikube start
```

> This will setup post-installation requirements.

Then start up the individual pods of the application with kubectl:

```bash
kubectl apply -f client/client-service-lb.yaml
kubectl apply -f client/client-pod.yaml
kubectl apply -f client/client-deployment.yaml
kubectl apply -f webapp/webapp-service.yaml
kubectl apply -f webapp/webapp-deployment.yaml
kubectl apply -f webapp/logic-deployment.yaml
kubectl apply -f webapp/logic-service.yaml
```

> These start up the deployment, services and pods for the micro services.

You can monitor with:

``` bash
kubectl get pods --watch
```

Instructions for each are setup in the Readme(s) in each service.

[![forthebadge](https://forthebadge.com/images/badges/made-with-python.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/uses-js.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/built-with-love.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/as-seen-on-tv.svg)](https://forthebadge.com)
