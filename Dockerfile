FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY index.js .

FROM node:22-alpine
WORKDIR /app
COPY --from=builder /app /app
RUN addgroup -S mcpuser && adduser -S mcpuser -G mcpuser
USER mcpuser
CMD ["node", "index.js"]
