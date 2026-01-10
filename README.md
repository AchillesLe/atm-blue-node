# ATM Blue Node API

## Setup environment aws

```bash
aws ssm put-parameter \
  --name "/atm-blue-node/dev/DB_HOST" \
  --value "DB_HOST" \
  --type "String" \
  --overwrite &> /dev/null

aws ssm put-parameter \
  --name "/atm-blue-node/dev/DB_NAME" \
  --value "DB_NAME" \
  --type "String" \
  --overwrite &> /dev/null

aws ssm put-parameter \
  --name "/atm-blue-node/dev/DB_USER" \
  --value "DB_USER" \
  --type "String" \
  --overwrite &> /dev/null

aws ssm put-parameter \
  --name "/atm-blue-node/dev/DB_PASSWORD" \
  --value "DB_PASSWORD" \
  --type "String" \
  --overwrite &> /dev/null

aws ssm put-parameter \
  --name "/atm-blue-node/dev/DB_PORT" \
  --value "3306" \
  --type "String" \
  --overwrite &> /dev/null
```

### Run

- Read Makefile
