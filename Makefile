.PHONY: help build up down restart logs shell health clean prune models

# Default target
help:
	@echo "Claudia Development Environment - Make Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build      Build the development Docker image"
	@echo "  up         Start all services (builds if needed)"
	@echo "  down       Stop all services"
	@echo "  restart    Restart all services"
	@echo "  logs       Show logs from all services"
	@echo "  shell      Open bash shell in container"
	@echo "  health     Check health of all services"
	@echo "  clean      Stop and remove containers, keep volumes"
	@echo "  prune      Remove everything including volumes (DESTRUCTIVE)"
	@echo "  models     Pull recommended Ollama models"
	@echo ""

# Build the Docker image
build:
	@echo "🔨 Building Claudia development image..."
	docker compose -f docker-compose.dev.yml build

# Start services
up:
	@echo "🚀 Starting Claudia development environment..."
	docker compose -f docker-compose.dev.yml up -d
	@echo ""
	@echo "✨ Services starting... Check health with: make health"
	@echo ""
	@echo "📍 Service URLs:"
	@echo "   Ollama:     http://localhost:11434"
	@echo "   SearXNG:    http://localhost:8080"
	@echo "   SurrealDB:  http://localhost:8081"
	@echo "   Serena:     http://localhost:8384"
	@echo ""

# Stop services
down:
	@echo "🛑 Stopping Claudia development environment..."
	docker compose -f docker-compose.dev.yml down

# Restart services
restart:
	@echo "🔄 Restarting Claudia development environment..."
	docker compose -f docker-compose.dev.yml restart

# Show logs
logs:
	docker compose -f docker-compose.dev.yml logs -f

# Open shell in container
shell:
	docker compose -f docker-compose.dev.yml exec claudia-dev /bin/bash

# Check health
health:
	@echo "🏥 Checking service health..."
	@docker compose -f docker-compose.dev.yml exec claudia-dev /usr/local/bin/healthcheck.sh || true

# Clean (remove containers but keep data)
clean:
	@echo "🧹 Cleaning up containers..."
	docker compose -f docker-compose.dev.yml down
	docker compose -f docker-compose.dev.yml rm -f

# Prune (remove everything including volumes)
prune:
	@echo "⚠️  WARNING: This will delete all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "🗑️  Removing everything..."; \
		docker compose -f docker-compose.dev.yml down -v; \
		docker compose -f docker-compose.dev.yml rm -f; \
		docker volume rm -f claudia-dev_ollama-data claudia-dev_surrealdb-data claudia-dev_searxng-data claudia-dev_serena-data 2>/dev/null || true; \
		echo "✅ Cleanup complete"; \
	else \
		echo "❌ Cancelled"; \
	fi

# Pull recommended Ollama models
models:
	@echo "📦 Pulling recommended Ollama models..."
	@echo "This may take a while depending on your internet connection..."
	docker compose -f docker-compose.dev.yml exec claudia-dev ollama pull llama2
	docker compose -f docker-compose.dev.yml exec claudia-dev ollama pull codellama
	docker compose -f docker-compose.dev.yml exec claudia-dev ollama pull mistral
	@echo "✅ Models installed"
	@echo ""
	@echo "List all models with: docker compose -f docker-compose.dev.yml exec claudia-dev ollama list"
