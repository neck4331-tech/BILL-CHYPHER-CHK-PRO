# Netflix Cookie Checker Bot — deployable container
# Build (local):  docker build -t nf-checker .
# Run:            docker run -d --name nf-checker -e TELEGRAM_BOT_TOKEN=xxx -p 5000:5000 ghcr.io/raistar44xyz-tech/netflix-cookie-checker:latest
FROM python:3.12-slim

# unar / libarchive-tools: RAR extraction backends for the rarfile package
RUN apt-get update \
    && apt-get install -y --no-install-recommends unar libarchive-tools curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Dashboard / status page
EXPOSE 5000

HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -fsS http://127.0.0.1:5000/ >/dev/null 2>&1 || exit 1

CMD ["python3", "bot.py"]
