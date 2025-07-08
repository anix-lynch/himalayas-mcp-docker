#!/bin/bash

set -e

echo "🔧 Generating Himalayas MCP Configuration..."

# Create config directory if it doesn't exist
mkdir -p /app/config

# Generate Claude Desktop config with Himalayas MCP
cat <<EOF > /app/config/claude_desktop_config_himalayas.json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/app"],
      "env": {}
    },
    "github": {
      "command": "npx", 
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "\${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {}
    },
    "himalayas": {
      "command": "npx",
      "args": ["mcp-remote", "https://mcp.himalayas.app/sse"],
      "env": {}
    },
    "docker": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-docker"],
      "env": {}
    }
  },
  "_profile_info": {
    "name": "Himalayas Job Hunt Profile",
    "description": "Remote job hunting with Himalayas.app integration",
    "use_case": "Find remote jobs, track applications, manage job search workflow",
    "servers": [
      "himalayas: Access to remote job listings and company info",
      "github: Manage job search repositories and documentation", 
      "filesystem: Local file management for resumes/cover letters",
      "memory: Track job applications and interview progress",
      "docker: Container management for development environments"
    ],
    "docker_image": "anixlynch/himalayas-mcp:latest"
  }
}
EOF

echo "✅ Configuration generated: /app/config/claude_desktop_config_himalayas.json"

# Generate Docker Compose file for easy deployment
cat <<EOF > /app/config/docker-compose.yml
version: '3.8'

services:
  himalayas-mcp:
    image: anixlynch/himalayas-mcp:latest
    container_name: himalayas-mcp
    ports:
      - "3000:3000"
    environment:
      - DOPPLER_TOKEN=\${DOPPLER_TOKEN}
      - NODE_ENV=production
    volumes:
      - ./data:/app/data
      - ./config:/app/config
    restart: unless-stopped
    
  # Optional: Add a simple web interface
  mcp-dashboard:
    image: nginx:alpine
    container_name: mcp-dashboard
    ports:
      - "8080:80"
    volumes:
      - ./dashboard:/usr/share/nginx/html
    depends_on:
      - himalayas-mcp
    restart: unless-stopped

volumes:
  data:
  config:
EOF

echo "✅ Docker Compose configuration generated"

# Generate CLI helper script
cat <<EOF > /app/config/himalayas-cli.sh
#!/bin/bash

# Himalayas MCP CLI Helper for Mac M4 Pro + Sequoia 15.5

case "\$1" in
  "search-jobs")
    echo "🔍 Searching jobs on Himalayas..."
    docker run --rm -e DOPPLER_TOKEN=\$DOPPLER_TOKEN anixlynch/himalayas-mcp:latest npx mcp-remote https://mcp.himalayas.app/sse
    ;;
  "start")
    echo "🚀 Starting Himalayas MCP container..."
    docker-compose -f /app/config/docker-compose.yml up -d
    ;;
  "stop")
    echo "🛑 Stopping Himalayas MCP container..."
    docker-compose -f /app/config/docker-compose.yml down
    ;;
  "logs")
    echo "📋 Showing container logs..."
    docker logs himalayas-mcp -f
    ;;
  "config")
    echo "📂 Copying config to Claude Desktop..."
    cp /app/config/claude_desktop_config_himalayas.json ~/Library/Application\ Support/Claude/claude_desktop_config.json
    echo "✅ Configuration updated. Restart Claude Desktop."
    ;;
  *)
    echo "Usage: \$0 {search-jobs|start|stop|logs|config}"
    echo ""
    echo "Commands:"
    echo "  search-jobs - Test Himalayas job search"
    echo "  start       - Start MCP container"
    echo "  stop        - Stop MCP container"
    echo "  logs        - View container logs"
    echo "  config      - Update Claude Desktop config"
    ;;
esac
EOF

chmod +x /app/config/himalayas-cli.sh

echo "✅ CLI helper script generated: /app/config/himalayas-cli.sh"
echo "🏔️ Himalayas MCP configuration complete!"