# Jaeger Tracing Windows Container

## Overview

This project provides a containerized version of [Jaeger](https://www.jaegertracing.io/), an open-source distributed tracing system, running on Windows containers. Jaeger is used for monitoring and troubleshooting microservices-based distributed systems.

## What It Does

Jaeger helps you:
- Monitor and troubleshoot transactions in complex distributed systems
- Track request flows across multiple services
- Identify performance bottlenecks
- Analyze service dependencies
- Debug latency issues in microservices architectures

This container runs Jaeger in "all-in-one" mode, which includes all Jaeger backend components (agent, collector, query service, and UI) in a single process.

## Container Details

### Base Images

Two Dockerfile options are provided:

- **dockerfile**: Uses `mcr.microsoft.com/windows/servercore:ltsc2022` (larger, more compatible)
- **dockerfile-nano**: Uses `mcr.microsoft.com/windows/nanoserver:ltsc2025` (smaller, more lightweight)

The docker-compose configuration uses the nano version by default.

### Exposed Ports

The container exposes the following ports:

| Port  | Protocol | Description                                    |
|-------|----------|------------------------------------------------|
| 6831  | UDP      | Jaeger agent - compact Thrift protocol        |
| 6832  | UDP      | Jaeger agent - binary Thrift protocol         |
| 5778  | HTTP     | Agent configuration server                     |
| 16686 | HTTP     | Jaeger UI and Query service                    |
| 14268 | HTTP     | Jaeger collector - accepts spans via HTTP     |
| 14250 | gRPC     | Jaeger collector - accepts spans via gRPC     |
| 9411  | HTTP     | Zipkin compatible endpoint                     |

### Directory Structure

```
.
├── docker-compose.yaml          # Docker Compose configuration
├── dockerfile                   # Dockerfile using Server Core base image
├── dockerfile-nano              # Dockerfile using Nano Server base image
├── README.md                    # This file
└── setup/
    ├── jaeger.exe              # Jaeger executable for Windows
    ├── all-in-one.yaml         # Jaeger configuration file
    └── config.yaml             # Additional configuration (if needed)
```

## Prerequisites

- Docker Desktop for Windows with Windows containers enabled
- Windows 10/11 or Windows Server 2019/2022
- Jaeger executable for Windows (v2.12.0 or compatible)

## Setup Instructions

### 1. Download Jaeger

Download the Jaeger binary for Windows:

```powershell
# Download from official Jaeger releases
# https://download.jaegertracing.io/v1.75.0/jaeger-2.12.0-windows-amd64.tar.gz
```

Extract `jaeger.exe` and place it in the `setup/` directory.

### 1b. Download OpenSearch binary for windows

Download the OpenSearch binary for Windows:

```powershell
# Download official OpenSearch binary
# https://artifacts.opensearch.org/releases/bundle/opensearch/3.3.2/opensearch-3.3.2-windows-x64.zip
```

### 2. Configuration

The container uses `setup/all-in-one.yaml` for Jaeger configuration. You can customize this file to adjust Jaeger's behavior, storage options, and other settings.

### 3. Build and Run

#### Using Docker Compose (Recommended)

```powershell
# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

#### Using Docker CLI

```powershell
# Build the image
docker build -t jaegertracing_win -f dockerfile-nano .

# Run the container
docker run -d `
  --name jaegertracing_win `
  -p 6831:6831/udp `
  -p 6832:6832/udp `
  -p 5778:5778 `
  -p 16686:16686 `
  -p 14268:14268 `
  -p 14250:14250 `
  -p 9411:9411 `
  jaegertracing_win
```

## Usage

### Access the Jaeger UI

Once the container is running, access the Jaeger UI at:

```
http://localhost:16686
```

The UI allows you to:
- Search and view traces
- Analyze service dependencies
- Compare traces
- View system architecture

### Send Traces to Jaeger

Configure your applications to send traces to Jaeger using one of the following endpoints:

- **Agent (UDP)**: `localhost:6831` or `localhost:6832`
- **Collector (HTTP)**: `http://localhost:14268/api/traces`
- **Collector (gRPC)**: `localhost:14250`
- **Zipkin compatible**: `http://localhost:9411/api/v2/spans`

### Example: Sending a Test Trace

You can use Jaeger's client libraries in various languages (Go, Java, Python, Node.js, etc.) to instrument your applications.

## Troubleshooting

### Container won't start

1. Ensure Docker is set to Windows containers mode
2. Verify `setup/jaeger.exe` exists
3. Check logs: `docker-compose logs`

### Cannot access Jaeger UI

1. Verify the container is running: `docker ps`
2. Check port bindings: `docker port jaegertracing_win`
3. Ensure no firewall rules are blocking port 16686

### Performance issues

Consider using the Server Core base image (`dockerfile`) instead of Nano Server if you encounter compatibility issues.

## Switching Base Images

To use the Server Core image instead of Nano Server:

1. Edit `docker-compose.yaml`
2. Change `dockerfile: dockerfile-nano` to `dockerfile: dockerfile`
3. Rebuild: `docker-compose up -d --build`

## Additional Resources

- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [Jaeger Architecture](https://www.jaegertracing.io/docs/architecture/)
- [Jaeger Client Libraries](https://www.jaegertracing.io/docs/client-libraries/)
- [OpenTelemetry](https://opentelemetry.io/) - Modern standard for instrumentation

## License

This container configuration is provided as-is. Jaeger itself is licensed under the Apache License 2.0.

## Version Information

- Jaeger Version: 2.12.0
- Base Image (Nano): Windows Nano Server LTSC 2025
- Base Image (Server Core): Windows Server Core LTSC 2022
