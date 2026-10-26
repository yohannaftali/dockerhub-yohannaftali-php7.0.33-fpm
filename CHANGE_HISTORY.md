# CHANGE_HISTORY.md

Newest first. One dated entry per notable change.

## [2026-10-26] — feat: switch base to Debian + Ondřej Surý PHP packages
- `Dockerfile`: `FROM debian:${DEBIAN_RELEASE}-slim` (default `trixie`) with `php${PHP_VERSION}-*` (default `7.0`) from `https://packages.sury.org/php/` instead of `php:7.0.33-fpm-alpine`. Reason: the official 7.0 image and its Alpine 3.7 base get no fixes. Sury's `php7.0` (7.0.33-93, built 2026-10-22) carries backported fixes and the weekly rebuild picks them up. amd64 and arm64 are both published by Sury.
- Matches the official runtime contract: `CMD ["php-fpm"]` (symlink), foreground, port 9000, logs to stderr, `WORKDIR /var/www/html`, `STOPSIGNAL SIGQUIT`.
- Debian's PHP follows `TZ` when `date.timezone` is unset (it reported `Asia/Jakarta`). Added `date.timezone = UTC` for cli/fpm to keep the 2026-10-05 decision.
- Breaking for users: config moved to `/etc/php/7.0/...`, no `docker-php-ext-*` helpers, `www-data` UID 82 -> 33, Debian production `php.ini`, `pcntl` CLI-only. Dropped the unused `php7-mcrypt`/`-dev` build packages; `mcrypt` now comes from `php7.0-mcrypt`. Added `curl` and `xml` extensions.
- Workflow matrix: `php: "7.0"`, `debian: trixie`; short description updated. README rewritten for the new base.

## [2026-10-05] — docs: PHP timezone stays UTC
- Verified that PHP's `date()` reports UTC even though the OS clock is WIB (PHP ignores `TZ` and uses `date.timezone`). Decision: keep PHP on UTC so applications stay datetime-agnostic. README, labels, short description and `AGENTS.md` now say "OS timezone Asia/Jakarta, PHP stays UTC" instead of implying PHP runs on Jakarta time. No Dockerfile behavior change.

## [2026-10-05] — fix + chore: correct timezone and Composer, apply the shared repo setup
- **Timezone fix**: the image reported `UTC`, not WIB. Alpine ships no `tzdata`, so the `/etc/localtime` symlink pointed at nothing. Added `tzdata` to the `apk add` list.
- **Composer fix**: `COPY --from=composer:latest` gave a Composer that aborts on PHP 7.0 ("Composer 2.3.0 dropped support for PHP <7.2.5"). Pinned to `composer:2.2` (LTS); verified 2.2.30 runs.
- `Dockerfile`: `PHP_VERSION` build arg, OCI labels, trailing-whitespace cleanup after line continuations, trailing newline. Left as-is: `DEBIAN_FRONTEND` (meaningless on Alpine), `php7-mcrypt` apk package (unused by the docker-built `mcrypt`), unconfigured `ssmtp`.
- `.github/workflows/docker-publish.yml`: single tag `latest` (`php:7.0.33-fpm-alpine`), amd64+arm64, weekly + on push to **`main`** (default branch is `main`; the default branch was renamed from `yohan` to `main` on 2026-10-05) + manual, then syncs README to the Hub overview. Rebuilds `latest`, last pushed 2025-01-14.
- `README.md`: full rewrite (EOL warning, what the image adds, usage, GitHub links, maintenance scripts).
- Added `scripts/`, `.env.example`, `.gitignore`, `CLAUDE.md`, `AGENTS.md` and `.claude/skills/` adapted from the sibling Docker Hub repos.
- Docker Hub category still to be set manually in the web UI.

## Earlier
- 2025-01-14: published `yohannaftali/php7.0.33-fpm:latest` (`init`).
- Initial Dockerfile: `FROM php:7.0.33-fpm-alpine` with the PHP extensions for CodeIgniter 2 and Composer.
