const express = require('express');
const axios = require('axios');
const winston = require('winston');
const Docker = require('dockerode');
require('dotenv').config();

// Setup Docker client
const docker = new Docker();

// Setup logging
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: '/app/logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: '/app/logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'himalayas-mcp-docker-hub',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    features: ['himalayas', 'docker-hub', 'github', 'filesystem', 'memory']
  });
});

// MCP server status endpoint
app.get('/mcp/status', async (req, res) => {
  try {
    // Check if Himalayas MCP is accessible
    const himalayasCheck = await axios.get('https://mcp.himalayas.app/sse', {
      timeout: 5000,
      headers: {
        'Accept': 'text/event-stream'
      }
    });
    
    // Check Docker daemon
    const dockerInfo = await docker.info();
    
    res.json({
      himalayas_mcp: 'connected',
      docker_daemon: 'connected',
      docker_info: {
        containers: dockerInfo.Containers,
        images: dockerInfo.Images,
        version: dockerInfo.ServerVersion
      },
      status: 'operational',
      last_check: new Date().toISOString()
    });
  } catch (error) {
    logger.error('MCP connection check failed', error);
    res.status(503).json({
      himalayas_mcp: error.message.includes('himalayas') ? 'disconnected' : 'unknown',
      docker_daemon: error.message.includes('docker') ? 'disconnected' : 'unknown',
      status: 'error',
      error: error.message,
      last_check: new Date().toISOString()
    });
  }
});

// Job search proxy endpoint (for testing)
app.post('/api/jobs/search', async (req, res) => {
  try {
    const { query, location, remote_only } = req.body;
    
    logger.info('Job search request', { query, location, remote_only });
    
    res.json({
      message: 'Use Himalayas MCP server via Claude Desktop for job searches',
      mcp_endpoint: 'https://mcp.himalayas.app/sse',
      instructions: 'Connect via npx mcp-remote https://mcp.himalayas.app/sse',
      example_queries: [
        'Search for remote software engineering jobs',
        'Find remote jobs in Europe',
        'Show me remote jobs at startups'
      ]
    });
  } catch (error) {
    logger.error('Job search error', error);
    res.status(500).json({ error: 'Job search failed' });
  }
});

// Docker Hub API endpoints
app.get('/api/docker/images', async (req, res) => {
  try {
    const images = await docker.listImages();
    res.json({
      count: images.length,
      images: images.map(img => ({
        id: img.Id.slice(0, 12),
        tags: img.RepoTags,
        size: Math.round(img.Size / 1024 / 1024) + ' MB',
        created: new Date(img.Created * 1000).toISOString()
      }))
    });
  } catch (error) {
    logger.error('Docker images list error', error);
    res.status(500).json({ error: 'Failed to list Docker images' });
  }
});

app.get('/api/docker/containers', async (req, res) => {
  try {
    const containers = await docker.listContainers({ all: true });
    res.json({
      count: containers.length,
      containers: containers.map(container => ({
        id: container.Id.slice(0, 12),
        name: container.Names[0].replace('/', ''),
        image: container.Image,
        status: container.Status,
        state: container.State,
        ports: container.Ports
      }))
    });
  } catch (error) {
    logger.error('Docker containers list error', error);
    res.status(500).json({ error: 'Failed to list Docker containers' });
  }
});

app.post('/api/docker/search', async (req, res) => {
  try {
    const { term, limit = 25 } = req.body;
    
    if (!term) {
      return res.status(400).json({ error: 'Search term is required' });
    }
    
    logger.info('Docker Hub search request', { term, limit });
    
    // Use Docker Hub API for search
    const searchResponse = await axios.get(`https://registry.hub.docker.com/v2/search/repositories/`, {
      params: {
        query: term,
        page_size: limit
      },
      timeout: 10000
    });
    
    res.json({
      term: term,
      count: searchResponse.data.count,
      results: searchResponse.data.results.map(repo => ({
        name: repo.repo_name,
        description: repo.short_description,
        stars: repo.star_count,
        pulls: repo.pull_count,
        is_official: repo.is_official,
        is_automated: repo.is_automated
      }))
    });
  } catch (error) {
    logger.error('Docker Hub search error', error);
    res.status(500).json({ error: 'Docker Hub search failed' });
  }
});

app.post('/api/docker/pull', async (req, res) => {
  try {
    const { image } = req.body;
    
    if (!image) {
      return res.status(400).json({ error: 'Image name is required' });
    }
    
    logger.info('Docker pull request', { image });
    
    res.json({
      message: `Pulling image: ${image}`,
      status: 'initiated',
      note: 'Use Docker MCP server via Claude Desktop for actual pull operations'
    });
  } catch (error) {
    logger.error('Docker pull error', error);
    res.status(500).json({ error: 'Docker pull failed' });
  }
});

// Configuration endpoint
app.get('/api/config', (req, res) => {
  res.json({
    mcp_servers: {
      himalayas: 'https://mcp.himalayas.app/sse',
      docker_mcp: 'uvx docker-mcp',
      docker_hub: 'mcp/docker',
      github: '@modelcontextprotocol/server-github',
      filesystem: '@modelcontextprotocol/server-filesystem',
      memory: '@modelcontextprotocol/server-memory'
    },
    docker_hub_features: [
      'Search Docker Hub repositories',
      'Pull images from Docker Hub',
      'Push images to Docker Hub',
      'Manage repositories and tags',
      'View image details and statistics'
    ],
    docker_operations: [
      'List local containers and images',
      'Start/stop containers',
      'Build images from Dockerfile',
      'Manage Docker networks and volumes',
      'View container logs and stats'
    ],
    docker_image: 'anixlynch/himalayas-mcp:latest',
    documentation: 'https://github.com/anix-lynch/himalayas-mcp-docker'
  });
});

// Docker Hub webhook endpoint (for future use)
app.post('/api/webhook/dockerhub', (req, res) => {
  try {
    const { repository, push_data } = req.body;
    
    logger.info('Docker Hub webhook received', { 
      repo: repository?.repo_name,
      tag: push_data?.tag 
    });
    
    res.json({ 
      status: 'webhook received',
      message: 'Docker Hub webhook processed successfully'
    });
  } catch (error) {
    logger.error('Docker Hub webhook error', error);
    res.status(500).json({ error: 'Webhook processing failed' });
  }
});

// Error handling middleware
app.use((error, req, res, next) => {
  logger.error('Unhandled error', error);
  res.status(500).json({ error: 'Internal server error' });
});

// Create logs directory
const fs = require('fs');
if (!fs.existsSync('/app/logs')) {
  fs.mkdirSync('/app/logs', { recursive: true });
}

app.listen(port, () => {
  logger.info(`🏔️ Himalayas + Docker Hub MCP server running on port ${port}`);
  logger.info('🚀 Ready to connect to Himalayas MCP and Docker Hub');
  logger.info('🐳 Docker Hub features: search, pull, push, manage');
  logger.info('🔍 Job hunting features: remote job search via Himalayas.app');
});

module.exports = app;