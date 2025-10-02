#!/usr/bin/env bash
# Проверка консистентности между файлами проекта
# Цель: поймать рассинхрон (например, Dockerfile vs Makefile)

set -euo pipefail

ERRORS=0

echo "[*] Проверка консистентности проекта..."

# 1. Проверяем, что Dockerfile или Podmanfile упоминается в Makefile
if [ -f "Dockerfile" ] && ! grep -q "Dockerfile" Makefile; then
  echo "[WARN] Dockerfile найден, но не упоминается в Makefile"
  ERRORS=$((ERRORS+1))
fi

# 2. Проверяем, что workflows используют актуальные скрипты
for wf in .github/workflows/*.yml; do
  if ! grep -q "scripts/run_analysis.sh" "$wf"; then
    echo "[WARN] В workflow $wf нет вызова run_analysis.sh"
    ERRORS=$((ERRORS+1))
  fi
done

# 3. Проверяем наличие README в ключевых папках
for dir in patches srpms kernels; do
  if [ ! -f "$dir/README.md" ]; then
    echo "[WARN] В каталоге $dir отсутствует README.md"
    ERRORS=$((ERRORS+1))
  fi
done

if [ $ERRORS -gt 0 ]; then
  echo "[ERROR] Консистентность нарушена ($ERRORS проблем)"
  exit 1
else
  echo "[OK] Консистентность в порядке"
fi
