#!/usr/bin/env bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."
BUILD_DIR="$PROJECT_ROOT/build/parsers"
VENDOR_DIR="$PROJECT_ROOT/vendor"

mkdir -p "$BUILD_DIR"
mkdir -p "$VENDOR_DIR"

# Если нет исходников грамматики C — клонируем
if [ ! -d "$VENDOR_DIR/tree-sitter-c" ]; then
    echo "[INFO] Клонируем tree-sitter-c..."
    git clone https://github.com/tree-sitter/tree-sitter-c.git "$VENDOR_DIR/tree-sitter-c"
fi

# Собираем библиотеку
echo "[INFO] Собираем parser.so для языка C..."
python3 - <<EOF
from tree_sitter import Language
Language.build_library(
    "${BUILD_DIR}/c.so",
    ["${VENDOR_DIR}/tree-sitter-c"]
)
EOF

echo "[OK] Грамматика C собрана: ${BUILD_DIR}/c.so"
