#!/bin/bash
# Startup script for Claudia Development Environment
# Initializes all services and starts supervisor

set -e

echo "🚀 Starting Claudia Development Environment..."

# Create necessary directories
mkdir -p /data/ollama/models
mkdir -p /data/surrealdb
mkdir -p /data/searxng
mkdir -p /data/serena
mkdir -p /var/log/supervisor

# Initialize SearXNG settings if not exists
if [ ! -f /data/searxng/settings.yml ]; then
    echo "📝 Initializing SearXNG settings..."
    cat > /data/searxng/settings.yml << 'EOF'
general:
  debug: false
  instance_name: "Claudia Search"

server:
  port: 8080
  bind_address: "0.0.0.0"
  secret_key: "changeme-generate-a-random-secret-key"
  limiter: false

search:
  safe_search: 0
  autocomplete: ""
  default_lang: "en"

ui:
  static_use_hash: true
  default_theme: simple
  theme_args:
    simple_style: auto

engines:
  - name: google
    engine: google
    shortcut: go
  - name: duckduckgo
    engine: duckduckgo
    shortcut: ddg
  - name: wikipedia
    engine: wikipedia
    shortcut: wp
  - name: github
    engine: github
    shortcut: gh
EOF
fi

# Set environment variables for services
export OLLAMA_HOST=0.0.0.0
export OLLAMA_MODELS=/data/ollama/models
export SEARXNG_SETTINGS_PATH=/data/searxng/settings.yml
export SURREALDB_PATH=/data/surrealdb/database.db

# Pull default Ollama models in background if OLLAMA_DEFAULT_MODELS is set
if [ ! -z "$OLLAMA_DEFAULT_MODELS" ]; then
    echo "📦 Scheduling model downloads: $OLLAMA_DEFAULT_MODELS"
    (
        sleep 30  # Wait for Ollama to start
        for model in $OLLAMA_DEFAULT_MODELS; do
            echo "Pulling Ollama model: $model"
            ollama pull $model || echo "Failed to pull $model"
        done
    ) &
fi

echo "✨ Starting all services with supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
