.PHONY: build
build:
	docker compose build --no-cache

.PHONY: up
up:
	docker compose up -d --build

.PHONY: down
down:
	docker compose down

.PHONY: migrate
migrate:
	docker compose exec app sh -c  "npm run migrate"

.PHONY: build-ecr-and-task-dev
build-ecr-and-task-dev:
	@echo "Building and pushing ECR image..."
	@NEW_TAG=$$(./aws/1.build-and-push.sh --env=dev | tail -1); \
	echo "Using image tag: $$NEW_TAG"; \
	./aws/2.build-and-push-task-definition.sh --env=dev --image-tag=$$NEW_TAG

.PHONY: build-ecr-and-task-prod
build-ecr-and-task-prod:
	@echo "Building and pushing ECR image..."
	@NEW_TAG=$$(./aws/1.build-and-push.sh --env=prod | tail -1); \
	echo "Using image tag: $$NEW_TAG"; \
	./aws/2.build-and-push-task-definition.sh --env=prod --image-tag=$$NEW_TAG