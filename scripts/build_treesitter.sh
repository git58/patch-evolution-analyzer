#!/usr/bin/env bash
# Сборка Tree-sitter грамматики с fallback-стратегиями

set -euo pipefail

GRAMMAR="$1"    # например, "c"
DEST="build/parsers/$GRAMMAR"

mkdir -p "$DEST"
cd "$DEST"

echo "[*] Пытаемся сгенерировать Tree-sitter грамматику: $GRAMMAR"

# 1. Основная стратегия
if tree-sitter generate && gcc -fPIC -shared src/parser.c -o parser.so; then
    echo "[OK] Сборка успешна (gcc)"
    exit 0
fi

# 2. Fallback: clang
echo "[WARN] GCC упал, пробуем clang..."
if command -v clang >/dev/null && clang -fPIC -shared src/parser.c -o parser.so; then
    echo "[OK] Сборка успешна (clang)"
    exit 0
fi

# 3. Fallback: c99
echo "[WARN] Компиляция не удалась, пробуем с -std=c99..."
if gcc -std=c99 -fPIC -shared src/parser.c -o parser.so; then
    echo "[OK] Сборка успешна (-std=c99)"
    exit 0
fi

# 4. Fallback: prebuilt
PREBUILT="../../vendor/$GRAMMAR/parser.so"
if [ -f "$PREBUILT" ]; then
    echo "[WARN] Используем prebuilt-грамматику: $PREBUILT"
    cp "$PREBUILT" parser.so
    exit 0
fi

# 5. Fallback: отказ
echo "[ERROR] Не удалось собрать Tree-sitter грамматику $GRAMMAR"
echo "[FALLBACK] AST-анализ будет отключён, останется только Coccinelle"
touch DISABLED_AST
exit 0
