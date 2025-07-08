# Himalayas MCP Docker 🏔️

Dockerized Himalayas MCP server for remote job hunting automation with Claude Desktop integration.

## Quick Start

```bash
# Build and run
docker build -t anixlynch/himalayas-mcp:latest .
docker run -p 3000:3000 -e DOPPLER_TOKEN=$DOPPLER_TOKEN anixlynch/himalayas-mcp:latest

# Or use CLI helper
./config/himalayas-cli.sh start
```

## Features

- **🏔️ Himalayas MCP Integration**: Direct access to remote job listings
- **🐙 GitHub Integration**: Manage job search repos and documentation  
- **📁 Filesystem Access**: Local resume/cover letter management
- **🧠 Memory Tracking**: Track applications and interview progress
- **🐳 Docker Support**: Containerized MCP servers
- **🔐 Doppler Secrets**: Secure credential management

## MCP Servers Included

- **Himalayas**: `https://mcp.himalayas.app/sse`
- **GitHub**: `@modelcontextprotocol/server-github`
- **Filesystem**: `@modelcontextprotocol/server-filesystem`
- **Memory**: `@modelcontextprotocol/server-memory`
- **Docker**: `@modelcontextprotocol/server-docker`

## Mac M4 Pro + Sequoia 15.5 Setup

```bash
# 1. Clone and build
git clone https://github.com/anix-lynch/himalayas-mcp-docker.git
cd himalayas-mcp-docker
docker build -t anixlynch/himalayas-mcp:latest .

# 2. Configure Claude Desktop
./config/himalayas-cli.sh config

# 3. Start container
./config/himalayas-cli.sh start

# 4. Test job search
./config/himalayas-cli.sh search-jobs
```

## Environment Variables

Set in Doppler:
- `GITHUB_PERSONAL_ACCESS_TOKEN`: GitHub API access
- `DOPPLER_TOKEN`: For secret management

## Claude Desktop Configuration

```json
{
  "mcpServers": {
    "himalayas": {
      "command": "npx",
      "args": ["mcp-remote", "https://mcp.himalayas.app/sse"]
    }
  }
}
```

## Docker Hub

Image: `anixlynch/himalayas-mcp:latest`

## API Endpoints

- `GET /health`: Container health check
- `GET /mcp/status`: MCP server connectivity
- `GET /api/config`: Configuration info

## Job Hunt Workflow

1. **Search**: Use Himalayas MCP to find remote jobs
2. **Track**: Store applications in memory/filesystem
3. **Manage**: Update resumes via GitHub
4. **Monitor**: Check application status

## CLI Commands

```bash
./config/himalayas-cli.sh {search-jobs|start|stop|logs|config}
```

Built for anixlynch's job hunt automation workflow.