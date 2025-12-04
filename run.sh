#!/usr/bin/env bash
set -e
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$ROOT_DIR/app"

echo "==> Creating Laravel app (if missing) in $APP_DIR ..."
if [ ! -d "$APP_DIR/vendor" ]; then
  if [ ! -d "$APP_DIR" ] || [ -z "$(ls -A $APP_DIR 2>/dev/null)" ]; then
    mkdir -p "$APP_DIR"
    echo " - running composer create-project laravel/laravel ."
    composer create-project laravel/laravel "$APP_DIR" --prefer-dist
  fi

  echo " - installing composer dependencies"
  (cd "$APP_DIR" && composer install --no-interaction)
else
  echo " - vendor exists, skipping composer create/install"
fi

# copy .env
if [ ! -f "$APP_DIR/.env" ]; then
  cp "$APP_DIR/.env.example" "$APP_DIR/.env"
  # minimal DB defaults (matches docker-compose)
  sed -i "s/DB_HOST=.*/DB_HOST=db/" "$APP_DIR/.env"
  sed -i "s/DB_DATABASE=.*/DB_DATABASE=${MYSQL_DATABASE:-tododb}/" "$APP_DIR/.env"
  sed -i "s/DB_USERNAME=.*/DB_USERNAME=${MYSQL_USER:-todo_user}/" "$APP_DIR/.env"
  sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${MYSQL_PASSWORD:-todo_pw}/" "$APP_DIR/.env"
fi

echo " - generating APP_KEY"
(cd "$APP_DIR" && php artisan key:generate)

echo " - require sanctum if not installed"
if ! grep -q "laravel/sanctum" "$APP_DIR/composer.json"; then
  (cd "$APP_DIR" && composer require laravel/sanctum "^4.0" --no-interaction)
fi

echo " - publishing sanctum migrations"
(cd "$APP_DIR" && php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider" --force || true)

echo "Done. You can now run './setup.sh' to dockerize and migrate."
