#!/usr/bin/env bash
# Универсальный логгер с уровнями INFO/WARN/ERROR
# Использует SESSION_LOGDIR (из run_analysis.sh), иначе пишет в runs/logs

set -euo pipefail

if [ -n "${SESSION_LOGDIR:-}" ]; then
  LOGDIR="$SESSION_LOGDIR"
else
  LOGDIR="runs/logs"
fi

mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/run.log"
FALLBACKFILE="$LOGDIR/fallback.log"

# 📌 При старте сессии сообщаем, где искать логи
if [ ! -f "$LOGDIR/.logger_init" ]; then
  echo "[INFO] Логи этой сессии сохраняются в: $LOGFILE" | tee -a "$LOGFILE"
  touch "$LOGDIR/.logger_init"
fi

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
