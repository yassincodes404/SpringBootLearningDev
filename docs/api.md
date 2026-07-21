# API Documentation

## Base URL

```
http://localhost:8080/api/v1
```

## Interactive Documentation

When the backend is running, visit:

- **Swagger UI**: [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)
- **OpenAPI JSON**: [http://localhost:8080/v3/api-docs](http://localhost:8080/v3/api-docs)

## Endpoints

### Users

| Method | Path             | Description       | Auth Required |
|--------|------------------|--------------------|---------------|
| GET    | `/api/v1/users`      | List all users     | No (for now)  |
| GET    | `/api/v1/users/{id}` | Get user by ID     | No (for now)  |
| POST   | `/api/v1/users`      | Create a new user  | No (for now)  |

### Auth (coming soon)

| Method | Path                   | Description        |
|--------|------------------------|--------------------|
| POST   | `/api/v1/auth/register` | Register a user    |
| POST   | `/api/v1/auth/login`    | Login (get JWT)    |
| POST   | `/api/v1/auth/refresh`  | Refresh JWT token  |

## Error Responses

All errors return a consistent format:

```json
{
  "timestamp": "2026-01-01T00:00:00",
  "status": 404,
  "error": "Not Found",
  "message": "User not found with id: '...'",
  "path": "/api/v1/users/..."
}
```
