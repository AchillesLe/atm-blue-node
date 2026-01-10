#!/bin/bash

if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install jq first."
  echo "On macOS: brew install jq"
  echo "On Ubuntu/Debian: sudo apt-get install jq"
  exit 1
fi

REGION="ap-southeast-1"
ACCOUNT_ID=""
AWS_PROFILE=""
ENV="dev"
IMAGE_TAG=1

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
    --image-tag=*)
      IMAGE_TAG="${ARG#*=}"
      shift
      ;;
    *)
      ;;
  esac
done

if [ "$ENV" != "dev" ] && [ "$ENV" != "prod" ]; then
  echo "Invalid environment specified. Use 'dev' or 'prod'."
  exit 1
fi
echo "Building task definition for environment: $ENV";
echo "Building image tag $IMAGE_TAG";

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile "$AWS_PROFILE" --query Account --output text)
if [ -n "$AWS_ACCOUNT_ID" ]; then
  ACCOUNT_ID="$AWS_ACCOUNT_ID"
fi

if [ -z "$ACCOUNT_ID" ]; then
  echo "Failed to get AWS account ID. Please configure your AWS CLI."
  exit 1
fi
echo "Using AWS profile: $AWS_PROFILE";

TEMPLATE_FILE="aws/task-definition-template.json"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Template file $TEMPLATE_FILE not found!"
  exit 1
fi

PROJECT_NAME="atm-blue-node"
FAMILY_NAME="$PROJECT_NAME-task-definition-$ENV"
EXECUTION_ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/ecsTaskExecutionRole-$PROJECT_NAME"
TASK_ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/ecsTaskRole-$PROJECT_NAME"
IMAGE_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT_NAME:$IMAGE_TAG"
AWSLOGS_GROUP="/ecs/$PROJECT_NAME-$ENV"
AWSLOGS_REGION="$REGION"
AWSLOGS_STREAM_PREFIX="ecs"
OUT_PUT_FILE="$PROJECT_NAME-task-definition-$ENV.json"

ENV_FILE="env/$ENV.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "Environment file $ENV_FILE not found!"
  exit 1
fi


ENVIRONMENT_JSON="["

while IFS= read -r line || [ -n "$line" ]; do
  [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

  key="${line%%=*}"
  value="${line#*=}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"

  ENVIRONMENT_JSON+='{"name":"'"$key"'","value":"'"$value"'"},'
done < "$ENV_FILE"

ENVIRONMENT_JSON="${ENVIRONMENT_JSON%,}]"

TASK_DEFINITION=$(sed \
  -e "s|\${PROJECT_NAME}|$PROJECT_NAME|g" \
  -e "s|\${ENV}|$ENV|g" \
  -e "s|\${ACCOUNT_ID}|$ACCOUNT_ID|g" \
  -e "s|\${REGION}|$REGION|g" \
  -e "s|\${FAMILY_NAME}|$FAMILY_NAME|g" \
  -e "s|\${EXECUTION_ROLE_ARN}|$EXECUTION_ROLE_ARN|g" \
  -e "s|\${TASK_ROLE_ARN}|$TASK_ROLE_ARN|g" \
  -e "s|\${IMAGE_URI}|$IMAGE_URI|g" \
  -e "s|\${AWSLOGS_GROUP}|$AWSLOGS_GROUP|g" \
  -e "s|\${AWSLOGS_REGION}|$AWSLOGS_REGION|g" \
  -e "s|\${AWSLOGS_STREAM_PREFIX}|$AWSLOGS_STREAM_PREFIX|g" \
  "$TEMPLATE_FILE" | jq --argjson env "$ENVIRONMENT_JSON" '.containerDefinitions[0].environment = $env')

echo "$TASK_DEFINITION" > "$OUT_PUT_FILE";

aws logs create-log-group --log-group-name "$AWSLOGS_GROUP" --region "$REGION" --profile "$AWS_PROFILE" 2>/dev/null
aws logs put-retention-policy --log-group-name "$AWSLOGS_GROUP" --retention-in-days 7 --region "$REGION" --profile "$AWS_PROFILE" 2>/dev/null

aws ecs register-task-definition --cli-input-json file://"$OUT_PUT_FILE" --profile "$AWS_PROFILE" &>/dev/null

rm "$OUT_PUT_FILE" &>/dev/null
echo "Done building and registering task definition."