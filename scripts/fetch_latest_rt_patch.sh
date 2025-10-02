#!/usr/bin/env bash
# Автопоиск RT-патча на kernel.org с fallback

set -euo pipefail

KVER="$1"       # версия ядра (например, 5.10 или 6.1)
TMPDIR="$2"     # временный каталог для патча
mkdir -p "$TMPDIR"

PATCH_URL=""

echo "[*] Ищем RT-патч для ядра $KVER..."

# 1. Пытаемся найти автоматически
PATCH_URL=$(curl -s "https://www.kernel.org/pub/linux/kernel/projects/rt/$KVER/" \
  | grep -oE "patch-${KVER}\.[0-9]+-rt[0-9]+\.patch\.gz" \
  | sort -V | tail -n1)

if [ -n "$PATCH_URL" ]; then
  PATCH_URL="https://www.kernel.org/pub/linux/kernel/projects/rt/$KVER/$PATCH_URL"
  echo "[OK] Найден RT-патч: $PATCH_URL"
  wget -q "$PATCH_URL" -O "$TMPDIR/rt.patch.gz"
  gunzip -f "$TMPDIR/rt.patch.gz"
  PATCH_FILE="$TMPDIR/rt.patch"
  exit 0
fi

# 2. Если авто-режим не сработал → fallback
echo "[WARN] Автоматический поиск RT-патча не удался"

case "$KVER" in
  5.10)
    FALLBACK_URL="https://www.kernel.org/pub/linux/kernel/projects/rt/5.10/older/patch-5.10.204-rt99.patch.gz"
    ;;
  6.1)
    FALLBACK_URL="https://www.kernel.org/pub/linux/kernel/projects/rt/6.1/older/patch-6.1.132-rt50.patch.gz"
    ;;
  *)
    echo "[ERROR] Нет fallback-патча для ядра $KVER"
    echo "[FALLBACK] Скачайте вручную с kernel.org и положите в patches/rt/"
    exit 0
    ;;
esac

echo "[*] Используем fallback: $FALLBACK_URL"
wget -q "$FALLBACK_URL" -O "$TMPDIR/fallback.patch.gz"
gunzip -f "$TMPDIR/fallback.patch.gz"
PATCH_FILE="$TMPDIR/fallback.patch"

echo "[OK] RT-патч загружен по fallback: $PATCH_FILE"
