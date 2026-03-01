# Tunel - Tor Proxy Pool

A Docker-based Tor proxy pool that runs three independent Tor instances, each providing SOCKS and HTTP tunnel proxies with control port access for programmatic management via Stem.

## Architecture

The project deploys three Tor proxy containers on a shared Docker bridge network:

- **proxy1** (tor-proxy-1): `172.28.0.2`
  - SOCKS proxy: port `666`
  - HTTP tunnel: port `6666`
  - Control port: port `6661`

- **proxy2** (tor-proxy-2): `172.28.0.3`
  - SOCKS proxy: port `666`
  - HTTP tunnel: port `6666`
  - Control port: port `6662`

- **proxy3** (tor-proxy-3): `172.28.0.4`
  - SOCKS proxy: port `666`
  - HTTP tunnel: port `6666`
  - Control port: port `6663`

## Prerequisites

- Docker
- Docker Compose

## Setup

### 1. Generate Control Port Passwords

Before running the proxies, you need to generate hashed passwords for the Tor control ports. Each proxy uses a control port for programmatic management (e.g., via Stem library).

To generate a hashed password, run:

```bash
tor --hash-password <your-password>
```

This will output a hash in the format: `16:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

**Important:** Generate a unique password for each proxy instance, or use the same password for all three if you prefer.

### 2. Update Tor Configuration Files

Edit `torrc1`, `torrc2`, and `torrc3` and replace the `HashedControlPassword` values with your generated hashes:

```
HashedControlPassword 16:YOUR_GENERATED_HASH_HERE
```

For example, if you generated a hash `16:ABC123...`, update each `torrc` file:

```bash
# In torrc1
HashedControlPassword 16:ABC123...

# In torrc2  
HashedControlPassword 16:ABC123...

# In torrc3
HashedControlPassword 16:ABC123...
```

### 3. Build and Start Services

Build the Docker image and start all three proxy containers:

```bash
docker compose up --build -d
```

This will:
- Build the Tor image from source (Alpine-based)
- Start all three proxy containers
- Create the bridge network `local_proxy` (172.28.0.0/24)

### 4. Verify Proxy Status

Test that all proxies are running and routing through Tor:

```bash
docker compose exec proxy entrypoint.sh test
```

Or run the healthcheck directly:

```bash
docker compose exec proxy python3 /healthcheck.py
```

The healthcheck will verify each proxy can reach the Tor network and display their exit IPs.

## Usage

### Accessing Proxies

From within the Docker network (`local_proxy`), you can access:

- **SOCKS proxies:**
  - `172.28.0.2:666` (proxy1)
  - `172.28.0.3:666` (proxy2)
  - `172.28.0.4:666` (proxy3)

- **HTTP tunnel proxies:**
  - `172.28.0.2:6666` (proxy1)
  - `172.28.0.3:6666` (proxy2)
  - `172.28.0.4:6666` (proxy3)

- **Control ports (for Stem/Django integration):**
  - `172.28.0.2:6661` (proxy1)
  - `172.28.0.3:6662` (proxy2)
  - `172.28.0.4:6663` (proxy3)

### Control Port Authentication

When connecting to control ports via Stem, use the password you hashed earlier. Example Python code:

```python
from stem.control import Controller

controller = Controller.from_port(address='172.28.0.2', port=6661)
controller.authenticate(password='your-password-here')
```

### Healthcheck

Run a healthcheck that exits with code 0 if at least 2 proxies are operational:

```bash
docker compose exec proxy entrypoint.sh health
```

## Django Web App Integration

This project is designed to support a Django web application that controls the three Tor proxies using the Stem library. The Django app should:

1. Connect to each proxy's control port (6661, 6662, 6663) on the `local_proxy` network
2. Use Stem to manage circuits, rotate identities, and monitor proxy health
3. Expose REST APIs for proxy management

The Django service should be added to `docker-compose.yml` on the same `local_proxy` network to access the proxy containers.

## Configuration Files

- `torrc1`, `torrc2`, `torrc3`: Tor configuration files for each proxy instance
- `docker-compose.yml`: Docker Compose orchestration
- `Dockerfile`: Builds Tor from source on Alpine Linux
- `healthcheck.py`: Python script to verify proxy health
- `entrypoint.sh`: Container entrypoint script
- `requirements.txt`: Python dependencies (requests, stem, tqdm, django)

## Stopping Services

```bash
docker compose down
```

## Troubleshooting

- If proxies fail to start, check Docker logs: `docker compose logs proxy`
- Verify control port passwords are correctly hashed and match in the `torrc` files
- Ensure ports 666, 6666, and 6661-6663 are not in use by other services
- Check network connectivity: `docker network inspect local_proxy`

## Security Notes

- Control ports are only accessible within the Docker network by default
- Use strong, unique passwords for control port authentication
- The proxies use non-standard ports (666, 6666) - adjust if needed for your environment
- All three proxies currently share the same control password hash - consider using different passwords for better security
