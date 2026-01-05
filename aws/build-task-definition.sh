# !/bin/bash

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
  echo "Invalid environment specified. Use 'dev' or 'prod'."
  exit 1
fi
echo "Building task definition for environment: $ENV";

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile "$AWS_PROFILE" --query Account --output text)
if [ -n "$AWS_ACCOUNT_ID" ]; then
  ACCOUNT_ID="$AWS_ACCOUNT_ID"
fi

if [ -z "$ACCOUNT_ID" ]; then
  echo "Failed to get AWS account ID. Please configure your AWS CLI."
  exit 1
fi
echo "Using AWS profile: $AWS_PROFILE";

# load template file
TEMPLATE_FILE="aws/task-definition-template.json"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Template file $TEMPLATE_FILE not found!"
  exit 1
fi

FAMILY_NAME="atm-blue-node-task-definition-$ENV"
EXECUTION_ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/ecsTaskExecutionRole-atm-blue-node"
TASK_ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/ecsTaskRole-atm-blue-node"
IMAGE_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/atm-blue-node"
AWSLOGS_GROUP="/ecs/atm-blue-node-$ENV"
AWSLOGS_REGION="$REGION"
AWSLOGS_STREAM_PREFIX="ecs"
OUT_PUT_FILE="atm-blue-node-task-definition-$ENV.json"

TASK_DEFINITION=$(sed \
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
  "$TEMPLATE_FILE")
echo "$TASK_DEFINITION" > "$OUT_PUT_FILE"

# pushing new task definition file
aws ecs register-task-definition --cli-input-json file://"$OUT_PUT_FILE" --profile "$AWS_PROFILE" &>/dev/null

rm "$OUT_PUT_FILE" &>/dev/null
echo "Task definition written to $OUT_PUT_FILE"