#!/usr/bin/env bash
set -e

echo "[INFO] Проверка окружения Tree-sitter..."

# Попробуем get_parser напрямую
python3 - <<'EOF'
import sys, subprocess
try:
    from tree_sitter_languages import get_parser
    try:
        parser = get_parser("c")
        print("✅ get_parser('c') успешно отработал")
    except Exception as e:
        print(f"❌ Ошибка при get_parser: {e}")
        print("⚠️  Похоже, конфликтует пакет 'tree-sitter'. Удаляем его...")
        subprocess.run([sys.executable, "-m", "pip", "uninstall", "-y", "tree-sitter"], check=False)
        subprocess.run([sys.executable, "-m", "pip", "uninstall", "-y", "py-tree-sitter"], check=False)
        print("🔁 Переустанавливаем tree-sitter-languages...")
        subprocess.run([sys.executable, "-m", "pip", "install", "--force-reinstall", "tree-sitter-languages"], check=True)
except ImportError:
    print("❌ tree_sitter_languages не установлен. Устанавливаем...")
    subprocess.run([sys.executable, "-m", "pip", "install", "tree-sitter-languages"], check=True)
EOF
