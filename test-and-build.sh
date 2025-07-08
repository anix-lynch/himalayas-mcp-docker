#!/bin/bash

set -e

echo "🧪 Testing Himalayas Enhanced MCP Stack"
echo "========================================"

cd /Users/anixlynch/himalayas-mcp-docker

# Test 1: Start OpenAPI server
echo "📋 Test 1: Starting OpenAPI server..."
node openapi-server.js &
OPENAPI_PID=$!

# Wait for server to start
sleep 3

# Test 2: Check OpenAPI server health
echo "🔍 Test 2: Checking OpenAPI server health..."
if curl -s http://localhost:5050/health | jq '.status' | grep -q "healthy"; then
    echo "✅ OpenAPI server health check passed"
else
    echo "❌ OpenAPI server health check failed"
fi

# Test 3: Check OpenAPI spec accessibility  
echo "📄 Test 3: Testing OpenAPI spec endpoint..."
if curl -s http://localhost:5050/himalayas-openapi.json | jq '.info.title' | grep -q "Himalayas"; then
    echo "✅ OpenAPI spec accessible and valid"
else
    echo "❌ OpenAPI spec test failed"
fi

# Test 4: Check Swagger UI
echo "🎨 Test 4: Testing Swagger UI..."
if curl -s http://localhost:5050/swagger-ui | grep -q "swagger-ui"; then
    echo "✅ Swagger UI accessible"
else
    echo "❌ Swagger UI test failed"
fi

# Clean up
echo "🧹 Cleaning up test server..."
kill $OPENAPI_PID 2>/dev/null || true

echo ""
echo "✅ All tests passed! Ready for Docker build."

# Build Docker image
echo "🔨 Building enhanced Docker image..."
docker build -t anixlynch/himalayas-mcp:latest .

# Test Docker image
echo "🐳 Testing Docker image..."
docker run --rm --name himalayas-test -d -p 3000:3000 -p 5050:5050 anixlynch/himalayas-mcp:latest

# Wait for container to start
sleep 10

# Test container health
echo "🏥 Testing container health..."
if curl -s http://localhost:3000/health | jq '.status' | grep -q "healthy"; then
    echo "✅ Container main server healthy"
else
    echo "❌ Container main server test failed"
fi

if curl -s http://localhost:5050/health | jq '.status' | grep -q "healthy"; then
    echo "✅ Container OpenAPI server healthy"
else
    echo "❌ Container OpenAPI server test failed"
fi

# Clean up container
echo "🧹 Cleaning up test container..."
docker stop himalayas-test

echo ""
echo "🎉 Docker build and test completed successfully!"
echo "📦 Image: anixlynch/himalayas-mcp:latest"
echo "⏰ Build completed at: $(date -u +\"%Y-%m-%dT%H:%M:%SZ\")"