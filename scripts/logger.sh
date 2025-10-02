#!/usr/bin/env bash
# Универсальный логгер с уровнями INFO/WARN/ERROR

set -euo pipefail

LOGDIR="runs/logs"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/run.log"
FALLBACKFILE="$LOGDIR/fallback.log"

timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

log_info() {
  echo "[INFO] $(timestamp) $*" | tee -a "$LOGFILE"
}

log_warn() {
  echo "[WARN] $(timestamp) $*" | tee -a "$LOGFILE" "$FALLBACKFILE"
}

log_error() {
  echo "[ERROR] $(timestamp) $*" | tee -a "$LOGFILE" "$FALLBACKFILE" >&2
}

log_fallback() {
  echo "[FALLBACK] $(timestamp) $*" | tee -a "$FALLBACKFILE"
}
