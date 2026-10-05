# CHANGE_HISTORY.md

Newest first. One dated entry per notable change.

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
