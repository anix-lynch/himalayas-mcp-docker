#!/bin/bash

set -e

echo "🏔️ Building Enhanced Himalayas MCP Docker Image"
echo "================================================"

cd /Users/anixlynch/himalayas-mcp-docker

# Make all scripts executable
chmod +x *.sh scripts/*.sh config/*.sh 2>/dev/null || true

# Build the Docker image
echo "🔨 Building Docker image with enhanced features..."
docker build -t anixlynch/himalayas-mcp:latest . --no-cache

echo "✅ Docker build complete!"

# Quick test of the built image
echo "🧪 Quick test of Docker image..."
timeout 30 docker run --rm --name himalayas-quick-test -p 13000:3000 -p 15050:5050 anixlynch/himalayas-mcp:latest &
CONTAINER_PID=$!

sleep 10

# Test if both ports are responding
if curl -s http://localhost:13000/health >/dev/null 2>&1; then
    echo "✅ Main server responding on port 3000"
else
    echo "⚠️ Main server not responding"
fi

if curl -s http://localhost:15050/health >/dev/null 2>&1; then
    echo "✅ OpenAPI server responding on port 5050"
else
    echo "⚠️ OpenAPI server not responding"
fi

# Clean up
docker stop himalayas-quick-test 2>/dev/null || true

echo ""
echo "🎉 Build and test completed!"
echo "📦 Image ready: anixlynch/himalayas-mcp:latest"
echo "⏰ Timestamp: $(date -u +\"%Y-%m-%dT%H:%M:%SZ\")"