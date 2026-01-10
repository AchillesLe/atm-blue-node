.PHONY: up
up:
	docker compose up -d --build

.PHONY: build-ecr-and-task-dev
build-ecr-and-task-dev:
	@echo "Building and pushing ECR image..."
	@NEW_TAG=$$(./aws/1.build-and-push.sh --env=dev | tail -1); \
	echo "Using image tag: $$NEW_TAG"; \
	./aws/2.build-and-push-task-definition.sh --env=dev --image-tag=$$NEW_TAG