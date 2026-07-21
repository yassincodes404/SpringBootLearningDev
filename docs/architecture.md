# Architecture

## Overview

This application follows a **monorepo structure** with clear separation between backend, frontend, and infrastructure concerns.

## High-Level Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Frontend   │────▶│    NGINX     │────▶│   Backend   │
│  (React/Vite)│     │ (Reverse    │     │ (Spring Boot)│
└─────────────┘     │  Proxy)     │     └──────┬──────┘
                     └─────────────┘            │
                                                ▼
                                    ┌─────────────────────┐
                                    │    PostgreSQL        │
                                    │    Redis (cache)     │
                                    └─────────────────────┘
```

## Backend Architecture

The backend uses a **feature-based package structure**:

```
com.example.project/
├── common/          # Shared utilities and constants
├── config/          # Application-wide configuration
├── security/        # Authentication & authorization
├── exception/       # Global exception handling
├── user/            # User feature module
│   ├── controller/
│   ├── service/
│   ├── repository/
│   ├── entity/
│   ├── dto/
│   └── mapper/
├── product/         # Product feature module
├── order/           # Order feature module
├── auth/            # Auth feature module
└── notification/    # Notification feature module
```

Each feature module is self-contained with its own controller → service → repository layers.

## Key Design Decisions

See [decisions/](decisions/) for Architecture Decision Records (ADRs).
