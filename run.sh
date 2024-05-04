#!/bin/bash

set -a
source .env
set +a

PROJECT_DIR=$(pwd)
echo "🚀 Starting setup for $PROJECT_DIR"
echo ''

echo "🐳 Starting docker containers"
docker compose up -d
echo ''

sync_package() {
    PACKAGE_DIR="$PROJECT_DIR/packages/$1"

    cd "$PACKAGE_DIR" || exit
    echo "🔄 Syncing $1"

    if [ -z "$(ls -A "$PACKAGE_DIR")" ]; then
        echo "  ∟ Cloning $1 repository..."
        git clone git@github.com:"$USERNAME_REPO"/"$1".git .
        docker compose run --rm -w /var/www/html server composer install
    else
        echo "  ∟ Pulling $1 repository..."
        git pull
    fi

    echo "✅ Done syncing $1"
    echo ''
}

echo "📥 Installing packages"
echo ''

sync_package telegram-git-notifier
sync_package laravel-telegram-git-notifier

cd "$PROJECT_DIR" || exit

echo "🔄 Syncing main project"

if [ -f .env ]; then
    echo "  ∟ .env file exists"
else
    echo "  ∟ Creating .env file"
    docker compose run --rm -w /var/www/html server cp .env.example .env
fi

if [ -d vendor ]; then
    echo "  ∟ vendor directory exists"
    echo "  ∟ Running composer update"
    docker compose run --rm -w /var/www/html server composer update
else
    echo "  ∟ Running composer install"
    docker compose run --rm -w /var/www/html server composer install
    docker compose run --rm -w /var/www/html server php artisan key:generate
fi

echo ''
echo "✅ Done installing packages"
