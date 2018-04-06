#!/bin/bash

# Run the script from the project's root directory

mkdir -p keys
ssh-keygen -q -t rsa -f keys/aws -N ""
chmod 600 keys/aws

aws ec2 import-key-pair \
--key-name "vpc-stack" \
--public-key-material file://$PWD/keys/aws.pub \
--region eu-central-1