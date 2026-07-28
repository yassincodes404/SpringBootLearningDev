# ==============================================================================
# Frontend Production Dockerfile
# ==============================================================================
# Stage 1: Build the React app with Vite
# Stage 2: Serve with NGINX
# ==============================================================================

# ---- Build Stage ----
FROM node:22-alpine AS build

WORKDIR /app

# Copy package files first for layer caching
COPY package.json package-lock.json* ./

# Use npm ci if lock file exists, otherwise npm install
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

COPY . .
RUN npm run build

# ---- Runtime Stage ----
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
