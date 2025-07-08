#!/bin/bash

set -e

echo "🔧 Generating Enhanced Himalayas MCP Configuration with API Gateway Fallback..."

# Create config directory if it doesn't exist
mkdir -p /app/config

# Generate Claude Desktop config with full MCP stack + API Gateway
cat <<EOF > /app/config/claude_desktop_config_god_mode.json
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
    },
    "api-gateway": {
      "command": "uvx",
      "args": ["mcp-api-gateway"],
      "env": {
        "mcp-api-gateway.api_1_name": "himalayas-fallback",
        "mcp-api-gateway.api_1_swagger_url": "http://host.docker.internal:5050/himalayas-openapi.json",
        "mcp-api-gateway.api_1_header_authorization": ""
      }
    },
    "desktop-commander": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-desktop-commander"],
      "env": {}
    }
  },
  "_profile_info": {
    "name": "Himalayas God Mode - Full MCP Stack",
    "description": "Complete remote job hunting with full MCP arsenal + API fallback",
    "use_case": "Find remote jobs, manage Docker/GitHub, execute commands, API fallback when MCP fails",
    "servers": [
      "himalayas: Primary remote job listings from https://mcp.himalayas.app/sse",
      "api-gateway: Fallback API access via http://localhost:5050/himalayas-openapi.json",
      "docker-mcp: Full Docker operations - containers, images, networks, volumes",
      "docker-hub: Docker Hub integration - search, pull, push, manage repositories",
      "github: GitHub repository management and operations",
      "desktop-commander: Execute system commands and scripts",
      "filesystem: Local file management for resumes/cover letters",
      "memory: Track job applications and interview progress"
    ],
    "fallback_strategy": {
      "primary": "Himalayas MCP server (mcp.himalayas.app/sse)",
      "secondary": "API Gateway with local OpenAPI spec (localhost:5050)",
      "tertiary": "Direct API calls via axios/fetch in custom tools"
    },
    "api_gateway_features": [
      "Automatic fallback when MCP server unavailable",
      "OpenAPI spec hosted locally on port 5050",
      "Swagger UI available at /swagger-ui",
      "Rate limiting and error handling"
    ],
    "docker_image": "anixlynch/himalayas-mcp:latest",
    "ports": {
      "mcp_server": 3000,
      "openapi_server": 5050
    }
  }
}
EOF

echo "✅ God Mode configuration generated: /app/config/claude_desktop_config_god_mode.json"

# Generate startup script for both services
cat <<EOF > /app/config/start-full-stack.sh
#!/bin/bash

set -e

echo "🚀 Starting Himalayas Full Stack (MCP + API Gateway)"

# Start OpenAPI server in background
echo "📋 Starting OpenAPI server on port 5050..."
node /app/openapi-server.js &
OPENAPI_PID=\$!

# Wait for OpenAPI server to be ready
sleep 3

# Test OpenAPI server
if curl -s http://localhost:5050/health > /dev/null; then
    echo "✅ OpenAPI server ready at http://localhost:5050"
else
    echo "⚠️ OpenAPI server may not be ready, continuing anyway..."
fi

# Start main MCP stack
echo "🏔️ Starting MCP servers..."
/app/scripts/start-mcp.sh &
MCP_PID=\$!

echo "📊 Service PIDs:"
echo "  OpenAPI Server: \$OPENAPI_PID"
echo "  MCP Stack: \$MCP_PID"

# Keep both services running
wait \$MCP_PID
EOF

chmod +x /app/config/start-full-stack.sh

# Generate API Gateway specific config
cat <<EOF > /app/config/api-gateway-standalone.json
{
  "mcpServers": {
    "api-gateway": {
      "command": "uvx",
      "args": ["mcp-api-gateway"],
      "env": {
        "mcp-api-gateway.api_1_name": "himalayas-fallback",
        "mcp-api-gateway.api_1_swagger_url": "http://host.docker.internal:5050/himalayas-openapi.json",
        "mcp-api-gateway.api_1_header_authorization": ""
      }
    }
  },
  "_api_gateway_config": {
    "purpose": "Fallback API access for Himalayas when MCP server is unavailable",
    "endpoints": {
      "jobs": "GET /jobs/api - List remote jobs with pagination",
      "companies": "GET /companies/api - List companies offering remote work"
    },
    "local_server": "http://localhost:5050/himalayas-openapi.json",
    "docker_internal": "http://host.docker.internal:5050/himalayas-openapi.json"
  }
}
EOF

echo "✅ API Gateway config generated"
echo "🏔️ Enhanced Himalayas MCP configuration complete!"
echo ""
echo "🎯 Available Configurations:"
echo "  1. claude_desktop_config_god_mode.json - Full MCP stack with API fallback"
echo "  2. api-gateway-standalone.json - API Gateway only for testing"
echo ""
echo "🚀 Services:"
echo "  Port 3000: Main MCP server"
echo "  Port 5050: OpenAPI specification server"
echo ""
echo "🔧 API Gateway Setup:"
echo "  Name: himalayas-fallback"
echo "  Swagger URL: http://host.docker.internal:5050/himalayas-openapi.json"
echo "  Purpose: Fallback when mcp.himalayas.app/sse is unavailable"