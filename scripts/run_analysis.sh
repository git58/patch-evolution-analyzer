#!/usr/bin/env bash
# Главный скрипт для запуска анализа патчей
# Объединяет загрузку SRPM, RT-патчей, AST-анализ и генерацию отчётов

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNS_DIR="$ROOT_DIR/runs"

# Загружаем логгер
source "$ROOT_DIR/scripts/logger.sh"

# Генерация имени сессии
TS=$(date +"%Y-%m-%d-%H%M")
CODENAME=$("$ROOT_DIR/scripts/gen_codename.sh")
SESSION="$RUNS_DIR/$TS-$CODENAME"

mkdir -p "$SESSION/reports" "$SESSION/logs" "$SESSION/tmp"
LOGDIR="$SESSION/logs"

log_info "Запуск анализа (сессия: $SESSION)"

# === 1. Скачивание и распаковка SRPM (пример: CentOS) ===
if [ -n "${SRPM_URL:-}" ]; then
  log_info "Скачиваем и распаковываем SRPM: $SRPM_URL"
  "$ROOT_DIR/scripts/fetch_and_unpack.sh" "$SRPM_URL" "$SESSION/srpm" || \
    log_warn "Не удалось обработать SRPM ($SRPM_URL)"
fi

# === 2. Поиск RT-патча ===
if [ -n "${KERNEL_VER:-}" ]; then
  log_info "Ищем RT-патч для $KERNEL_VER"
  "$ROOT_DIR/scripts/fetch_latest_rt_patch.sh" "$KERNEL_VER" "$SESSION/tmp" || \
    log_warn "RT-патч для $KERNEL_VER не найден"
fi

# === 3. Сборка Tree-sitter ===
if [ "${ENABLE_AST:-true}" = "true" ]; then
  log_info "Собираем Tree-sitter грамматику C"
  "$ROOT_DIR/scripts/build_treesitter.sh" "c" || \
    log_warn "AST-анализ отключён"
else
  log_warn "AST-анализ отключён (по параметру ENABLE_AST=false)"
fi

# === 4. Запуск Python-анализатора ===
log_info "Запускаем Python-анализатор"
if ! python3 -m analyzer.report_generator --session "$SESSION"; then
  log_error "Python-анализатор завершился с ошибкой"
  exit 1
fi

log_info "Готово! Отчёты лежат в $SESSION/reports"
