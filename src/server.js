const express = require('express');
const axios = require('axios');
const winston = require('winston');
require('dotenv').config();

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
    service: 'himalayas-mcp-docker',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV
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
    
    res.json({
      himalayas_mcp: 'connected',
      status: 'operational',
      last_check: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Himalayas MCP connection check failed', error);
    res.status(503).json({
      himalayas_mcp: 'disconnected',
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
    
    // This would proxy to Himalayas API if needed
    // For now, return a mock response indicating MCP usage
    res.json({
      message: 'Use Himalayas MCP server via Claude Desktop for job searches',
      mcp_endpoint: 'https://mcp.himalayas.app/sse',
      instructions: 'Connect via npx mcp-remote https://mcp.himalayas.app/sse'
    });
  } catch (error) {
    logger.error('Job search error', error);
    res.status(500).json({ error: 'Job search failed' });
  }
});

// Configuration endpoint
app.get('/api/config', (req, res) => {
  res.json({
    mcp_servers: {
      himalayas: 'https://mcp.himalayas.app/sse',
      github: '@modelcontextprotocol/server-github',
      filesystem: '@modelcontextprotocol/server-filesystem',
      memory: '@modelcontextprotocol/server-memory'
    },
    docker_image: 'anixlynch/himalayas-mcp:latest',
    documentation: 'https://github.com/anix-lynch/himalayas-mcp-docker'
  });
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
  logger.info(`🏔️ Himalayas MCP Docker server running on port ${port}`);
  logger.info('🚀 Ready to connect to Himalayas MCP server');
});

module.exports = app;