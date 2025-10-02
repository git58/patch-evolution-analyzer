#!/usr/bin/env bash
# Автоматическая сборка prebuilt parser.so для Tree-sitter C
# Работает даже без tree-sitter-cli (использует готовые parser.c из репо)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="$ROOT_DIR/vendor/c"
TMPDIR="$(mktemp -d)"

echo "[*] Клонируем tree-sitter-c..."
git clone --depth=1 https://github.com/tree-sitter/tree-sitter-c.git "$TMPDIR/tree-sitter-c"

pushd "$TMPDIR/tree-sitter-c" >/dev/null

echo "[*] Собираем parser.so напрямую (без tree-sitter-cli)..."
gcc -fPIC -c src/parser.c -o parser.o
if [ -f src/scanner.c ]; then
  gcc -fPIC -c src/scanner.c -o scanner.o
  gcc -shared -o parser.so parser.o scanner.o
else
  gcc -shared -o parser.so parser.o
fi

popd >/dev/null

mkdir -p "$VENDOR_DIR"
cp "$TMPDIR/tree-sitter-c/parser.so" "$VENDOR_DIR/parser.so"
echo "[OK] Prebuilt parser.so сохранён в $VENDOR_DIR/parser.so"

rm -rf "$TMPDIR"
