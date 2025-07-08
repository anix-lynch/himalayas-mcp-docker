#!/bin/bash

set -e

echo "🏔️ Starting Himalayas + Docker Hub MCP Container..."

# Load Doppler secrets if token is available
if [ -n "$DOPPLER_TOKEN" ]; then
    echo "📦 Loading secrets from Doppler..."
    doppler secrets download --no-file --format env > /tmp/.env
    source /tmp/.env
    rm /tmp/.env
fi

# Verify required environment variables
if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    echo "❌ GITHUB_PERSONAL_ACCESS_TOKEN not found in environment"
    echo "Please check your Doppler configuration"
    exit 1
fi

echo "✅ Environment validated"

# Generate the MCP configuration
echo "🔧 Generating MCP configuration..."
./scripts/generate-config.sh

# Start the MCP servers
echo "🚀 Starting MCP servers..."

# Start filesystem server in background
npx @modelcontextprotocol/server-filesystem /app &
FILESYSTEM_PID=$!

# Start github server in background  
GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN npx @modelcontextprotocol/server-github &
GITHUB_PID=$!

# Start memory server in background
npx @modelcontextprotocol/server-memory &
MEMORY_PID=$!

# Start Himalayas MCP server via mcp-remote
echo "🏔️ Connecting to Himalayas MCP server..."
npx mcp-remote https://mcp.himalayas.app/sse &
HIMALAYAS_PID=$!

# Start Docker MCP server in background
echo "🐳 Starting Docker MCP server..."
if command -v uvx >/dev/null 2>&1; then
    uvx docker-mcp &
    DOCKER_PID=$!
else
    echo "⚠️ uvx not found, starting Docker MCP via Python..."
    python -m docker_mcp &
    DOCKER_PID=$!
fi

# Start the main Node.js server
echo "🌐 Starting main HTTP server..."
node src/server.js &
SERVER_PID=$!

echo "✅ All MCP servers started successfully!"
echo "📊 Server PIDs:"
echo "  Filesystem: $FILESYSTEM_PID"
echo "  GitHub: $GITHUB_PID" 
echo "  Memory: $MEMORY_PID"
echo "  Himalayas: $HIMALAYAS_PID"
echo "  Docker MCP: $DOCKER_PID"
echo "  HTTP Server: $SERVER_PID"

echo ""
echo "🔗 Available Endpoints:"
echo "  Health Check: http://localhost:3000/health"
echo "  MCP Status: http://localhost:3000/mcp/status"
echo "  Docker Hub API: http://localhost:3000/api/docker"
echo ""
echo "🏔️ Ready for job hunting with Docker Hub integration!"

# Keep container running and monitor main processes
wait $SERVER_PID