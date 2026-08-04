#!/bin/bash

read -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -s -p "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo
read -p "AWS Region [us-east-1]: " AWS_REGION

AWS_REGION=${AWS_REGION:-us-east-1}

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$AWS_REGION

echo "Verifying credentials..."

aws sts get-caller-identity

if [ $? -eq 0 ]; then
    echo "AWS authentication successful"
else
    echo "AWS authentication failed"
    exit 1
fi