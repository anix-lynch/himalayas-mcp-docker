FROM node:20-alpine

WORKDIR /app

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git \
    curl \
    bash \
    docker-cli \
    docker-compose

# Install global npm packages
RUN npm install -g \
    @modelcontextprotocol/server-filesystem \
    @modelcontextprotocol/server-github \
    @modelcontextprotocol/server-memory \
    mcp-remote

# Install Python packages for Docker MCP
RUN pip install docker-mcp --break-system-packages || pip install docker-mcp

# Copy package files
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy project files
COPY . .

# Create MCP config directory
RUN mkdir -p /app/config

# Set executable permissions
RUN chmod +x /app/scripts/*.sh || true

# Set environment variables
ENV NODE_ENV=production
ENV MCP_HOME=/app

# Expose ports for both MCP server and OpenAPI server
EXPOSE 3000 5050

# Start both the main MCP server and OpenAPI server
CMD ["sh", "-c", "node openapi-server.js & ./scripts/start-mcp.sh"]
