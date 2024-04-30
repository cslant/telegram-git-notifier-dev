#!/bin/bash

set -a
source .env
set +a

PROJECT_DIR=$(pwd)

sync_package() {
    PACKAGE_DIR="$PROJECT_DIR/packages/$1"

    cd "$PACKAGE_DIR" || exit
    echo "🔄 Syncing $1"

    if [ -z "$(ls -A "$PACKAGE_DIR")" ]; then
        echo "  ∟ Cloning $1 repository..."
        git clone git@github.com:"$USERNAME_REPO"/"$1".git .
        composer install
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
    cp .env.example .env
fi

if [ -d vendor ]; then
    echo "  ∟ vendor directory exists"
else
    echo "  ∟ Running composer install"
    composer install
    php artisan key:generate
fi

echo ''
echo "✅ Done installing packages"
