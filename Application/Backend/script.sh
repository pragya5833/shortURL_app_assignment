#!/bin/bash
# Variables
REGION="us-east-1"
ACCOUNT_ID="848417356303"
REPOSITORY_NAME="shorturl"
IMAGE_VERSION="1.0.0"

# Login to AWS ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build the Docker image
docker build -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest .

# Tag the image with a version
docker tag $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_VERSION

# Push the images
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_VERSION

# kubectl create secret docker-registry ecr-secret \
#   --docker-server=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com \
#   --docker-username=AWS \
#   --docker-password=$(aws ecr get-login-password) \
#   --namespace=shorturl


kubectl create secret docker-registry ecr-secret \
  --docker-server=848417356303.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=shorturl

kubectl create secret docker-registry ecr-secret \
  --docker-server=848417356303.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=ingress-nginx

"nginx" = "848417356303.dkr.ecr.us-east-1.amazonaws.com/nginx"
  "shorturl" = "848417356303.dkr.ecr.us-east-1.amazonaws.com/shorturl"