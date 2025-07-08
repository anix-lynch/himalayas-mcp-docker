#!/bin/bash

cd /Users/anixlynch/himalayas-mcp-docker
chmod +x test-and-build.sh
chmod +x scripts/*.sh
chmod +x config/*.sh

echo "🧪 Starting local test of OpenAPI server..."

# Quick test of OpenAPI server
node openapi-server.js &
OPENAPI_PID=$!

sleep 3

echo "🔍 Testing endpoints..."
curl -s http://localhost:5050/health || echo "Health check failed"
curl -s http://localhost:5050/himalayas-openapi.json | head -10 || echo "OpenAPI spec failed"

# Clean up
kill $OPENAPI_PID 2>/dev/null || true

echo "✅ Quick test complete"