# 🏔️ himalayas-mcp-docker (Fallback-Free)

This is a minimal Claude MCP helper Docker image. It does **not** include Swagger or API Gateway fallback.

## ✅ Includes

- MCP-compatible base server
- No Swagger fallback
- No api-gateway
- For direct use with Claude's `mcp.himalayas.app/sse`

## 🐳 Usage

Build:
docker build -t himalayas-mcp .

Run:
docker run --rm -it himalayas-mcp

## 👷 Next Steps

Add your own MCP tools via index.js or extend with Claude-compatible APIs.
