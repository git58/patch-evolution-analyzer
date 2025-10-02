#!/usr/bin/env bash
# Сборка Tree-sitter грамматики с многоуровневыми fallback-стратегиями.
# Приоритет:
#   1) Если есть prebuilt в vendor/<grammar>/parser.so — используем его.
#   2) Если задан GRAMMAR_SRC с исходниками grammar.js/src/* — пробуем собрать (gcc/clang/c99).
#   3) Если ничего не вышло — создаём маркер DISABLED_AST и НЕ валим пайплайн.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRAMMAR="${1:-c}"
DEST="$ROOT_DIR/build/parsers/$GRAMMAR"

mkdir -p "$DEST"

echo "[*] Tree-sitter: подготовка для грамматики: $GRAMMAR"
echo "[*] DEST: $DEST"

# 1) Fallback: prebuilt
PREBUILT="$ROOT_DIR/vendor/$GRAMMAR/parser.so"
if [ -f "$PREBUILT" ]; then
  echo "[WARN] Используем prebuilt-грамматику: $PREBUILT"
  cp -f "$PREBUILT" "$DEST/parser.so"
  echo "[OK] AST будет доступен через prebuilt ($DEST/parser.so)"
  exit 0
fi

# 2) Попытка сборки из исходников (если заданы)
#    Ожидаем, что $GRAMMAR_SRC указывает на репо типа tree-sitter-c (с grammar.js и src/)
if [ -n "${GRAMMAR_SRC:-}" ] && [ -d "${GRAMMAR_SRC:-}" ]; then
  echo "[*] Попытка сборки из исходников: $GRAMMAR_SRC"
  if ! command -v tree-sitter >/dev/null 2>&1; then
    echo "[WARN] tree-sitter-cli не найден в PATH — пропускаем генерацию"
  else
    TMPDIR="$(mktemp -d)"
    rsync -a "$GRAMMAR_SRC/" "$TMPDIR/" >/dev/null 2>&1 || true
    pushd "$TMPDIR" >/dev/null

    if [ -f "grammar.js" ] || [ -d "src" ]; then
      if tree-sitter generate >/dev/null 2>&1; then
        echo "[*] Сгенерирован parser.c — пробуем компиляцию"

        # Пытаемся разными компиляторами/настройками
        if gcc -fPIC -shared src/parser.c -o "$DEST/parser.so" >/dev/null 2>&1; then
          echo "[OK] Сборка успешна (gcc) → $DEST/parser.so"
          popd >/dev/null
          rm -rf "$TMPDIR"
          exit 0
        fi

        if command -v clang >/dev/null 2>&1 && clang -fPIC -shared src/parser.c -o "$DEST/parser.so" >/dev/null 2>&1; then
          echo "[OK] Сборка успешна (clang) → $DEST/parser.so"
          popd >/dev/null
          rm -rf "$TMPDIR"
          exit 0
        fi

        if gcc -std=c99 -fPIC -shared src/parser.c -o "$DEST/parser.so" >/dev/null 2>&1; then
          echo "[OK] Сборка успешна (-std=c99) → $DEST/parser.so"
          popd >/dev/null
          rm -rf "$TMPDIR"
          exit 0
        fi

        echo "[WARN] Компиляция не удалась всеми стратегиями"
      else
        echo "[WARN] tree-sitter generate завершился неуспешно"
      fi
    else
      echo "[WARN] В $GRAMMAR_SRC не найдены grammar.js/src — пропускаем сборку"
    fi

    popd >/dev/null
    rm -rf "$TMPDIR"
  fi
else
  echo "[INFO] GRAMMAR_SRC не задан — пропускаем сборку из исходников"
fi

# 3) Отключаем AST, но НЕ падаем
echo "[ERROR] Не удалось собрать/получить Tree-sitter грамматику: $GRAMMAR"
echo "[FALLBACK] AST-анализ будет отключён, работаем только через Coccinelle"
touch "$DEST/DISABLED_AST"
exit 0
