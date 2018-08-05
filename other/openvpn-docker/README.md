## OpenVPN Docker

### Usage

1. **config.sh**: Configure volume name, client name, and domain name. This script yields `.ovpn.config` (required from the following steps).
2. **init.sh**: Setup OpenVPN environment in the docker volume.
3. **client.sh**: Generate client file.
4. **start.sh**: Start OpenVPN server.
