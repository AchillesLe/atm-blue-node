.PHONY: up
up:
	docker compose up -d

.PHONY: build-ecr-and-task
build-ecr-and-task:
	@echo "Building and pushing ECR image..."
	@NEW_TAG=$$(./aws/1.build-and-push.sh --env=dev | tail -1); \
	echo "Using image tag: $$NEW_TAG"; \
	./aws/2.build-and-push-task-definition.sh --env=dev --image-tag=$$NEW_TAG