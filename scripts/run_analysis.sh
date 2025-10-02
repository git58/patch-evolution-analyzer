#!/usr/bin/env bash
# Главный скрипт для запуска анализа патчей
# Объединяет загрузку SRPM, RT-патчей, AST-анализ и генерацию отчётов

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNS_DIR="$ROOT_DIR/runs"

# Генерация имени сессии
TS=$(date +"%Y-%m-%d-%H%M")
CODENAME=$("$ROOT_DIR/scripts/gen_codename.sh")
SESSION="$RUNS_DIR/$TS-$CODENAME"

mkdir -p "$SESSION/reports" "$SESSION/logs" "$SESSION/tmp"
export SESSION_LOGDIR="$SESSION/logs"

# Загружаем логгер (после экспорта SESSION_LOGDIR)
source "$ROOT_DIR/scripts/logger.sh"

log_info "Запуск анализа (сессия: $SESSION)"

# === 1. Скачивание и распаковка SRPM (пример: CentOS) ===
if [ -n "${SRPM_URL:-}" ]; then
  log_info "Скачиваем и распаковываем SRPM: $SRPM_URL"
  if ! "$ROOT_DIR/scripts/fetch_and_unpack.sh" "$SRPM_URL" "$SESSION/srpm"; then
    log_warn "Не удалось обработать SRPM ($SRPM_URL)"
  fi
fi

# === 2. Поиск RT-патча ===
if [ -n "${KERNEL_VER:-}" ]; then
  log_info "Ищем RT-патч для $KERNEL_VER"
  if ! "$ROOT_DIR/scripts/fetch_latest_rt_patch.sh" "$KERNEL_VER" "$SESSION/tmp"; then
    log_warn "RT-патч для $KERNEL_VER не найден"
  fi
fi

# === 3. Сборка Tree-sitter ===
if [ "${ENABLE_AST:-true}" = "true" ]; then
  log_info "Собираем Tree-sitter грамматику C"
  if ! "$ROOT_DIR/scripts/build_treesitter.sh" "c"; then
    log_warn "AST-анализ отключён"
  fi
else
  log_warn "AST-анализ отключён (по параметру ENABLE_AST=false)"
fi

# === 4. Запуск Python-анализатора ===
log_info "Запускаем Python-анализатор"
if ! python3 -m analyzer.report_generator --session "$SESSION"; then
  log_error "Python-анализатор завершился с ошибкой"
  # не валим весь пайплайн, чтобы можно было смотреть хотя бы частичные отчёты
  exit 0
fi

log_info "Готово! Отчёты лежат в $SESSION/reports"
