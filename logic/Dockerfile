FROM python:3.6.1-onbuild

LABEL maintainer="lusinabrian@gmail.com"

# We copy just the requirements.txt first to leverage Docker cache
COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip install -r requirements.txt

COPY . /app

WORKDIR /app

RUN python -m textblob.download_corpora

EXPOSE 5000

CMD ["python", "sentiment_analysis.py"]