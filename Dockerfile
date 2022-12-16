FROM python:3.10-slim

#LABEL maintainer="Chris von Csefalvay <chris@chrisvoncsefalvay.com>"

RUN apt-get update
#RUN apt-get install -y python3 python3-dev python3-pip

COPY ./app/requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

COPY ./app /app
WORKDIR /app

EXPOSE 80

CMD gunicorn --bind 0.0.0.0:80 wsgi