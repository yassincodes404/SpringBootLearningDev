# ==============================================================================
# Makefile — Common development commands
# ==============================================================================

.PHONY: help dev-up dev-down dev-logs build test test-unit test-integration \
        lint format run frontend-install frontend-dev frontend-build \
        prod-up prod-down db-backup db-restore clean

COMPOSE_DEV  = docker compose --env-file .env.local  -f infrastructure/compose/dev.yml
COMPOSE_PROD = docker compose --env-file .env.production -f infrastructure/compose/prod.yml

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --------------- Development Infrastructure ---------------

dev-up: ## Start development services (Phase 1: PostgreSQL + pgAdmin)
	$(COMPOSE_DEV) up -d

dev-down: ## Stop development services
	$(COMPOSE_DEV) down

dev-logs: ## Tail development service logs
	$(COMPOSE_DEV) logs -f

# --------------- Backend ---------------

build: ## Build the backend
	cd backend && ./mvnw clean package -DskipTests

test: ## Run all backend tests
	cd backend && ./mvnw test

test-unit: ## Run unit tests only
	cd backend && ./mvnw test -Dgroups=unit

test-integration: ## Run integration tests only
	cd backend && ./mvnw test -Dgroups=integration

lint: ## Run code formatting & style checks
	cd backend && ./mvnw spotless:check checkstyle:check

format: ## Auto-format code
	cd backend && ./mvnw spotless:apply

run: ## Run the backend locally (dev profile)
	cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# --------------- Frontend ---------------

frontend-install: ## Install frontend dependencies
	cd frontend && npm install

frontend-dev: ## Start frontend dev server
	cd frontend && npm run dev

frontend-build: ## Build frontend for production
	cd frontend && npm run build

# --------------- Docker (Production) ---------------

prod-up: ## Start production stack
	$(COMPOSE_PROD) up -d --build

prod-down: ## Stop production stack
	$(COMPOSE_PROD) down

# --------------- Database ---------------

db-backup: ## Backup the database
	bash scripts/backup-db.sh

db-restore: ## Restore the database
	bash scripts/restore-db.sh

# --------------- Cleanup ---------------

clean: ## Clean all build artifacts
	cd backend && ./mvnw clean
	cd frontend && rm -rf node_modules dist
