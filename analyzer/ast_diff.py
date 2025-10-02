import logging
from .ts_wrapper import load_parser

class ASTDiff:
    def __init__(self, lang="c"):
        self.enabled = False
        try:
            self.parser = load_parser(lang)
            self.enabled = True
        except Exception as e:
            logging.warning(f"[AST] Не удалось инициализировать Tree-sitter: {e}")
            self.parser = None

    def parse_code(self, code: str):
        if not self.enabled:
            return None
        try:
            return self.parser.parse(bytes(code, "utf8"))
        except Exception as e:
            logging.error(f"[AST] Ошибка при парсинге: {e}")
            return None

    def diff(self, old_code: str, new_code: str):
        if not self.enabled:
            return None
        old_tree = self.parse_code(old_code)
        new_tree = self.parse_code(new_code)
        if not old_tree or not new_tree:
            return None
        return "[AST diff placeholder]"
