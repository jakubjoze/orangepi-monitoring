#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
IP=$(hostname -I | awk '{print $1}')
sed -i "s#\${HOST_IP}#${IP}#g" prometheus/prometheus.yml
echo "HOST_IP set to ${IP}"
echo "Start: docker compose up -d"
