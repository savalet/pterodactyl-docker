FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PTERO_PATH=/var/www/pterodactyl

# --------------------------------
# Step 1: System dependencies
# --------------------------------
RUN apt update && apt install -y \
    software-properties-common \
    curl \
    apt-transport-https \
    ca-certificates \
    gnupg \
    mariadb-client \
    netcat-traditional \
    redis-server \
    nginx \
    tar \
    unzip \
    git

# --------------------------------
# Step 2: Install PHP 8.3 from Sury
# --------------------------------
RUN curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ bookworm main" > /etc/apt/sources.list.d/php.list && \
    apt update && \
    apt install -y php8.3 php8.3-common php8.3-cli php8.3-gd php8.3-mysql php8.3-mbstring php8.3-bcmath php8.3-xml php8.3-fpm php8.3-curl php8.3-zip nginx tar unzip

# --------------------------------
# Step 3: Install Composer
# --------------------------------
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# --------------------------------
# Step 4: Download and extract Pterodactyl
# --------------------------------
RUN mkdir -p ${PTERO_PATH}
WORKDIR ${PTERO_PATH}
RUN curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz && \
    tar -xzvf panel.tar.gz && \
    rm panel.tar.gz && \
    chmod -R 755 *

# --------------------------------
# Step 5: Install PHP dependencies
# --------------------------------
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader

# --------------------------------
# Step 6: Copy entrypoint
# --------------------------------
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# --------------------------------
# Step 6: Setup the webserver config
# -------------------------------
WORKDIR /etc/nginx/sites-enabled
RUN rm default
COPY pterodactyl.conf ./

WORKDIR /
EXPOSE 80
CMD ["./entrypoint.sh"]
