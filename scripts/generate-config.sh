#!/bin/bash

set -e

echo "🔧 Generating Himalayas MCP Configuration with Docker Hub Support..."

# Create config directory if it doesn't exist
mkdir -p /app/config

# Generate Claude Desktop config with Himalayas MCP + Docker Hub MCP
cat <<EOF > /app/config/claude_desktop_config_himalayas_dockerhub.json
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
    "docker-mcp": {
      "command": "uvx",
      "args": ["docker-mcp"],
      "env": {
        "DOCKER_HOST": "unix:///var/run/docker.sock"
      }
    },
    "docker-hub": {
      "command": "docker",
      "args": [
        "run", 
        "-i", 
        "--rm", 
        "-v", "/var/run/docker.sock:/var/run/docker.sock",
        "mcp/docker"
      ],
      "env": {
        "DOCKER_HUB_USERNAME": "\${DOCKER_HUB_USERNAME}",
        "DOCKER_HUB_TOKEN": "\${DOCKER_HUB_TOKEN}"
      }
    }
  },
  "_profile_info": {
    "name": "Himalayas + Docker Hub Job Hunt Profile",
    "description": "Remote job hunting with Himalayas.app + Docker Hub container management",
    "use_case": "Find remote jobs, manage Docker containers, push/pull images, track applications",
    "servers": [
      "himalayas: Access to remote job listings and company info from https://himalayas.app",
      "docker-mcp: Full Docker operations - containers, images, networks, volumes",
      "docker-hub: Docker Hub integration - search, pull, push, manage repositories",
      "github: Manage job search repositories and documentation", 
      "filesystem: Local file management for resumes/cover letters",
      "memory: Track job applications and interview progress"
    ],
    "docker_hub_features": [
      "Search Docker Hub repositories",
      "Pull and push container images", 
      "Manage Docker Hub repositories",
      "View image details and tags",
      "Monitor download statistics"
    ],
    "docker_operations": [
      "List and manage containers",
      "Build and tag images",
      "Create and manage networks",
      "Handle volumes and data",
      "Monitor container logs"
    ],
    "docker_image": "anixlynch/himalayas-mcp:latest"
  }
}
EOF

echo "✅ Enhanced configuration generated: /app/config/claude_desktop_config_himalayas_dockerhub.json"

# Generate Docker Compose file with Docker Hub MCP
cat <<EOF > /app/config/docker-compose-dockerhub.yml
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
      - DOCKER_HUB_USERNAME=\${DOCKER_HUB_USERNAME}
      - DOCKER_HUB_TOKEN=\${DOCKER_HUB_TOKEN}
    volumes:
      - ./data:/app/data
      - ./config:/app/config
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
    
  # Docker Hub MCP Server
  docker-hub-mcp:
    image: mcp/docker
    container_name: docker-hub-mcp
    environment:
      - DOCKER_HUB_USERNAME=\${DOCKER_HUB_USERNAME}
      - DOCKER_HUB_TOKEN=\${DOCKER_HUB_TOKEN}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
    depends_on:
      - himalayas-mcp

  # Optional: MCP Dashboard
  mcp-dashboard:
    image: nginx:alpine
    container_name: mcp-dashboard
    ports:
      - "8080:80"
    volumes:
      - ./dashboard:/usr/share/nginx/html
    depends_on:
      - himalayas-mcp
      - docker-hub-mcp
    restart: unless-stopped

volumes:
  data:
  config:
EOF

echo "✅ Docker Compose with Docker Hub MCP generated"

# Generate enhanced CLI helper script
cat <<EOF > /app/config/himalayas-dockerhub-cli.sh
#!/bin/bash

# Himalayas + Docker Hub MCP CLI Helper for Mac M4 Pro + Sequoia 15.5

