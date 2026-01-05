#!/bin/bash

REGION="ap-southeast-1"
ACCOUNT_ID=""
AWS_PROFILE=""
ENV="dev"

for ARG in "$@"; do
  case $ARG in
    --env=*)
      ENV="${ARG#*=}"
      shift
      ;;
    --profile=*)
      AWS_PROFILE="${ARG#*=}"
      shift
      ;;
    *)
      ;;
  esac
done

if [ "$ENV" != "dev" ] && [ "$ENV" != "prod" ]; then
  echo "Invalid environment. Use 'dev' or 'prod'."
  exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile "$AWS_PROFILE" --query Account --output text)
if [ -n "$AWS_ACCOUNT_ID" ]; then
  ACCOUNT_ID="$AWS_ACCOUNT_ID"
fi

if [ -z "$ACCOUNT_ID" ]; then
  echo "Failed to get AWS account ID."
  exit 1
fi

ECR_REPO="atm-blue-node"
IMAGE_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO"
IMAGE_TAG="latest"

echo "Building for linux/amd64..."
docker build --platform linux/amd64 -t $ECR_REPO .

echo "Pushing to ECR..."
docker tag atm-blue-node:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG

docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG

echo "Done: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG"
