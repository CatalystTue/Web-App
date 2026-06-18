# Stage 1: Build Flutter web app (runs on modern Linux inside the container)
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Cache dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# Stage 2: Serve static files with nginx (optional — use profile "web" below)
FROM nginx:alpine AS web

COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
