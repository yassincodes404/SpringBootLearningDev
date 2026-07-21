# My Project

> A production-ready Spring Boot SaaS application built as a learning journey toward Senior Backend Engineering.

---

## Tech Stack

| Layer          | Technology                              |
|----------------|-----------------------------------------|
| **Backend**    | Java 21, Spring Boot 3.3, Maven        |
| **Database**   | PostgreSQL, Flyway (migrations)         |
| **Cache**      | Redis                                   |
| **Frontend**   | React, Vite, TypeScript                 |
| **Infra**      | Docker, NGINX, GitHub Actions           |
| **Cloud**      | Azure (App Service, ACR, Blob, etc.)    |
| **Monitoring** | Grafana, Prometheus, Loki, Tempo        |

---

## Prerequisites

- Java 21+
- Docker & Docker Compose
- Node.js 20+ (for frontend)
- Maven 3.9+ (or use the included wrapper)

---

## Getting Started

### 1. Clone & configure

```bash
git clone <repo-url>
cd my-project
cp .env.example .env
# Edit .env with your local values
```

### 2. Start dev infrastructure

```bash
make dev-up
# or
docker compose -f docker-compose.dev.yml up -d
```

### 3. Run the backend

```bash
cd backend
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

### 4. Run the frontend

```bash
cd frontend
npm install
npm run dev
```

---

## Project Structure

```
.
├── backend/           # Spring Boot application
├── frontend/          # React + Vite application
├── infrastructure/    # NGINX, Postgres, Redis, monitoring configs
├── docs/              # Architecture, API, deployment documentation
├── scripts/           # Dev & ops helper scripts
├── .github/           # CI/CD workflows & templates
└── .vscode/           # Editor configuration
```

See [docs/architecture.md](docs/architecture.md) for a deeper dive.

---

## Development Workflow

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make changes and write tests
3. Run checks: `make lint && make test`
4. Open a Pull Request against `develop`
5. CI runs automatically — merge after review

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
