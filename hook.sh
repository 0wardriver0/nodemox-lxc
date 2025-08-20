#!/bin/bash
# $1: hook type (e.g., post-start)
# $2: container ID
# $3: config path

if [[ "$1" == "post-start" ]]; then
    echo "🔁 Hook triggered for container $2"
    sleep 2  # Give container a second to boot up
    pct exec "$2" -- bash /root/setup.sh
fi
