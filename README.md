# Himalayas + Docker Hub MCP 🏔️🐳

Dockerized Himalayas MCP server with Docker Hub integration for remote job hunting and container management automation via Claude Desktop.

## Features

- **🏔️ Himalayas MCP Integration**: Direct access to remote job listings from https://himalayas.app
- **🐳 Docker Hub MCP**: Search, pull, push, and manage Docker Hub repositories
- **🐙 GitHub Integration**: Manage job search repos and documentation  
- **📁 Filesystem Access**: Local resume/cover letter management
- **🧠 Memory Tracking**: Track applications and interview progress
- **🔐 Doppler Secrets**: Secure credential management

## Quick Start

```bash
# 1. Clone and build
git clone https://github.com/anix-lynch/himalayas-mcp-docker.git
cd himalayas-mcp-docker
docker build -t anixlynch/himalayas-mcp:latest .

# 2. Set up Docker Hub credentials
export DOCKER_HUB_USERNAME=your_username
export DOCKER_HUB_TOKEN=your_access_token

# 3. Configure Claude Desktop
./scripts/generate-config.sh
cp config/claude_desktop_config_himalayas_dockerhub.json ~/Library/Application\ Support/Claude/claude_desktop_config.json

# 4. Test the setup
docker run -p 3000:3000 -v /var/run/docker.sock:/var/run/docker.sock anixlynch/himalayas-mcp:latest
```

## MCP Servers Included

- **Himalayas**: `https://mcp.himalayas.app/sse`
- **Docker Hub**: `mcp/docker` - Official Docker MCP server
- **Docker MCP**: `uvx docker-mcp` - Docker operations server
- **GitHub**: `@modelcontextprotocol/server-github`
- **Filesystem**: `@modelcontextprotocol/server-filesystem`
- **Memory**: `@modelcontextprotocol/server-memory`

## Docker Hub MCP Capabilities

### 🔍 Search & Discovery
- Search Docker Hub repositories by keyword
- Filter by official images, stars, pulls
- Get detailed image information and tags

### 📥📤 Image Management  
- Pull images from Docker Hub to local machine
- Push local images to Docker Hub repositories
- Manage image tags and versions

### 🏪 Repository Operations
- Create and manage Docker Hub repositories
- View repository statistics and download counts
- Configure automated builds and webhooks

### 🔐 Authentication
- Secure authentication with Docker Hub API
- Support for personal access tokens
- Enterprise registry integration

## Claude Desktop Configuration

```json
{
  "mcpServers": {
    "himalayas": {
      "command": "npx",
      "args": ["mcp-remote", "https://mcp.himalayas.app/sse"]
    },
    "docker-hub": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "/var/run/docker.sock:/var/run/docker.sock",
        "mcp/docker"
      ],
      "env": {
        "DOCKER_HUB_USERNAME": "${DOCKER_HUB_USERNAME}",
        "DOCKER_HUB_TOKEN": "${DOCKER_HUB_TOKEN}"
      }
    }
  }
}
```

## Example Claude Queries

### Job Hunting with Himalayas
```
🏔️ "Search for remote software engineering jobs on Himalayas"
🌍 "Find remote jobs in Europe that accept US candidates"
🚀 "Show me remote startup jobs with equity compensation"
```

### Docker Hub Operations
```
🔍 "Search Docker Hub for Node.js images"
📥 "Pull the latest Redis image from Docker Hub"
📤 "Push my-app:latest to Docker Hub"
🏪 "Show me the most popular Python images on Docker Hub"
```

### Combined Workflow
```
💼 "Search for DevOps remote jobs and find Docker images I might need"
🔄 "Find remote jobs at companies that use microservices and pull relevant container images"
```

## Environment Variables

Set these in Doppler or environment:

```bash
# Required for GitHub integration
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token

# Required for Docker Hub integration  
DOCKER_HUB_USERNAME=your_dockerhub_username
DOCKER_HUB_TOKEN=your_dockerhub_access_token

# Optional for secrets management
DOPPLER_TOKEN=your_doppler_token
```

## CLI Commands

Use the enhanced CLI helper:

```bash
# Job hunting
./config/himalayas-dockerhub-cli.sh search-jobs

# Docker Hub operations
./config/himalayas-dockerhub-cli.sh search-images "node"
./config/himalayas-dockerhub-cli.sh pull-image "mcp/memory"
./config/himalayas-dockerhub-cli.sh push-image "anixlynch/my-app:latest"

# Container management
./config/himalayas-dockerhub-cli.sh start
./config/himalayas-dockerhub-cli.sh status
./config/himalayas-dockerhub-cli.sh logs
```

## API Endpoints

Test the server directly:

- `GET /health`: Container health and feature check
- `GET /mcp/status`: MCP server connectivity status
- `GET /api/docker/images`: List local Docker images
- `GET /api/docker/containers`: List Docker containers
- `POST /api/docker/search`: Search Docker Hub repositories
- `GET /api/config`: Configuration and capabilities info

## Job Hunt + DevOps Workflow

1. **🔍 Search**: Use Himalayas MCP to find remote DevOps/SRE jobs
2. **🐳 Prepare**: Pull relevant Docker images for interview prep
3. **📝 Track**: Store applications and technical requirements in memory
4. **🚀 Deploy**: Push portfolio projects to Docker Hub
5. **📊 Monitor**: Track application status and technical progress

## Mac M4 Pro + Sequoia 15.5 Setup

Optimized for Apple Silicon:

```bash
# 1. Install Docker Desktop for Mac (Apple Silicon)
# 2. Enable Docker BuildKit
export DOCKER_BUILDKIT=1

# 3. Build multi-platform image
docker buildx build --platform linux/amd64,linux/arm64 -t anixlynch/himalayas-mcp:latest .

# 4. Run with proper socket binding
docker run -p 3000:3000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e DOCKER_HUB_USERNAME=$DOCKER_HUB_USERNAME \
  -e DOCKER_HUB_TOKEN=$DOCKER_HUB_TOKEN \
  anixlynch/himalayas-mcp:latest
```

## Docker Compose Deployment

```bash
# Start full stack
docker-compose -f config/docker-compose-dockerhub.yml up -d

# View logs
docker-compose logs -f

# Stop stack
docker-compose down
```

## Security & Best Practices

- 🔐 Use Docker Hub personal access tokens (not passwords)
- 🔒 Store secrets in Doppler or secure environment variables
- 🛡️ Run containers with non-root users where possible
- 📊 Monitor container resource usage
- 🔍 Regularly update base images for security patches

## Troubleshooting

### Docker Socket Issues
```bash
# Fix permissions on Mac
sudo chown $USER /var/run/docker.sock
```

### Docker Hub Authentication
```bash
# Test authentication
docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_TOKEN
```

### MCP Connection Issues
```bash
# Test Himalayas MCP
curl -H "Accept: text/event-stream" https://mcp.himalayas.app/sse

# Test Docker daemon
docker info
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Test with both Himalayas and Docker Hub MCP
4. Submit a pull request

## Links

- 🏔️ **Himalayas**: https://himalayas.app
- 🐳 **Docker Hub**: https://hub.docker.com/r/anixlynch/himalayas-mcp
- 🐙 **GitHub**: https://github.com/anix-lynch/himalayas-mcp-docker
- 📚 **MCP Docs**: https://docs.docker.com/mcp/
- 🔧 **Docker MCP**: https://github.com/docker/mcp-servers

Built for comprehensive remote job hunting with modern container workflows.