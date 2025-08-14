#!/usr/bin/env bash
set -euo pipefail
urls=(
  http://localhost:3000/login
  http://localhost:9090/targets
  http://localhost:9115/
  http://localhost:3100/ready
  http://localhost:3100/metrics
  http://localhost:9100/metrics
)
for u in "${urls[@]}"; do
  if curl -sf "$u" >/dev/null; then echo "[OK] $u"; else echo "[ERR] $u"; fi
done
echo "Tip: if Loki shows [ERR], run: docker logs loki --tail=200"
