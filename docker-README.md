# Claudia Development Environment - Docker Setup

All-in-one multi-service Docker container for local development.

## 🚀 Quick Start

```bash
# Using Make (recommended)
make up

# Or using Docker Compose directly
docker compose -f docker-compose.dev.yml up -d
```

## 📦 Included Services

All services run in a **single container** managed by Supervisor:

| Service | Port | Purpose |
|---------|------|---------|
| **Ollama** | 11434 | Local LLM inference server |
| **SearXNG** | 8080 | Privacy-respecting metasearch |
| **SurrealDB** | 8081 | Multi-model database |
| **Serena** | 8384 | Code analysis service |

## 🛠️ Make Commands

```bash
make help      # Show all available commands
make build     # Build the Docker image
make up        # Start all services
make down      # Stop all services
make restart   # Restart all services
make logs      # Show logs from all services
make shell     # Open bash shell in container
make health    # Check health of all services
make models    # Pull recommended Ollama models
make clean     # Remove containers (keep data)
make prune     # Remove everything including data (DESTRUCTIVE)
```

## 📋 Requirements

- Docker 20.10+
- Docker Compose v2+
- 8GB RAM minimum (16GB recommended)
- 20GB free disk space

## 🔧 Configuration

### Environment Variables

Create a `.env` file from the example:

```bash
cp .env.example .env
```

Key variables:

```bash
# Ollama
OLLAMA_DEFAULT_MODELS=llama2,codellama  # Models to auto-download

# SurrealDB
SURREALDB_USER=root
SURREALDB_PASS=root

# SearXNG
SEARXNG_SECRET_KEY=your-random-secret-key

# Serena
SERENA_API_KEY=dev-key

# Playwright
PLAYWRIGHT_HEADLESS=true
PLAYWRIGHT_BROWSER=chromium
```

### Data Persistence

All data is stored in Docker volumes:

```bash
# List volumes
docker volume ls | grep claudia

# Inspect a volume
docker volume inspect claudia-dev_ollama-data

# Backup volumes (example for Ollama)
docker run --rm -v claudia-dev_ollama-data:/data -v $(pwd):/backup ubuntu tar czf /backup/ollama-backup.tar.gz /data
```

## 🏥 Health Checks

The container includes comprehensive health checks:

```bash
# Quick health check
make health

# Manual check
docker compose -f docker-compose.dev.yml exec claudia-dev /usr/local/bin/healthcheck.sh
```

Expected output:
```
🏥 Checking service health...
✓ Ollama: healthy
✓ SurrealDB: healthy
✓ SearXNG: healthy
✓ Serena: healthy
---
Healthy: 4 | Unhealthy: 0
Status: HEALTHY
```

## 📊 Service Management

All services are managed by **Supervisor** inside the container.

### Check Service Status

```bash
# Open shell
make shell

# Inside container
supervisorctl status
```

### Restart Individual Services

```bash
# Inside container (after 'make shell')
supervisorctl restart ollama
supervisorctl restart surrealdb
supervisorctl restart searxng
supervisorctl restart serena

# Restart all services
supervisorctl restart all
```

### View Service Logs

```bash
# Inside container
tail -f /var/log/supervisor/ollama.out.log
tail -f /var/log/supervisor/surrealdb.out.log
tail -f /var/log/supervisor/searxng.out.log
tail -f /var/log/supervisor/serena.out.log

# View all logs
tail -f /var/log/supervisor/*.log
```

## 🤖 Ollama Models

### Pull Models

```bash
# Using Make (pulls recommended models)
make models

# Or manually
docker compose -f docker-compose.dev.yml exec claudia-dev ollama pull llama2
docker compose -f docker-compose.dev.yml exec claudia-dev ollama pull codellama
docker compose -f docker-compose.dev.yml exec claudia-dev ollama pull mistral
```

### List Installed Models

```bash
docker compose -f docker-compose.dev.yml exec claudia-dev ollama list
```

### Test Ollama

```bash
# From host
curl http://localhost:11434/api/version

# Generate completion
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Why is the sky blue?",
  "stream": false
}'
```

## 🔍 Testing Services

### Ollama

```bash
curl http://localhost:11434/api/version
curl http://localhost:11434/api/tags
```

### SurrealDB

```bash
curl http://localhost:8081/health
```

### SearXNG

```bash
# Web interface
open http://localhost:8080

# Health check
curl http://localhost:8080/healthz
```

### Serena

```bash
curl http://localhost:8384/health
```

## 🐛 Troubleshooting

### Container Won't Start

```bash
# Check logs
make logs

# Rebuild image
make down
make build
make up
```

### Service Not Responding

```bash
# Check health
make health

# Open shell and check supervisor
make shell
supervisorctl status

# Restart problematic service
supervisorctl restart <service-name>
```

### Port Already in Use

```bash
# Check what's using the port
lsof -i :11434
lsof -i :8080
lsof -i :8081
lsof -i :8384

# Change port in docker-compose.dev.yml
# Example: "8082:8080" instead of "8080:8080"
```

### Out of Disk Space

```bash
# Check disk usage
docker system df

# Clean up unused images/containers
docker system prune -a

# Remove Claudia volumes (DESTRUCTIVE)
make prune
```

### Slow Performance

```bash
# Check resource usage
docker stats claudia-dev-env

# Allocate more resources in Docker Desktop settings
# Recommended: 4 CPUs, 8GB RAM
```

## 🔐 Security Notes

- Default passwords are set in `.env.example` - **CHANGE THEM**
- Services listen on `0.0.0.0` inside container but are only exposed to localhost
- For production use, add authentication and use HTTPS
- Never commit `.env` file to version control

## 📚 Additional Resources

- [Ollama Documentation](https://github.com/ollama/ollama)
- [SurrealDB Docs](https://surrealdb.com/docs)
- [SearXNG Docs](https://docs.searxng.org/)
- [Supervisor Docs](http://supervisord.org/)

## 🤝 Contributing

When making changes to the Docker setup:

1. Test locally with `make build && make up`
2. Verify all services start: `make health`
3. Check logs for errors: `make logs`
4. Update this README if adding new services
5. Update SETUP.md with any new configuration

## 📝 License

Same as the Claudia project.
