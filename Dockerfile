# --- STAGE 1: Build Frontend (Node.js) ---
FROM node:20 as frontend_builder

WORKDIR /app

# Copy file package
COPY package*.json vite.config.ts tsconfig.json ./

# Install dependensi JS
RUN npm install

# Copy seluruh source code frontend
COPY resources ./resources
COPY public ./public

# Build aset produksi (Vite akan membuat folder public/build)
RUN npm run build

# --- STAGE 2: Build Backend (PHP) & Final Image ---
FROM php:8.3

# Install dependensi sistem
RUN apt-get update && apt-get install -y \
    git zip unzip curl libpng-dev libonig-dev libxml2-dev libzip-dev sqlite3 \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy file composer dulu
COPY composer.json composer.lock ./

# Install dependensi Laravel
RUN composer install --no-dev --no-scripts --no-autoloader

# Copy seluruh source code project
COPY . .

# Copy hasil build JS/CSS dari Stage 1
COPY --from=frontend_builder /app/public/build /var/www/public/build

# ---------------------------------------------
# Menyalin file config lokal ke folder sistem PHP
COPY php-upload.ini /usr/local/etc/php/conf.d/zzz-upload.ini
# ---------------------------------------------

# Lanjutkan installasi Laravel
RUN composer dump-autoload --optimize

# Buat folder storage dan cache
RUN mkdir -p /var/www/storage/framework/views \
    /var/www/storage/framework/cache \
    /var/www/storage/framework/sessions \
    /var/www/storage/logs \
    /var/www/bootstrap/cache

# Fix permission
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
RUN chmod -R 777 /var/www/storage /var/www/bootstrap/cache

# --- PERBAIKAN UTAMA (FIX DATABASE ZOMBIE) ---
# 1. Hapus cache konfigurasi agar tidak memaksa settingan lama
RUN php artisan config:clear

# 2. Hapus database lama yang tercopy (penyebab mismatch) & buat baru
RUN rm -f database/database.sqlite && touch database/database.sqlite

# 3. Jalankan migrasi ulang
RUN php artisan migrate:fresh --force
# ---------------------------------------------

# Expose port
EXPOSE 8080

# Jalankan server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]