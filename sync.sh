#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$REPO_DIR/deploy.log"
BRANCH="main"
CONTAINER_NAME="ops-status-api"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

cd "$REPO_DIR"

git fetch origin "$BRANCH" --quiet

LOCAL_HASH=$(git rev-parse HEAD)
REMOTE_HASH=$(git rev-parse "origin/$BRANCH")

IS_RUNNING=$(docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null || echo "false")

if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    log "Update detected ($LOCAL_HASH to $REMOTE_HASH). Pulling changes and redeploying..."
    git pull origin "$BRANCH" --quiet
    docker compose up -d --build --remove-orphans
    log "Deployment successful. Current commit: $REMOTE_HASH"
elif [ "$IS_RUNNING" != "true" ]; then
    log "WARN: Container $CONTAINER_NAME is down! Triggering automated recovery..."
    docker compose up -d
    log "Recovery complete. Container $CONTAINER_NAME is back online."
fi
