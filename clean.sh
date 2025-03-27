#!/bin/bash

set -a
source .env
set +a

docker compose down -v
rm -rf ./config/grafana/dashboards/providers