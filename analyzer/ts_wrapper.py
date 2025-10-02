import logging
import os
from tree_sitter import Language, Parser

def load_parser(lang="c", build_dir="build/parsers", vendor_dir="vendor"):
    so_path = os.path.join(build_dir, f"{lang}.so")

    if not os.path.exists(so_path):
        raise RuntimeError(f"[AST] parser.so для {lang} не найден. Запустите scripts/build_prebuilt.sh")

    LANGUAGE = Language(so_path, lang)
    parser = Parser()
    parser.set_language(LANGUAGE)
    logging.info(f"[AST] Используем Tree-sitter (ручная сборка: {so_path})")
    return parser
