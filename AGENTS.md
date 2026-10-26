# AGENTS.md

> **READ THIS FIRST.** Every AI agent working in this repository (Claude, Gemini, Copilot,
> Cursor, ...) must read this file before doing anything else. It is the single source of
> truth for what this project is and how to work on it. After any structural change
> (new file, new workflow, new tag, changed secret), update this file in the same change.
>
> **Compaction rule:** keep this file describing the *current* state. Put dated history in
> [`CHANGE_HISTORY.md`](CHANGE_HISTORY.md).

## Repository

- remote: https://github.com/yohannaftali/dockerhub-yohannaftali-php7.0.33-fpm
- platform: GitHub (use the `gh` CLI; it is already authenticated on the maintainer's machine)
- default branch: `main`
- Docker Hub image: `yohannaftali/php7.0.33-fpm` (https://hub.docker.com/r/yohannaftali/php7.0.33-fpm)

## Big Picture

A tiny repo that builds and publishes a PHP-FPM image (PHP 7.0.33 from Ondřej Surý's
<https://packages.sury.org/php/> on `debian:trixie-slim`)
for legacy CodeIgniter 2 apps, timezone Asia/Jakarta. There is no application code: the product
is the Docker Hub image and its listing (overview, short description, tags, categories).

```
Dockerfile ──► GitHub Actions (build matrix, amd64+arm64) ──► Docker Hub yohannaftali/php7.0.33-fpm
README.md  ──► peter-evans/dockerhub-description / scripts/dockerhub-update.sh ──► Hub overview
```

## Repository Layout

```
Dockerfile                       # FROM debian:${DEBIAN_RELEASE}-slim + Sury php${PHP_VERSION}-*; Composer 2.2, TZ=Asia/Jakarta
README.md                        # human docs AND the Docker Hub overview (synced as-is)
AGENTS.md / CHANGE_HISTORY.md    # agent guide / dated history
CLAUDE.md                        # points agents at this file
.env.example                     # variable names only; real .env is git-ignored
.github/workflows/docker-publish.yml   # build+push matrix, then description sync
scripts/dockerhub_update.py      # Docker Hub API helper (stdlib only, run via uv)
scripts/dockerhub-update.sh|.ps1 # bash / PowerShell wrappers around `uv run`
.claude/skills/                  # planner, coder, tester, reviewer (see below)
```

## Key Facts

- **Tags** are the `include` matrix in `docker-publish.yml`: only `latest` (`php: "7.0"`, `debian: trixie`).
  Adding or dropping a version means editing that matrix **and** the Tags table in `README.md`.
- The workflow runs on push to `main`, weekly (Mon 03:00 UTC, to pick up upstream fixes) and
  manually. The `description` job syncs `README.md` to Docker Hub after all builds pass.
- **Secrets** (GitHub repo secrets): `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` (Docker Hub PAT,
  scope *Read, Write, Delete*; description updates need Delete scope).
- **Categories cannot be set via the Docker Hub API** (it silently ignores them). They are set
  by hand in the web UI. Not set yet.
- `README.md` is published verbatim as the Hub overview: keep it self-contained, no
  repo-relative links that only work on GitHub.

## Conventions & Guardrails

- Never commit `.env` or any token. `.env.example` holds names and placeholders only.
- Never print tokens in output, logs or commit messages. Refer to them as `$TOKEN`.
- PHP comes from Sury's Debian repo (`packages.sury.org/php`, keyring `debsuryorg-archive-keyring.deb`),
  not the official `php` image. Its `php7.0` is 7.0.33 plus backported fixes; the weekly rebuild picks up
  new package releases. The Dockerfile mimics the official `php:*-fpm` runtime contract: `CMD ["php-fpm"]`
  (symlink to `php-fpm7.0`), foreground, `listen = 9000`, logs to stderr (`pool.d/zz-docker.conf`),
  `WORKDIR /var/www/html`, `STOPSIGNAL SIGQUIT`. Keep that contract. No entrypoint script.
- Known constraints: `tzdata` must be installed or the OS timezone silently stays UTC; Composer is pinned
  to `2.2` (the LTS line that still runs on PHP 7.0, `composer:latest` aborts). Do not unpin. Debian builds
  `pcntl` for the CLI only, not for FPM. `www-data` is UID 33 (Alpine was 82).
- PHP stays on **UTC** (decided 2026-10-05: keep PHP datetime-agnostic). Debian's PHP follows `TZ` when
  `date.timezone` is unset, so `conf.d/zz-docker-timezone.ini` pins `date.timezone = UTC` for cli and fpm.
  `TZ=Asia/Jakarta` only affects the OS clock. Do not change PHP's timezone without asking.
- Pinned versions go through the `PHP_VERSION` (Sury minor, e.g. `7.0`) and `DEBIAN_RELEASE` build args,
  not separate Dockerfiles.
- Python scripts are stdlib-only and run through `uv` (`uv run scripts/dockerhub_update.py`);
  bash and PowerShell wrappers must stay thin and behave identically.
- Commit message ends with the attribution trailer configured for the session.
- Pushing to `main` publishes images to Docker Hub. Treat it as a release.

## Validation (before pushing)

```bash
docker build -t php-test .
docker run --rm php-test php -v                       # PHP 7.0.33
docker run --rm php-test date +%Z                     # WIB (OS)
docker run --rm php-test php -r 'echo date_default_timezone_get();'   # UTC (pinned)
docker run --rm php-test composer --version          # runs (2.2 LTS)
docker run --rm php-test php-fpm -t                    # config valid
docker run --rm php-test php-fpm -m                    # FPM extensions (no pcntl)
uv run scripts/dockerhub_update.py status             # needs .env; read-only
```

See the `tester` skill for the full smoke test (extensions load, Composer runs, WIB timezone, php-fpm config valid).

## Agent Skills (`.claude/skills/`)

Adapted from the Senar project for a single-image repo (no issue-tracker UI, no browser).

- **`planner`**: create/track GitHub issues with `gh`; checks `CHANGE_HISTORY.md` for
  duplicates and keeps the Tracked Issues table below current.
- **`coder`**: implements an issue (Dockerfile, workflow, scripts, README) per these rules.
- **`tester`**: builds the image locally, smoke-tests it, and only then opens/merges a PR.
- **`reviewer`**: post-merge audit of what landed on `main` and on Docker Hub.

Flow: `planner` -> `coder` -> `tester` -> `reviewer`.

## Tracked Issues

| ID | Title | Status | Last Checked |
|----|-------|--------|--------------|

## Change Log Policy

- `AGENTS.md`: current architecture and rules only.
- `CHANGE_HISTORY.md`: one dated entry per notable change, newest first.
- Any agent making a structural change updates both files in the same change.
