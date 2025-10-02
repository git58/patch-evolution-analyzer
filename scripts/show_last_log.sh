#!/usr/bin/env bash
# Показывает run.log последней сессии анализа

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNS_DIR="$ROOT_DIR/runs"

if [ ! -d "$RUNS_DIR" ]; then
  echo "[ERROR] Каталог $RUNS_DIR не найден. Ещё не запускался анализ?"
  exit 1
fi

LAST_SESSION=$(ls -1t "$RUNS_DIR" | head -n1)
LOGFILE="$RUNS_DIR/$LAST_SESSION/logs/run.log"

if [ ! -f "$LOGFILE" ]; then
  echo "[ERROR] Файл лога не найден: $LOGFILE"
  exit 1
fi

echo "[INFO] Последняя сессия: $LAST_SESSION"
echo "[INFO] Путь к логам: $LOGFILE"
echo "--------------------------------------------------"
cat "$LOGFILE"
