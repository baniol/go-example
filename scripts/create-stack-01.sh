#!/bin/bash

aws cloudformation update-stack --stack-name vpc-sample-01 --template-body file://cloudformation/02_stack_ec2.yaml --parameters ParameterKey=KeyName,ParameterValue=vpc-stack ParameterKey=InstanceType,ParameterValue=t2.micro --region eu-central-1