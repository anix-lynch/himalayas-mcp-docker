#!/bin/bash

set -e

echo "🏔️ Starting Himalayas God Mode - Full MCP Stack + API Gateway"

# Load Doppler secrets if token is available
if [ -n "$DOPPLER_TOKEN" ]; then
    echo "📦 Loading secrets from Doppler..."
    doppler secrets download --no-file --format env > /tmp/.env
    source /tmp/.env
    rm /tmp/.env
fi

# Verify required environment variables (optional for demo mode)
if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    echo "⚠️ GITHUB_PERSONAL_ACCESS_TOKEN not found - GitHub MCP will be limited"
    echo "Set GITHUB_PERSONAL_ACCESS_TOKEN for full functionality"
else
    echo "✅ GitHub token found"
fi

# Generate the MCP configuration
echo "🔧 Generating enhanced MCP configuration..."
./scripts/generate-config.sh

# Start OpenAPI server first (API Gateway fallback)
echo "📋 Starting OpenAPI server on port 5050..."
node openapi-server.js &
OPENAPI_PID=$!

# Wait for OpenAPI server to be ready
sleep 3
if curl -s http://localhost:5050/health > /dev/null; then
    echo "✅ OpenAPI server ready - API Gateway fallback available"
else
    echo "⚠️ OpenAPI server may not be ready"
fi

# Start the MCP servers
echo "🚀 Starting MCP server stack..."

# Start filesystem server in background
npx @modelcontextprotocol/server-filesystem /app &
FILESYSTEM_PID=$!

# Start github server in background (if token available)
if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN npx @modelcontextprotocol/server-github &
    GITHUB_PID=$!
else
    echo "⏭️ Skipping GitHub MCP (no token)"
    GITHUB_PID="N/A"
fi

# Start memory server in background
npx @modelcontextprotocol/server-memory &
MEMORY_PID=$!

# Try to start Himalayas MCP server via mcp-remote
echo "🏔️ Attempting to connect to Himalayas MCP server..."
if timeout 10 npx mcp-remote https://mcp.himalayas.app/sse --test-connection; then
    echo "✅ Himalayas MCP server reachable, starting connection..."
    npx mcp-remote https://mcp.himalayas.app/sse &
    HIMALAYAS_PID=$!
    HIMALAYAS_STATUS="✅ Connected"
else
    echo "⚠️ Himalayas MCP server not reachable - API Gateway fallback will handle requests"
    HIMALAYAS_PID="N/A"
    HIMALAYAS_STATUS="❌ Using API fallback"
fi

# Start Docker MCP server in background (if available)
echo "🐳 Starting Docker MCP server..."
if command -v uvx >/dev/null 2>&1; then
    uvx docker-mcp &
    DOCKER_PID=$!
    DOCKER_STATUS="✅ via uvx"
elif command -v python >/dev/null 2>&1; then
    python -m docker_mcp &
    DOCKER_PID=$!
    DOCKER_STATUS="✅ via python"
else
    echo "⚠️ Docker MCP not available (uvx/python not found)"
    DOCKER_PID="N/A"
    DOCKER_STATUS="❌ Unavailable"
fi

# Start Desktop Commander MCP (if available)
echo "💻 Starting Desktop Commander MCP..."
if command -v npx >/dev/null 2>&1; then
    npx @modelcontextprotocol/server-desktop-commander &
    COMMANDER_PID=$!
    COMMANDER_STATUS="✅ Available"
else
    COMMANDER_PID="N/A"
    COMMANDER_STATUS="❌ Unavailable"
fi

# Start the main Node.js server
echo "🌐 Starting main HTTP server..."
node src/server.js &
SERVER_PID=$!

echo ""
echo "🎉 Himalayas God Mode Stack Started Successfully!"
echo "================================================"
echo "📊 Service Status:"
echo "  OpenAPI Server:    ✅ PID $OPENAPI_PID (Port 5050)"
echo "  Main HTTP Server:  ✅ PID $SERVER_PID (Port 3000)"
echo "  Filesystem MCP:    ✅ PID $FILESYSTEM_PID"
echo "  GitHub MCP:        $([[ \"$GITHUB_PID\" != \"N/A\" ]] && echo \"✅ PID $GITHUB_PID\" || echo \"⚠️ Skipped\")"
echo "  Memory MCP:        ✅ PID $MEMORY_PID"
echo "  Himalayas MCP:     $HIMALAYAS_STATUS"
echo "  Docker MCP:        $DOCKER_STATUS"
echo "  Desktop Commander: $COMMANDER_STATUS"

echo ""
echo "🔗 Available Endpoints:"
echo "  Main Server:       http://localhost:3000"
echo "  Health Check:      http://localhost:3000/health"
echo "  MCP Status:        http://localhost:3000/mcp/status"
echo "  Docker Hub API:    http://localhost:3000/api/docker"
echo "  OpenAPI Spec:      http://localhost:5050/himalayas-openapi.json"
echo "  Swagger UI:        http://localhost:5050/swagger-ui"
echo "  API Health:        http://localhost:5050/health"

echo ""
echo "🏔️ MCP Integration:"
echo "  Primary:   Himalayas MCP (https://mcp.himalayas.app/sse)"
echo "  Fallback:  API Gateway → http://localhost:5050/himalayas-openapi.json"
echo "  Strategy:  Auto-fallback when primary MCP unavailable"

echo ""
echo "🎯 Ready for:"
echo "  🔍 Remote job hunting via Himalayas"
echo "  🐳 Docker Hub operations"  
echo "  🐙 GitHub repository management"
echo "  💻 System command execution"
echo "  📁 File system operations"
echo "  🧠 Application tracking"

echo ""
echo "⏰ Started at: $(date -u +\"%Y-%m-%dT%H:%M:%SZ\")"

# Keep container running and monitor main processes
wait $SERVER_PID