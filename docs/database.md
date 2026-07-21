# Database

## Engine

**PostgreSQL 16** — running in Docker for development, Azure Database for PostgreSQL in production.

## Migrations

We use **Flyway** for database migrations. Migration files are located at:

```
backend/src/main/resources/db/migration/
```

### Naming Convention

```
V{version}__{description}.sql
```

Examples:
- `V1__init.sql` — Initial schema
- `V2__add_products_table.sql`
- `V3__add_orders_table.sql`

### Rules
- **Never** edit a migration that has already been applied
- **Never** manually modify production databases
- Always create a new migration file for schema changes
- Test migrations locally before pushing

## Schema

### users

| Column     | Type         | Nullable | Default          |
|------------|--------------|----------|------------------|
| id         | UUID         | No       | uuid_generate_v4 |
| email      | VARCHAR(255) | No       | -                |
| password   | VARCHAR(255) | No       | -                |
| first_name | VARCHAR(100) | Yes      | -                |
| last_name  | VARCHAR(100) | Yes      | -                |
| enabled    | BOOLEAN      | No       | true             |
| created_at | TIMESTAMP    | No       | NOW()            |
| updated_at | TIMESTAMP    | No       | NOW()            |

## Backup & Restore

```bash
make db-backup    # Creates a timestamped dump
make db-restore   # Restores from the latest dump
```
