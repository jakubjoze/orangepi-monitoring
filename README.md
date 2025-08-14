
<div align="center">

**Orange Pi Monitoring & Logs**

[![Docker Compose](https://img.shields.io/badge/Docker-Compose-blue)]()
[![Grafana](https://img.shields.io/badge/Grafana-ready-orange)]()
[![Prometheus](https://img.shields.io/badge/Prometheus-metrics-orange)]()
[![Loki](https://img.shields.io/badge/Loki-logs-green)]()

</div>

---

## ✨ What is this?

A complete, self-contained stack for **monitoring** and **log aggregation** on a tiny **Orange Pi**.

- **Prometheus** – metrics time‑series
- **Grafana** – dashboards
- **Blackbox Exporter** – HTTP/ICMP probes
- **Node Exporter** – system metrics
- **Loki** – log database
- **Promtail** – log shipper (journald, syslog, Docker)

Everything runs with Docker Compose and is auto‑provisioned (datasources + dashboards).

---

## 🧭 Architecture

```
                        ┌──────────────┐
                        │   Grafana    │ 3000
                        └──────┬───────┘
                               │
        ┌──────────────────────┴──────────────────────┐
        │                                             │
 ┌──────▼──────┐ 9090       3100 ┌──────────────┐     │
 │ Prometheus  ├───────────────► │     Loki     │◄────┘
 └──────┬──────┘                 └──────┬───────┘
        │ 9100/9115                        ▲
        │                                  │
 ┌──────▼─────────┐                 ┌──────┴───────┐
 │ node-exporter  │                 │   Promtail   │ 1514/UDP
 └────────────────┘                 └──────────────┘
         ▲  ICMP/HTTP probes via 9115
 ┌───────┴────────┐
 │ Blackbox Exp.  │
 └────────────────┘
```

---

## 📁 Repository layout

```
monitoring/
├─ docker-compose.yml
├─ prometheus/
│  └─ prometheus.yml
├─ blackbox/
│  └─ blackbox.yml
├─ loki/
│  └─ loki-config.yml
├─ promtail/
│  └─ promtail-config.yml
├─ grafana/
│  ├─ provisioning/
│  │  ├─ datasources/   (Prometheus, Loki)
│  │  └─ dashboards/    (file provider)
│  └─ dashboards/       (JSON dashboards: Monitoring, Logs)
├─ scripts/
│  ├─ setup.sh          (inject HOST_IP for Prometheus)
│  └─ healthcheck.sh    (curl-based readiness check)
└─ .gitignore           (excludes data volumes etc.)
```

> **Note:** Volumes like `grafana-data/`, `prometheus-data/`, `loki-data/` are **not** tracked – they’re created by Docker.

---

## 🚀 Quick start

### Prerequisites
- Linux on your SBC (Orange Pi / Raspberry Pi)
- Docker Engine + Compose plugin
- Open ports: `3000 9090 9115 3100 1514/udp` (local network is enough)

### Run
```bash
git clone https://github.com/<your-gh-user>/orange-pi-monitoring.git
cd orange-pi-monitoring

# 1) Set the host IP in Prometheus config
bash scripts/setup.sh

# 2) Start services
docker compose up -d

# 3) Verify readiness (with retry)
bash scripts/healthcheck.sh
```

### URLs
- Grafana → `http://<IP>:3000` (first signin: `admin` / `admin`)
- Prometheus → `http://<IP>:9090`
- Blackbox → `http://<IP>:9115`
- Loki → `http://<IP>:3100`

---

## 📊 Dashboards (auto-provisioned)

Folder **“Orange Pi”** in Grafana contains:

- **Orange Pi Monitoring** – CPU/RAM/Disk, Load/Uptime/Temp, Network, Disk I/O, Blackbox probes.  
  The dashboard includes a **datasource selector** so you can pick your Prometheus instance.
- **Logs & Security** – recent auth/journal, SSH failed attempts / 5m, Docker errors, errors per container.  
  Also includes a **datasource selector** for Loki.

---

## 🔁 Boot behavior / Autostart

All services use `restart: unless-stopped`. Ensure Docker starts on boot:
```bash
sudo systemctl enable --now docker
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now monitoring
```

---

## 🛠️ Daily Operations

```bash
cd ~/monitoring

# Status / lifecycle
docker compose ps
docker compose up -d
docker compose restart grafana
docker compose logs -f grafana

# Health
bash scripts/healthcheck.sh

# Loki / Promtail
docker logs loki --tail=120
docker logs promtail --tail=200
logger "test loki $(date)"                  # generate a test log

# Upgrades
docker compose pull
docker compose up -d

# Disk usage / cleanup (careful)
docker system df
docker system prune -af
docker volume ls
```

---

---

## 🔍 Troubleshooting

- `/ready` is ERR right after `up -d` → normal for a few seconds; run `scripts/healthcheck.sh` (does retries).
- Logs dashboard shows “No data” → verify Promtail is running:
  ```bash
  docker compose ps
  docker logs promtail --tail=200

- DNS/ICMP probes down → open Blackbox UI: `http://<IP>:9115/` → click a probe → **Logs**.

---

## 🔐 Security notes

- Grafana default credentials `admin/admin` → **change on first login**.
- If exposing to the internet, put the stack behind a reverse proxy with TLS + auth.
- Docker socket is read‑only for Promtail and only to parse container logs.

---

---

## 🖼️ Screenshots

- Home dashboard  – CPU/RAM/Disk gauges and Blackbox.
<img width="1692" height="1206" alt="image" src="https://github.com/user-attachments/assets/8e0662c8-b830-452c-8f42-f1d6a60f7a3a" />

- Logs & Security – recent logs + SSH failures.
<img width="1707" height="936" alt="image" src="https://github.com/user-attachments/assets/30c42c19-8e36-4024-ad41-ca2f77758c27" />

---

## ✅ One‑minute verification checklist

- [ ] `docker compose up -d` completes without errors
- [ ] `bash scripts/healthcheck.sh` → all **OK**
- [ ] Grafana shows both dashboards in folder **Orange Pi**
- [ ] Explore → Loki contains live entries (journald/syslog/docker)
- [ ] Blackbox probes show `UP` for at least one HTTP and ICMP target

Enjoy! 🎉
