# Pterodactyl Panel Docker Setup

This repository provides a **fully automated Docker setup** for Pterodactyl Panel, including:

- PHP-FPM + Nginx Panel
- MariaDB
- Redis
- Caddy for SSL and reverse proxy
- Automatic admin user creation on first run

---

## Features

- **Full auto setup**: panel SSL certs, admin user, database migrations & seeders.
- **SSL ready**: Caddy automatically generates certificates via Let’s Encrypt.
- **Dynamic hostname**: APP_URL and Caddy hostname read from `.env` (`APP_DOMAIN`).

---

## Requirements

- Docker ≥ 24
- Docker Compose ≥ 2.0
- Domain name pointing to your server (for SSL via Caddy)

---

## Setup

1. Clone the repository:

```bash
git clone https://github.com/savalet/pterodactyl-docker
cd pterodactyl-docker
```

2. Copy .env.example to .env and set your domain & database credentials:

```bash
cp .env.example .env
vim .env
```

Set the APP_DOMAIN, APP_URL, DB_USER, DB_PASSWORD, ...
Do not forget to generate an APP_KEY with `echo "base64:$(openssl rand -base64 32)"`

3. Start containers:
```bash
docker compose up -d
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| panel   | N/A (proxied by Caddy) | PHP-FPM + Nginx for Pterodactyl Panel |
| db      | 3306 | MariaDB database |
| redis   | 6379 | Redis server for cache/queues |
| caddy   | 80/443 | Reverse proxy with SSL |

---

## Admin User

- On the **first startup**, the entrypoint will automatically generate an admin user if no users exist.
- A random password is generated and **logged to the console**:

You can get the admin password in the panel's logs with:

```bash
docker compose logs panel 2>&1 \
  | grep -A3 "First admin credentials" \
  | sed -E 's/^[^|]*\| //' 
```

## Docker Hub
In the docker-compose the panel's image is pull from my Docker Hub repository https://hub.docker.com/r/savalet/pterodactyl-panel

## Licence

This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.
