# Typing-Mind Docker Configuration

This directory contains Docker configuration for running the Typing-Mind MCP service.

## Configuration

The service can be configured using the following environment variables:

- `PORT`: The port to expose the service on (default: 8080)
- `MCP_TOKEN`: Your authentication token for the service

## Usage

### Basic Usage

Run with default configuration:
```bash
docker-compose up
```

### Custom Configuration

Run with custom port and token:
```bash
PORT=3000 MCP_TOKEN=your_token_here docker-compose up
```

### Environment File

Alternatively, create a `.env` file in this directory:
```
PORT=8080
MCP_TOKEN=your_token_here
```

Then run:
```bash
docker-compose up
```

## Files

- `Dockerfile`: Defines the container image with Node.js and the MCP package
- `docker-compose.yml`: Defines the service configuration and environment 