# Electrum Server Container image

This image contains an [electrs] install. It extends the [base image].

## Installation

1. Pull from [Docker Hub], download the package from [Releases] or build using `builder/build.sh`

## Usage

### Environment variables

-   `ELECTRS_DAEMON_P2P_ADDR`
    -   Bitcoin daemon P2P `addr:port` to connect to.
-   `ELECTRS_DAEMON_RPC_ADDR`
    -   Bitcoin daemon JSONRPC `addr:port` to connect to.

### Volumes

-   `/media/bitcoin/data`
    -   The data directory of bitcoind.
-   `/media/electrum-server`
    -   Data of the electrs server.

## Development

To run for development execute:

```bash
docker compose --file docker-compose-dev.yaml up --build
```

[base image]: https://github.com/mbT-Infrastructure/docker-base
[electrs]: https://github.com/romanz/electrs
[Docker Hub]: https://hub.docker.com/r/madebytimo/electrum-server
[Releases]: https://github.com/mbT-Infrastructure/docker-electrum-server/releases
