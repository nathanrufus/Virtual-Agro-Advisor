# ---------- Base image ----------
FROM python:3.13-slim

# Prevent Python from writing .pyc files & buffer logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# App working directory
WORKDIR /app

# - nodejs + npm for the Jac React client bundle
# - build-essential for any native extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nodejs \
        npm \
        build-essential \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

# requirements.txt already includes jaclang, jac-client, byllm, etc. 
COPY requirements.txt ./
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy package.json / lockfile first so Docker can cache npm install
COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 8000

CMD ["jac", "serve", "app.jac"]