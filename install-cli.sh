#!/bin/bash

set -e

echo "🏔️ Himalayas MCP CLI Setup for Mac M4 Pro + Sequoia 15.5"
echo "==============================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command_exists docker; then
    echo "❌ Docker not found. Please install Docker Desktop."
    exit 1
fi

if ! command_exists git; then
    echo "❌ Git not found. Please install git."
    exit 1
fi

if ! command_exists doppler; then
    echo "⚠️  Doppler CLI not found. Installing..."
    brew install doppler || echo "Failed to install Doppler. Please install manually."
fi

echo "✅ Prerequisites checked"

# Setup directory
INSTALL_DIR="/Users/anixlynch/himalayas-mcp-setup"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Clone the repository if not exists
if [ ! -d "himalayas-mcp-docker" ]; then
    echo "📥 Cloning Himalayas MCP Docker repository..."
    git clone https://github.com/anix-lynch/himalayas-mcp-docker.git
fi

cd himalayas-mcp-docker

# Make scripts executable
chmod +x scripts/*.sh
chmod +x docker-build.sh

# Build and test image
echo "🔨 Building Docker image..."
docker build -t anixlynch/himalayas-mcp:latest .

# Create CLI symlink for easy access
echo "🔧 Setting up CLI..."
sudo ln -sf "$PWD/config/himalayas-cli.sh" /usr/local/bin/himalayas-mcp || echo "Note: Could not create symlink. Run scripts directly."

# Generate Claude Desktop config
echo "📋 Generating Claude Desktop configuration..."
./scripts/generate-config.sh

echo ""
echo "✅ Himalayas MCP CLI Setup Complete!"
echo ""
echo "🚀 Quick Start Commands:"
echo "  himalayas-mcp start        # Start MCP container"
echo "  himalayas-mcp search-jobs  # Test job search"
echo "  himalayas-mcp config       # Update Claude Desktop config"
echo "  himalayas-mcp stop         # Stop container"
echo "  himalayas-mcp logs         # View logs"
echo ""
echo "📁 Files located at: $INSTALL_DIR/himalayas-mcp-docker"
echo "🐳 Docker image: anixlynch/himalayas-mcp:latest"
echo "🔗 GitHub: https://github.com/anix-lynch/himalayas-mcp-docker"
echo ""
echo "🔐 Remember to set your Doppler secrets:"
echo "  export DOPPLER_TOKEN=your_token_here"
echo "  doppler secrets set GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token"
echo ""
echo "🏔️ Ready to hunt for remote jobs!"
