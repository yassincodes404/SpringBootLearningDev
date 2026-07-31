# Spring Boot Cloud Platform

> A production-ready, containerized Spring Boot SaaS application built as a learning journey toward Senior Cloud & Backend Engineering.

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Backend** | Java 21, Spring Boot 3.3, Maven |
| **Database** | PostgreSQL 16, Flyway (migrations) |
| **Frontend** | React 18, Vite 5, TypeScript |
| **Reverse Proxy** | NGINX |
| **CI/CD** | GitHub Actions, GitHub Container Registry (`ghcr.io`) |
| **Cloud Hosting** | Microsoft Azure VM (Ubuntu 24.04 LTS) |

---

## Quick Start

### 1. Prerequisites

- Java 21+
- Node.js 20+
- Docker Desktop

### 2. Run the Development Environment

**Windows:**
```cmd
scripts\run_dev.bat
```

**Linux / macOS / Git Bash:**
```bash
make dev
# or: bash scripts/run_dev.sh
```

The script automatically verifies prerequisites, boots PostgreSQL & pgAdmin in Docker, starts the Spring Boot backend and Vite frontend, and provides live logs.

### 3. Service Access Links

- **Frontend (Vite UI)**: [http://localhost:5173](http://localhost:5173)
- **Backend API**: [http://localhost:8080](http://localhost:8080)
- **Actuator Health**: [http://localhost:8080/actuator/health](http://localhost:8080/actuator/health)
- **OpenAPI / Swagger UI**: [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)
- **pgAdmin**: [http://localhost:5050](http://localhost:5050) *(Email: `admin@admin.com` \| Password: `admin`)*

---

## Project Structure

```
.
├── backend/               # Spring Boot 3.3 Application (Java 21)
├── frontend/              # React 18 + Vite + TypeScript Dashboard
├── infrastructure/        # Docker Compose (dev & prod), NGINX, Postgres init & roadmap
│   ├── compose/           # dev.yml & prod.yml stack definitions
│   ├── nginx/             # Reverse proxy config
│   └── README.md          # Future infrastructure roadmap & seeds
├── scripts/               # Smart dev launchers & DB management scripts
├── docs/                  # Architecture, API, and Deployment documentation
└── .github/               # Automated CI & CD GitHub Actions workflows
```

For detailed guides, refer to [docs/architecture.md](docs/architecture.md), [docs/deployment.md](docs/deployment.md), and [docs/infrastructure_manual.md](docs/infrastructure_manual.md).

---

## Deployment & CI/CD Pipeline

Pushing to `main` triggers a two-job GitHub Actions pipeline:
1. **CI Job**: Builds Java code, runs unit and integration tests against a PostgreSQL test container, and type-checks the React frontend.
2. **CD Job**: Builds production Docker images, tags them with commit SHA and `latest`, pushes to `ghcr.io`, and deploys live to the Azure Virtual Machine over SSH via Docker Compose.

---

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.
