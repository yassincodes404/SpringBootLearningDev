# Project Roadmap & Progress

## Phase 1 — Foundation & Core Infrastructure
- [x] Monorepo skeleton & directory structure
- [x] Spring Boot 3.3 + Java 21 setup
- [x] PostgreSQL 16 database integration
- [x] Docker Compose development environment (`dev.yml`)
- [x] Automated dev launchers (`scripts/run_dev.bat` & `scripts/run_dev.sh`)
- [x] GitHub Actions CI & CD pipeline (`.github/workflows/ci.yml`)
- [x] Automated Azure VM deployment over SSH & GHCR

## Phase 2 — Quality & Frontend Dashboard
- [x] React 18 + Vite 5 + TypeScript frontend integration
- [x] Interactive Cloud Platform Dashboard UI (System health, API tester, Architecture map)
- [x] Spring Boot Actuator health & metrics endpoints
- [x] OpenAPI / Swagger documentation (`/swagger-ui.html`)
- [ ] Flyway database migrations (In Progress)
- [ ] Spotless & Checkstyle code formatting rules

## Phase 3 — Security & Production Hardening
- [x] NGINX reverse proxy configuration
- [x] Multi-stage production Dockerfiles (JRE 21 Alpine & NGINX)
- [ ] JWT authentication & refresh tokens
- [ ] Role-based access control (RBAC)

## Phase 4 — Future Services Roadmap (Seeds ready in `infrastructure/README.md`)
- [ ] Redis caching & session management
- [ ] MinIO / Azure Blob Storage for file uploads
- [ ] MailHog / SMTP email notification integration
- [ ] Async message queue (RabbitMQ)

## Phase 5 — Advanced Observability
- [ ] Prometheus metrics scraping
- [ ] Grafana monitoring dashboards
- [ ] Loki log aggregation
- [ ] Tempo distributed tracing
