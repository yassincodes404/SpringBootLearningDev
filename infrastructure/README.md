# Infrastructure

This directory contains configuration and orchestration files for the project's infrastructure.

## Active Components

| Directory | Purpose | Used By |
|:---|:---|:---|
| `compose/` | Docker Compose files for dev and production environments | `dev.yml`, `prod.yml` |
| `nginx/` | NGINX reverse proxy config for production | `prod.yml` |
| `postgres/` | PostgreSQL init scripts (extensions, schemas) | Both `dev.yml` and `prod.yml` |

## Future Tools Roadmap

When you need to add a new infrastructure service, follow these steps:

### Redis (Caching)

When your app needs caching or session storage:

1. Create `infrastructure/redis/redis.conf`
2. Add a Redis service to `infrastructure/compose/dev.yml` (uncomment the seed below)
3. Add `spring-boot-starter-data-redis` to `backend/pom.xml`
4. Configure `REDIS_HOST`, `REDIS_PORT` in `.env.local`

```yaml
# Redis seed for dev.yml:
  redis:
    image: redis:7-alpine
    container_name: myproject-redis
    restart: unless-stopped
    ports:
      - "${REDIS_PORT:-6379}:6379"
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### MailHog (Email Testing)

When your app sends emails and you need to test them locally:

1. Add MailHog service to `dev.yml`
2. Configure Spring Mail to point to `localhost:1025`
3. View emails at `http://localhost:8025`

```yaml
# MailHog seed for dev.yml:
  mailhog:
    image: mailhog/mailhog:latest
    container_name: myproject-mailhog
    restart: unless-stopped
    ports:
      - "1025:1025"   # SMTP
      - "8025:8025"   # Web UI
```

### MinIO (Object Storage / S3-Compatible)

When your app needs file uploads or object storage:

1. Create `infrastructure/minio/` directory
2. Add MinIO service to `dev.yml`
3. Add `io.minio:minio` dependency to `backend/pom.xml`
4. Configure `MINIO_*` env vars in `.env.local`

```yaml
# MinIO seed for dev.yml:
  minio:
    image: minio/minio:latest
    container_name: myproject-minio
    restart: unless-stopped
    ports:
      - "9000:9000"   # API
      - "9001:9001"   # Console
    environment:
      MINIO_ROOT_USER: ${MINIO_ACCESS_KEY:-minioadmin}
      MINIO_ROOT_PASSWORD: ${MINIO_SECRET_KEY:-minioadmin}
    volumes:
      - minio-data:/data
    command: server /data --console-address ":9001"
```

### Keycloak (Authentication / OAuth2)

When your app needs SSO, OAuth2, or OpenID Connect:

```yaml
# Keycloak seed for dev.yml:
  keycloak:
    image: quay.io/keycloak/keycloak:latest
    container_name: myproject-keycloak
    restart: unless-stopped
    ports:
      - "8180:8080"
    environment:
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin
    command: start-dev
```

### Monitoring Stack (Prometheus + Grafana)

When you need application metrics and dashboards:

```yaml
# Prometheus seed:
  prometheus:
    image: prom/prometheus:latest
    container_name: myproject-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ../prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro

# Grafana seed:
  grafana:
    image: grafana/grafana:latest
    container_name: myproject-grafana
    ports:
      - "3001:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
```

### RabbitMQ (Message Queue)

When your app needs async processing or event-driven architecture:

```yaml
# RabbitMQ seed for dev.yml:
  rabbitmq:
    image: rabbitmq:3-management-alpine
    container_name: myproject-rabbitmq
    restart: unless-stopped
    ports:
      - "5672:5672"   # AMQP
      - "15672:15672" # Management UI
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER:-guest}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASS:-guest}
```
