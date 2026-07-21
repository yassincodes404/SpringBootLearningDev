-- ==============================================================================
-- PostgreSQL Initialization Script
-- ==============================================================================
-- This script runs when the PostgreSQL container is created for the first time.
-- Use it for any setup that Flyway doesn't handle (extensions, roles, etc.).
-- ==============================================================================

-- Create the application database (if not already created via POSTGRES_DB env var)
-- CREATE DATABASE myproject;

-- Create a read-only user for reporting (optional)
-- CREATE USER readonly_user WITH PASSWORD 'readonly_password';
-- GRANT CONNECT ON DATABASE myproject TO readonly_user;
-- GRANT USAGE ON SCHEMA public TO readonly_user;
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;

-- Enable useful extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- Trigram similarity for fuzzy search