case "\$1" in
  "search-jobs")
    echo "🔍 Searching jobs on Himalayas..."
    docker run --rm -e DOPPLER_TOKEN=\$DOPPLER_TOKEN anixlynch/himalayas-mcp:latest npx mcp-remote https://mcp.himalayas.app/sse
    ;;
  "search-images")
    echo "🐳 Searching Docker Hub images..."
    docker search "\$2" --limit 25
    ;;
  "pull-image")
    echo "📥 Pulling Docker image: \$2"
    docker pull "\$2"
    ;;
  "push-image")
    echo "📤 Pushing Docker image: \$2"
    docker push "\$2"
    ;;
  "start")
    echo "🚀 Starting Himalayas + Docker Hub MCP containers..."
    docker-compose -f /app/config/docker-compose-dockerhub.yml up -d
    ;;
  "stop")
    echo "🛑 Stopping MCP containers..."
    docker-compose -f /app/config/docker-compose-dockerhub.yml down
    ;;
  "logs")
    echo "📋 Showing container logs..."
    docker logs himalayas-mcp -f
    ;;
  "docker-logs")
    echo "📋 Showing Docker Hub MCP logs..."
    docker logs docker-hub-mcp -f
    ;;
  "config")
    echo "📂 Copying config to Claude Desktop..."
    cp /app/config/claude_desktop_config_himalayas_dockerhub.json ~/Library/Application\\ Support/Claude/claude_desktop_config.json
    echo "✅ Configuration updated. Restart Claude Desktop."
    ;;
  "status")
    echo "📊 MCP Services Status:"
    echo "Himalayas MCP: \$(docker ps --filter name=himalayas-mcp --format 'table {{.Status}}')"
    echo "Docker Hub MCP: \$(docker ps --filter name=docker-hub-mcp --format 'table {{.Status}}')"
    ;;
  *)
    echo "Usage: \$0 {search-jobs|search-images|pull-image|push-image|start|stop|logs|docker-logs|config|status}"
    echo ""
    echo "Commands:"
    echo "  search-jobs           - Test Himalayas job search"
    echo "  search-images <term>  - Search Docker Hub for images"
    echo "  pull-image <image>    - Pull image from Docker Hub"
    echo "  push-image <image>    - Push image to Docker Hub"
    echo "  start                 - Start all MCP containers"
    echo "  stop                  - Stop all MCP containers"
    echo "  logs                  - View Himalayas MCP logs"
    echo "  docker-logs           - View Docker Hub MCP logs"
    echo "  config                - Update Claude Desktop config"
    echo "  status                - Show all services status"
    echo ""
    echo "Examples:"
    echo "  \$0 search-images 'node'"
    echo "  \$0 pull-image 'mcp/memory'"
    echo "  \$0 push-image 'anixlynch/my-app:latest'"
    ;;
esac
EOF

chmod +x /app/config/himalayas-dockerhub-cli.sh

echo "✅ Enhanced CLI helper script generated: /app/config/himalayas-dockerhub-cli.sh"

# Generate Docker Hub MCP specific configuration for different scenarios
cat <<EOF > /app/config/docker-hub-mcp-standalone.json
{
  "mcpServers": {
    "docker-hub": {
      "command": "docker",
      "args": [
        "run", 
        "-i", 
        "--rm", 
        "-v", "/var/run/docker.sock:/var/run/docker.sock",
        "mcp/docker"
      ],
      "env": {
        "DOCKER_HUB_USERNAME": "\${DOCKER_HUB_USERNAME}",
        "DOCKER_HUB_TOKEN": "\${DOCKER_HUB_TOKEN}"
      }
    }
  },
  "_docker_hub_capabilities": {
    "search": "Search Docker Hub repositories and images",
    "pull": "Pull images from Docker Hub to local machine",
    "push": "Push local images to Docker Hub repositories", 
    "manage": "Manage Docker Hub repositories and tags",
    "monitor": "Monitor image downloads and statistics",
    "authenticate": "Secure authentication with Docker Hub"
  }
}
EOF

echo "✅ Docker Hub MCP standalone config generated"
echo "🏔️ Himalayas + Docker Hub MCP configuration complete!"
echo ""
echo "🐳 Docker Hub MCP Features:"
echo "  - Search Docker Hub repositories"
echo "  - Pull/push container images"
echo "  - Manage repositories and tags"
echo "  - Monitor image statistics"
echo "  - Secure authentication"
echo ""
echo "🔧 Setup your Docker Hub credentials:"
echo "  export DOCKER_HUB_USERNAME=your_username"
echo "  export DOCKER_HUB_TOKEN=your_access_token"