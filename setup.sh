#!/usr/bin/env bash
set -e
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$ROOT_DIR/app"

echo "==> Building and starting Docker containers..."
docker compose up -d --build

echo "==> Waiting for DB to accept connections..."
# simple wait loop (attempt to run migrate until db is ready)
tries=0
until docker compose exec -T db mysql -u${MYSQL_USER:-todo_user} -p${MYSQL_PASSWORD:-todo_pw} -e "SELECT 1;" ${MYSQL_DATABASE:-tododb} >/dev/null 2>&1 || [ $tries -ge 30 ]; do
  tries=$((tries+1))
  echo " waiting... ($tries)"
  sleep 2
done

echo "==> Running Laravel migrations & seeding (inside app container)..."
docker compose exec -T app bash -lc "cd /var/www/html && php artisan migrate --force || true"

echo "==> Fixing Laravel storage permissions..."
docker compose exec -T app bash -lc "cd /var/www/html && \
    chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache"


echo "Done. App should be available at http://localhost:8080"
