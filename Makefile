include .env

init:
	docker compose build
	@make up
	@make db-create
	@make gen-certs

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

rebuild:
	@make down
	@make build
	@make up

reup:
	@make down
	@make up

ps:
	docker compose ps

server-sh:
	docker compose exec app /bin/bash

db-sh:
	docker compose exec db /bin/bash

cert-sh:
	docker compose run --rm cert /bin/bash

cargo-build:
	docker compose exec app cargo build

cargo-run:
	docker compose exec app cargo run --bin server

cargo-add:
	docker compose exec app cargo add ${name}

cargo-fmt:
	docker compose exec app cargo fmt

cargo-clippy:
	docker compose exec app cargo clippy

cargo-lint:
	@make cargo-fmt
	@make cargo-clippy

cargo-update:
	docker compose exec app cargo update

gen-openapi:
	docker run --rm -v "${PWD}:/work" openapitools/openapi-generator-cli generate \
    -i work/openapi.yaml \
    -g rust-axum \
    -o work/server/openapigen

seeder:
	docker compose exec app /bin/bash -c './db/scripts/seeder db/seeder'

db-create:
	docker compose exec app sqlx database create

db-drop:
	docker compose exec app sqlx database drop

db-reset:
	docker compose exec app sqlx database reset --source db/migrations

migrate-create:
	docker compose exec app sqlx migrate add ${name} -r --source db/migrations

migrate:
	docker compose exec app sqlx migrate run --source db/migrations

migrate-info:
	docker compose exec app sqlx migrate info --source db/migrations

migrate-down-latest:
	docker compose exec app sqlx migrate revert --source db/migrations

migrate-down-all:
	docker compose exec app sqlx migrate revert --target-version 0 --source db/migrations

migrate-down-specify:
	docker compose exec app sqlx migrate revert --target-version ${version} --source db/migrations

gen-entity:
	docker compose exec app sea-orm-cli generate entity -o src/rdb/gen --with-copy-enums --lib --expanded-format
