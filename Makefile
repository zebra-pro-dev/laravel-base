build:
	@docker compose build
build-nc:
	@docker compose build --no-cache
push:
	@docker compose push
