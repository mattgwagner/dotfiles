FROM node:20-slim

WORKDIR /app

# Install the package globally
RUN npm install -g @typingmind/mcp

# Set environment variables
ENV PORT=8080
ENV MCP_TOKEN=""

# Command to run
CMD ["sh", "-c", "npx @typingmind/mcp $MCP_TOKEN"] 