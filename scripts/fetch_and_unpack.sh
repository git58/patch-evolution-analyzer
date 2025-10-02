#!/usr/bin/env bash
# Скачивание и распаковка SRPM с fallback

set -euo pipefail

URL="$1"
OUTDIR="$2"

mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "[*] Скачиваем SRPM: $URL"

if ! wget -q "$URL" -O source.rpm; then
  echo "[ERROR] Не удалось скачать $URL"
  echo "[FALLBACK] Попробуйте вручную скачать SRPM и положить в $OUTDIR"
  exit 0
fi

echo "[*] Распаковываем SRPM..."
if ! rpm2cpio source.rpm | cpio -idmv; then
  echo "[ERROR] Ошибка при распаковке $URL"
  echo "[FALLBACK] Можно попробовать: rpm2cpio source.rpm | bsdtar -xvf -"
  exit 0
fi

echo "[OK] SRPM успешно распакован в $OUTDIR"
