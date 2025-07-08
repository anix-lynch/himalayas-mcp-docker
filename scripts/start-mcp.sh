#!/bin/bash

set -e

echo "🏔️ Starting Himalayas MCP Docker Container..."

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

echo "✅ All MCP servers started successfully!"
echo "📊 Server PIDs:"
echo "  Filesystem: $FILESYSTEM_PID"
echo "  GitHub: $GITHUB_PID" 
echo "  Memory: $MEMORY_PID"
echo "  Himalayas: $HIMALAYAS_PID"

# Keep container running and monitor processes
wait $HIMALAYAS_PID