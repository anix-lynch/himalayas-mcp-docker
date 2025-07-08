#!/bin/bash

set -e

echo "🏔️ Building and Pushing Himalayas MCP Docker Image"

cd /Users/anixlynch/himalayas-mcp-docker

# Make scripts executable
chmod +x scripts/*.sh

# Build Docker image
echo "🔨 Building Docker image..."
docker build -t anixlynch/himalayas-mcp:latest .

# Push to Docker Hub  
echo "📤 Pushing to Docker Hub..."
docker push anixlynch/himalayas-mcp:latest

echo "✅ Docker image pushed successfully!"
echo "🐳 Image: anixlynch/himalayas-mcp:latest"

# Test the image
echo "🧪 Testing Docker image..."
docker run --rm anixlynch/himalayas-mcp:latest ls -laR /app

echo "🏔️ Himalayas MCP Docker setup complete!"
