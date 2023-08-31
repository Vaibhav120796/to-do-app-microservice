#!/bin/bash
IMAGE="registry.vedlogic.local:5000/todo:v1"
CONTAINER="lab01_todo"
docker run -d -p 6000:5000 \
  --name=${CONTAINER} \
  -v $PWD:/app ${IMAGE}