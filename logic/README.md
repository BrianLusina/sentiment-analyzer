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

-> `localhost:5050/analyse/sentiment` or

-> `<docker-machine ip>:5050/analyse/sentiment` Docker-machine ip has to be used if your OS doesn't provide native docker support.

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
