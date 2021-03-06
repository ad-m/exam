#!/bin/sh
set -euo
AWS_REGION=${region}
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases?per_page=1 | sed -E -n 's/^.*tag_name": "(.+?)".*$/\1/p')
curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;
chmod +x /usr/local/bin/docker-compose;
systemctl start docker
systemctl enable docker
docker-compose -f /opt/docker-compose.yml up -d