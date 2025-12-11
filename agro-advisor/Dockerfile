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
# - nginx as a tiny reverse-proxy in front of Jac
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nodejs \
        npm \
        build-essential \
        ca-certificates \
        curl \
        nginx \
    && rm -rf /var/lib/apt/lists/*

# requirements.txt already includes jaclang, jac-client, byllm, etc. 
COPY requirements.txt ./
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy package.json / lockfile first so Docker can cache npm install
COPY package*.json ./
RUN npm install

# Copy the rest of the app (including nginx.conf)
COPY . .

# Use our custom nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Expose Nginx port (front door)
EXPOSE 8000

# Run Jac server on 8001, then start nginx on 8000 in the foreground
CMD ["sh", "-c", "jac serve app.jac --port 8001 & nginx -g 'daemon off;'"]
