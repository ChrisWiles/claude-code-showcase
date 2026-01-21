#!/bin/bash
# Health check script for all services
# Exit code 0 = healthy, 1 = unhealthy

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

healthy=0
unhealthy=0

echo "🏥 Checking service health..."

# Check Ollama (port 11434)
if curl -sf http://localhost:11434/api/version > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Ollama: healthy"
    ((healthy++))
else
    echo -e "${RED}✗${NC} Ollama: unhealthy"
    ((unhealthy++))
fi

# Check SurrealDB (port 8000 - internal, exposed as 8081)
if curl -sf http://localhost:8000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} SurrealDB: healthy"
    ((healthy++))
else
    echo -e "${RED}✗${NC} SurrealDB: unhealthy"
    ((unhealthy++))
fi

# Check SearXNG (port 8080)
if curl -sf http://localhost:8080/healthz > /dev/null 2>&1 || \
   curl -sf http://localhost:8080/ > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} SearXNG: healthy"
    ((healthy++))
else
    echo -e "${YELLOW}⚠${NC} SearXNG: unhealthy (non-critical)"
    # SearXNG is optional, don't count as critical failure
fi

# Check Serena (port 8384)
if curl -sf http://localhost:8384/health > /dev/null 2>&1 || \
   curl -sf http://localhost:8384/ > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Serena: healthy"
    ((healthy++))
else
    echo -e "${YELLOW}⚠${NC} Serena: unhealthy (non-critical)"
    # Serena is optional, don't count as critical failure
fi

echo "---"
echo "Healthy: $healthy | Unhealthy: $unhealthy"

# Consider healthy if critical services (Ollama, SurrealDB) are up
# SearXNG and Serena are optional
if [ $unhealthy -gt 2 ]; then
    echo -e "${RED}Status: UNHEALTHY${NC}"
    exit 1
else
    echo -e "${GREEN}Status: HEALTHY${NC}"
    exit 0
fi
