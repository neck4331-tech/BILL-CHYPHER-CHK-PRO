# Netflix Cookie Checker — Telegram Bot

A high-speed Telegram bot that validates Netflix cookies in bulk, extracts full account details, and saves hits to MongoDB.

---

## Features

- **Bulk cookie checking** — paste text or upload `.txt` / `.zip` file
- **Proxy race engine** — races N proxies simultaneously, uses direct as fallback
- **Smart proxy scoring** — EMA latency tracking keeps fastest proxies at the front
- **MongoDB integration** — hits, free accounts, and on-hold accounts saved automatically
- **Multiple output modes** — Basic (compact) and Full Info
- **Delivery modes** — individual messages or ZIP archive
- **Change password** — [BETA] change a Netflix account password directly from Telegram

---

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/raistar44xyz-tech/netflix-cookie-checker.git
cd netflix-cookie-checker
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Set environment variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `TELEGRAM_BOT_TOKEN` | ✅ | — | Telegram bot token from @BotFather |
| `MONGODB_URL` | ❌ | — | MongoDB connection string (hits saved when set) |
| `ADMIN_ID` | ❌ | first `/setadmin` user | Telegram user ID of the admin |
| `RACE_N` | ❌ | `6` | How many proxies to race simultaneously |
| `BULK_CONCURRENCY` | ❌ | `16` | How many cookies to check per batch |

> **MongoDB URL tip:** If your password contains `@`, it is automatically percent-encoded — no manual fix needed.

### 4. Run

```bash
python bot.py
```

---

## Bot Commands

| Command | Description |
|---|---|
| `/start` | Welcome message & overview |
| `/help` | Supported formats & bulk mode guide |
| `/info` | Live stats & bot info |
| `/settings` | Output format & delivery mode |
| `/mode` | Toggle Basic ↔ Full Info |
| `/basic` | Switch to Basic (compact) mode |
| `/fullinfo` | Switch to Full Info mode |
| `/changepw` | [BETA] Change a Netflix account password |
| `/cancel` | Cancel any active flow |

> Admin-only commands (`/proxy`, `/setadmin`) are intentionally hidden from the public menu but still work.

---

## Supported Cookie Formats

| Format | Example |
|--------|---------|
| Netscape `.txt` | `.netflix.com TRUE / TRUE … NetflixId ct%3D…` |
| CookieCheckerPro | `[user]-[IN]-[Premium]-[4K+HDR]-[21 Apr 2026]-[VISA]` |
| Pipe-combo | `email:pass \| Country=IN \| NetflixId=ct%3D…` |
| JSON array | `[{"name":"NetflixId","value":"ct%3D…"}]` |
| ZIP bundle | Each `.txt` / `.json` inside = one account |

---

## Proxy Pool

- Add proxies via `/proxy` → Add Proxy (format: `http://ip:port` or `socks5://ip:port`)
- Or set a proxy source URL — the bot will auto-fetch and refresh
- Proxies are scored by round-trip latency (EMA) after each successful check
- Dead proxies are automatically retired after repeated failures

---

## Performance Tuning

| Env Var | Default | Suggested Range |
|---|---|---|
| `RACE_N` | `6` | `6`–`16` (more = faster on large proxy pools) |
| `BULK_CONCURRENCY` | `32` | `24`–`48` |

---

## File Structure

| File | Purpose |
|------|---------|
| `bot.py` | Telegram handlers, formatters, bulk processing, ZIP export |
| `checker.py` | Cookie parsing, Netflix HTTP validation |
| `proxy_manager.py` | Rotating proxy pool with EMA latency scoring |
| `mongodb_store.py` | MongoDB persistence for hits (auto-connects on startup) |
| `password_changer.py` | [BETA] Netflix password changer |
| `stats.py` | Thread-safe in-memory stats tracker |
| `requirements.txt` | Python dependencies |
| `scripts/post-merge.sh` | Auto-installs dependencies after merges |

---

## Requirements

- Python 3.10+
- See `requirements.txt`

---

## Deploy with Docker (GHCR image)

A ready-made image is published automatically to GitHub Container Registry on every push to `main`.

### One-liner run

```bash
docker run -d --name nf-checker \
  -e TELEGRAM_BOT_TOKEN=123456:ABC-your-token \
  -p 5000:5000 \
  --restart unless-stopped \
  ghcr.io/raistar44xyz-tech/netflix-cookie-checker:latest
```

### Or with docker-compose

```bash
export TELEGRAM_BOT_TOKEN=123456:ABC-your-token
docker compose up -d
```

### Note — image is private (repo is private)

Pulling the image requires a one-time login with a GitHub token that has
`read:packages` scope (your PAT works):

```bash
echo YOUR_GITHUB_TOKEN | docker login ghcr.io -u raistar44xyz-tech --password-stdin
```

> To make the image pullable anywhere without login: on GitHub open
> **Packages → netflix-cookie-checker → Package settings → Danger Zone →
> Change visibility → Public** (one-time step).

Optional extras (compose / docker run `-e`): `ADMIN_ID`, `MONGODB_URL`, `BULK_CONCURRENCY`, `RACE_N`.
The dashboard is served on port `5000`.

### Build the image yourself

```bash
git clone https://github.com/raistar44xyz-tech/netflix-cookie-checker.git
cd netflix-cookie-checker
docker build -t nf-checker .
```

> The GHCR image is rebuilt automatically on every push to `main` (see
> `.github/workflows/docker-publish.yml`) — so the image always matches the repo.
