# Jaeger Tracing & OpenSearch Windows Containers

## Overview

This project provides containerized versions of [Jaeger](https://www.jaegertracing.io/) and [OpenSearch](https://opensearch.org/) running on Windows containers. 

- **Jaeger**: An open-source distributed tracing system for monitoring and troubleshooting microservices-based distributed systems
- **OpenSearch**: A community-driven, open-source search and analytics suite used for log analytics, application monitoring, and full-text search

## What It Does

### Jaeger
Jaeger helps you:
- Monitor and troubleshoot transactions in complex distributed systems
- Track request flows across multiple services
- Identify performance bottlenecks
- Analyze service dependencies
- Debug latency issues in microservices architectures

This container runs Jaeger in "all-in-one" mode, which includes all Jaeger backend components (agent, collector, query service, and UI) in a single process.

### OpenSearch
OpenSearch provides:
- Full-text search capabilities
- Log analytics and aggregation
- Real-time application monitoring
- Data visualization and exploration
- RESTful API for data indexing and querying
- Machine learning and anomaly detection features

The OpenSearch container is configured with security enabled and includes 25+ plugins for enhanced functionality.

## Container Details

### Base Images

**Jaeger** - Two Dockerfile options are provided:
- **dockerfile**: Uses `mcr.microsoft.com/windows/servercore:ltsc2022` (larger, more compatible)
- **dockerfile-nano**: Uses `mcr.microsoft.com/windows/nanoserver:ltsc2025` (smaller, more lightweight)

**OpenSearch** - Single Dockerfile:
- **dockerfile-opensearch**: Uses `mcr.microsoft.com/windows/nanoserver:ltsc2025`

The docker-compose configuration uses the nano version for both containers by default.

### Exposed Ports

#### Jaeger Ports

| Port  | Protocol | Description                                    |
|-------|----------|------------------------------------------------|
| 6831  | UDP      | Jaeger agent - compact Thrift protocol        |
| 6832  | UDP      | Jaeger agent - binary Thrift protocol         |
| 5778  | HTTP     | Agent configuration server                     |
| 16686 | HTTP     | Jaeger UI and Query service                    |
| 14268 | HTTP     | Jaeger collector - accepts spans via HTTP     |
| 14250 | gRPC     | Jaeger collector - accepts spans via gRPC     |
| 9411  | HTTP     | Zipkin compatible endpoint                     |

#### OpenSearch Ports

| Port  | Protocol | Description                                    |
|-------|----------|------------------------------------------------|
| 9200  | HTTPS    | OpenSearch REST API                            |
| 9300  | TCP      | OpenSearch transport (internal communication)  |
| 9600  | HTTP     | Performance Analyzer                           |
| 5601  | HTTP     | OpenSearch Dashboards (reserved)               |

### Directory Structure

```
.
├── docker-compose.yaml          # Docker Compose configuration for both services
├── dockerfile                   # Jaeger Dockerfile using Server Core base image
├── dockerfile-nano              # Jaeger Dockerfile using Nano Server base image
├── dockerfile-opensearch        # OpenSearch Dockerfile using Nano Server
├── README.md                    # This file
└── setup/
    ├── jaeger/                 # Jaeger installation directory
    │   ├── jaeger.exe         # Jaeger executable for Windows
    │   ├── all-in-one.yaml    # Jaeger configuration file
    │   └── config.yaml        # Additional Jaeger configuration
    └── opensearch/             # OpenSearch installation directory
```

## Prerequisites

- Docker Desktop or DOcker EE with Windows containers enabled
- Windows 10/11 or Windows Server 2019/2022
- Jaeger executable for Windows (v2.12.0 or compatible)
- OpenSearch for Windows (v3.3.2 or compatible)

## Setup Instructions

### 1. Download Jaeger

Download the Jaeger binary for Windows:

```powershell
# Download from official Jaeger releases
# https://download.jaegertracing.io/v1.75.0/jaeger-2.12.0-windows-amd64.tar.gz
```

Extract `jaeger.exe` and the configuration files, then place them in the `setup/jaeger/` directory.

### 2. Download OpenSearch

Download the OpenSearch binary for Windows:

```powershell
# Download from official OpenSearch releases
# https://artifacts.opensearch.org/releases/bundle/opensearch/3.3.2/opensearch-3.3.2-windows-x64.zip
```

Extract the contents and rename the folder to `opensearch`, then place it in the `setup/` directory.

### 3. Configuration

#### Jaeger Configuration

The Jaeger container uses `setup/jaeger/all-in-one.yaml` for configuration. You can customize this file to adjust Jaeger's behavior, storage options, and other settings.

#### OpenSearch Configuration

The OpenSearch container is pre-configured with:
- **Security enabled**: SSL/TLS with demo certificates
- **Single-node mode**: Configured for standalone deployment
- **Network binding**: Listens on all interfaces (0.0.0.0)
- **Admin credentials**: `admin` / `OpenSearch123!`
- **Memory**: 512MB heap size (adjustable via `OPENSEARCH_JAVA_OPTS`)

### 4. Build and Run

#### Using Docker Compose (Recommended)

```powershell
# Build and start all containers
docker-compose up -d

# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f jaegertracing_win
docker-compose logs -f opensearch_win

# Stop all containers
docker-compose down
```

#### Using Docker CLI

**Jaeger:**
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

**OpenSearch:**
```powershell
# Build the image
docker build -t opensearch_win -f dockerfile-opensearch .

# Run the container
docker run -d `
  --name opensearch_win `
  -p 9200:9200 `
  -p 9300:9300 `
  -p 9600:9600 `
  -p 5601:5601 `
  opensearch_win
```

## Usage

### Access the Services

#### Jaeger UI

Once the containers are running, access the Jaeger UI at:

```
http://localhost:16686
```

The UI allows you to:
- Search and view traces
- Analyze service dependencies
- Compare traces
- View system architecture

#### OpenSearch API

Access OpenSearch via HTTPS at:

```
https://localhost:9200
```

**Credentials:**
- Username: `admin`
- Password: `OpenSearch123!`

**Example PowerShell request:**
```powershell
$password = ConvertTo-SecureString 'OpenSearch123!' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential('admin', $password)
Invoke-RestMethod -Uri 'https://localhost:9200' -Credential $credential -SkipCertificateCheck -AllowUnencryptedAuthentication
```

**Common endpoints:**
- `https://localhost:9200` - Cluster information
- `https://localhost:9200/_cluster/health` - Cluster health status
- `https://localhost:9200/_cat/indices?v` - List all indices
- `https://localhost:9200/_cat/plugins?v` - List installed plugins
- `https://localhost:9200/_cat/nodes?v` - List cluster nodes

### Send Traces to Jaeger

Configure your applications to send traces to Jaeger using one of the following endpoints:

- **Agent (UDP)**: `localhost:6831` or `localhost:6832`
- **Collector (HTTP)**: `http://localhost:14268/api/traces`
- **Collector (gRPC)**: `localhost:14250`
- **Zipkin compatible**: `http://localhost:9411/api/v2/spans`

### Working with OpenSearch

#### Create an Index
```powershell
$password = ConvertTo-SecureString 'OpenSearch123!' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential('admin', $password)
Invoke-RestMethod -Uri 'https://localhost:9200/my-index' -Method Put -Credential $credential -SkipCertificateCheck -AllowUnencryptedAuthentication
```

#### Index a Document
```powershell
$body = @{
    title = "Sample Document"
    content = "This is a test document"
    timestamp = (Get-Date).ToString("o")
} | ConvertTo-Json

Invoke-RestMethod -Uri 'https://localhost:9200/my-index/_doc/1' -Method Put -Body $body -ContentType 'application/json' -Credential $credential -SkipCertificateCheck -AllowUnencryptedAuthentication
```

#### Search Documents
```powershell
$searchBody = @{
    query = @{
        match = @{
            content = "test"
        }
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri 'https://localhost:9200/my-index/_search' -Method Post -Body $searchBody -ContentType 'application/json' -Credential $credential -SkipCertificateCheck -AllowUnencryptedAuthentication
```

## Troubleshooting

### Containers won't start

1. Ensure Docker is set to Windows containers mode
2. Verify required files exist:
   - `setup/jaeger/jaeger.exe` (Jaeger)
   - `setup/opensearch/` (OpenSearch)
3. Check logs: `docker-compose logs` or `docker logs <container_name>`

### Cannot access Jaeger UI

1. Verify the container is running: `docker ps`
2. Check port bindings: `docker port jaegertracing_win`
3. Ensure no firewall rules are blocking port 16686

### Cannot access OpenSearch API

1. Verify the container is running: `docker ps`
2. Check if OpenSearch is ready: `docker logs opensearch_win | Select-String "started"`
3. Test connectivity: `Test-NetConnection -ComputerName localhost -Port 9200`
4. Ensure you're using HTTPS (not HTTP) and the correct credentials
5. Wait 60-90 seconds after container start for full initialization

### OpenSearch authentication fails

1. Verify you're using the correct credentials: `admin` / `OpenSearch123!`
2. Ensure you're using Basic authentication
3. Use `-SkipCertificateCheck` flag with PowerShell cmdlets (demo certificates are self-signed)

### Performance issues

Consider using the Server Core base image (`dockerfile`) for Jaeger instead of Nano Server if you encounter compatibility issues. OpenSearch requires the Nano Server image as configured.

## Switching Base Images

To use the Server Core image instead of Nano Server:

1. Edit `docker-compose.yaml`
2. Change `dockerfile: dockerfile-nano` to `dockerfile: dockerfile`
3. Rebuild: `docker-compose up -d --build`

## Network Configuration

Both containers are connected via a Docker network named `jaeger-network`, allowing them to communicate with each other. This enables scenarios such as:
- Storing Jaeger traces in OpenSearch for long-term retention and analysis
- Searching and analyzing trace data using OpenSearch's powerful query capabilities
- Building custom dashboards combining metrics from both systems

## Additional Resources

### Jaeger
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [Jaeger Architecture](https://www.jaegertracing.io/docs/architecture/)
- [Jaeger Client Libraries](https://www.jaegertracing.io/docs/client-libraries/)
- [OpenTelemetry](https://opentelemetry.io/) - Modern standard for instrumentation

### OpenSearch
- [OpenSearch Documentation](https://opensearch.org/docs/latest/)
- [OpenSearch API Reference](https://opensearch.org/docs/latest/api-reference/)
- [OpenSearch Security](https://opensearch.org/docs/latest/security/)
- [OpenSearch Plugins](https://opensearch.org/docs/latest/install-and-configure/plugins/)

## License

This container configuration is provided as-is. Jaeger itself is licensed under the Apache License 2.0.

## Version Information

### Jaeger
- Version: 2.12.0
- Base Image (Nano): Windows Nano Server LTSC 2025
- Base Image (Server Core): Windows Server Core LTSC 2022

### OpenSearch
- Version: 3.3.2
- Base Image: Windows Nano Server LTSC 2025
- Included Plugins: 25+ (alerting, anomaly detection, security, ML, and more)
- Security: Enabled with demo certificates (not for production use)
