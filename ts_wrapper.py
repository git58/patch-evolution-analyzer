import logging
from tree_sitter import Language, Parser
import os

def load_parser(lang_name="c", build_dir="build/parsers", vendor_dir="vendor"):
    so_path = os.path.join(build_dir, f"{lang_name}.so")

    if not os.path.exists(so_path):
        logging.info(f"[AST] Собираем библиотеку для {lang_name}...")
        Language.build_library(
            so_path,
            [os.path.join(vendor_dir, f"tree-sitter-{lang_name}")]
        )

    LANGUAGE = Language(so_path, lang_name)
    parser = Parser()
    parser.set_language(LANGUAGE)
    logging.info(f"[AST] Используем API: tree_sitter (ручная сборка {lang_name})")
    return parser
