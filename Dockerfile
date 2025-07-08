FROM node:20-alpine

WORKDIR /app

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git \
    curl \
    bash \
    doppler

# Install global npm packages
RUN npm install -g \
    @modelcontextprotocol/server-filesystem \
    @modelcontextprotocol/server-github \
    @modelcontextprotocol/server-memory \
    mcp-remote

# Copy package files
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy project files
COPY . .

# Create MCP config directory
RUN mkdir -p /app/config

# Set executable permissions
RUN chmod +x /app/scripts/*.sh

# Set environment variables
ENV NODE_ENV=production
ENV MCP_HOME=/app
ENV DOPPLER_TOKEN=${DOPPLER_TOKEN}

# Expose port for MCP server
EXPOSE 3000

# Default command runs the Himalayas MCP setup
CMD ["./scripts/start-mcp.sh"]
