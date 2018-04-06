#!/bin/bash

REGION=eu-central-1
ACCOUNT=500606609328
REPOSITORY=go-example
IMAGE=go-example

LOGINCOMMAND=$(aws ecr get-login --no-include-email --region ${REGION} --profile ${ACCOUNT})
$LOGINCOMMAND

docker build -t ${REPOSITORY} .
docker tag ${REPOSITORY}:latest ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${IMAGE}:latest
docker push ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${IMAGE}:latest