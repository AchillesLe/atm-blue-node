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

echo "Login to ECR..."
aws ecr get-login-password --region $REGION \
| docker login \
  --username AWS \
  --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com


LATEST_TAG=$(aws ecr describe-images \
  --repository-name $ECR_REPO \
  --region $REGION \
  --query 'imageDetails[].imageTags[]' \
  --output text 2>/dev/null \
| tr '\t' '\n' \
| grep -E '^[0-9]+$' \
| sort -n \
| tail -1)

if [ -z "$LATEST_TAG" ]; then
  NEW_TAG=1
else
  NEW_TAG=$((LATEST_TAG + 1))
fi

FULL_IMAGE_TAG=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO:$NEW_TAG
echo "Building for linux/amd64..."
docker build --platform linux/amd64 -t $ECR_REPO:latest .

echo "Pushing to ECR..."
docker push $FULL_IMAGE_TAG

echo "Done: Image Tag"
echo $NEW_TAG