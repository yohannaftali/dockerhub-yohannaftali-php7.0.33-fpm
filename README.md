# yohannaftali/php7.0.33-fpm

[![Docker Pulls](https://img.shields.io/docker/pulls/yohannaftali/php7.0.33-fpm)](https://hub.docker.com/r/yohannaftali/php7.0.33-fpm)
[![Docker Image Size](https://img.shields.io/docker/image-size/yohannaftali/php7.0.33-fpm/latest)](https://hub.docker.com/r/yohannaftali/php7.0.33-fpm)

[PHP 7.0.33-FPM](https://hub.docker.com/_/php) (Alpine) image for legacy applications such as CodeIgniter 2, preconfigured with the **Asia/Jakarta (WIB, UTC+7)** timezone, the extensions those apps usually need (including `mcrypt`) and Composer 2.2.

- Docker Hub: <https://hub.docker.com/r/yohannaftali/php7.0.33-fpm>
- Source code (Dockerfile, build workflow, scripts): <https://github.com/yohannaftali/dockerhub-yohannaftali-php7.0.33-fpm>
- Issues and feature requests: <https://github.com/yohannaftali/dockerhub-yohannaftali-php7.0.33-fpm/issues>

> **Note:** PHP 7.0 (end of life since January 2019) and the Alpine 3.7 base (also EOL) no longer receive security fixes, and rebuilding does not change that. Use this image only for legacy applications that cannot be upgraded, and do not expose it to untrusted input without other mitigations.

## Use this image

No build needed. Pull the prebuilt image straight from Docker Hub:

```bash
docker pull yohannaftali/php7.0.33-fpm
```

Or reference it in your `docker-compose.yml`:

```yaml
services:
  php:
    image: yohannaftali/php7.0.33-fpm:latest
```

## Overview

Built `FROM php:7.0.33-fpm-alpine` and adds:

- **Timezone**: `TZ=Asia/Jakarta` (with `tzdata` installed, so `date` and PHP report WIB).
- **Extensions**: `gd` (freetype, jpeg), `mysqli`, `pdo`, `pdo_mysql`, `pgsql`, `pdo_pgsql`, `zip`, `soap`, `bcmath`, `mbstring`, `pcntl`, `xmlrpc`, `intl`, `mcrypt`.
- **Composer 2.2** (the LTS line; Composer 2.3 and later no longer run on PHP 7.0).
- **Tools**: `nano`, `wget`, `curl`, `zip`, `unzip`, `iputils`, `nmap`, and `jpegoptim`, `optipng`, `pngquant`, `gifsicle`.
- **ssmtp** is installed but not configured; mount your own `/etc/ssmtp/ssmtp.conf` if you want PHP `mail()` to work.

## Tags

| Tag | Base image |
| --- | --- |
| `latest` | `php:7.0.33-fpm-alpine` |

## Quick start

```yaml
services:
  php:
    image: yohannaftali/php7.0.33-fpm:latest
    restart: unless-stopped
    volumes:
      - ./app:/var/www/html
    expose:
      - "9000"

  web:
    image: nginx:stable
    ports:
      - "8080:80"
    volumes:
      - ./app:/var/www/html:ro
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - php
```

Verify the image:

```bash
docker run --rm yohannaftali/php7.0.33-fpm php -v
docker run --rm yohannaftali/php7.0.33-fpm date +%Z      # WIB
docker run --rm yohannaftali/php7.0.33-fpm composer --version
docker run --rm yohannaftali/php7.0.33-fpm php -m
```

## Build (maintainers)

```bash
docker login

docker build -t yohannaftali/php7.0.33-fpm:latest .
docker push yohannaftali/php7.0.33-fpm:latest
```

Multi-arch (amd64 + arm64):

```bash
docker buildx build --platform linux/amd64,linux/arm64 \
  -t yohannaftali/php7.0.33-fpm:latest --push .
```

## Automated publishing

`.github/workflows/docker-publish.yml` builds and pushes the image on every push to `main`, weekly, and on manual dispatch. It also syncs this README to the Docker Hub **overview** and the short **description**.

Required GitHub repository secrets:

| Secret | Value |
| --- | --- |
| `DOCKERHUB_USERNAME` | `yohannaftali` |
| `DOCKERHUB_TOKEN` | Docker Hub access token with *Read, Write, Delete* scope |

To change which tags are published, edit the `include` matrix in the workflow and the Tags table above.

## Maintaining the Docker Hub repository

- **Overview**: synced from this `README.md` by the workflow.
- **Short description**: set in the workflow (`short-description`), max 100 characters.
- **Manual sync / status**: see [Maintenance scripts](#maintenance-scripts).
- **Category**: not exposed through the API; set manually in *Repository → Settings → Categories*.
- **Tags**: remove stale tags in *Repository → Tags*.

## Maintenance scripts

Helper scripts in `scripts/` manage the Docker Hub repository from your machine. They need [uv](https://docs.astral.sh/uv/) and a `.env` file (copy `.env.example`) with `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`. There are no other dependencies.

| Command | Action |
| --- | --- |
| *(none)* / `sync` | Push `README.md` as the overview and set the short description |
| `status` | Show description, categories, pull and star counts |
| `tags` | List tags with last update and size |
| `delete-tag <tag>` | Delete a tag |

Bash:

```bash
./scripts/dockerhub-update.sh            # sync
./scripts/dockerhub-update.sh status
./scripts/dockerhub-update.sh tags
```

PowerShell:

```powershell
.\scripts\dockerhub-update.ps1            # sync
.\scripts\dockerhub-update.ps1 status
.\scripts\dockerhub-update.ps1 tags
```

Both wrappers call `scripts/dockerhub_update.py` through `uv run`. Set `DOCKERHUB_REPO` to target a repository other than `php7.0.33-fpm`.

## Source and contributing

The Dockerfile, GitHub Actions workflow and maintenance scripts live at <https://github.com/yohannaftali/dockerhub-yohannaftali-php7.0.33-fpm>. Open an issue there to report a problem.

## License

The Dockerfile in this repository is provided as-is. PHP is licensed under the PHP License; see the [official image](https://hub.docker.com/_/php) for details.
