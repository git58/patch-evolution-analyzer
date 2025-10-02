"""
AST Diff — сравнение AST-деревьев с помощью Tree-sitter.
Если AST отключён или не собран, возвращает пустой результат.
"""

import os

try:
    from tree_sitter import Language, Parser
except ImportError:
    Language = None
    Parser = None


class ASTDiff:
    def __init__(self, grammar_dir="build/parsers/c"):
        self.grammar_path = os.path.join(grammar_dir, "parser.so")
        self.disabled_marker = os.path.join(grammar_dir, "DISABLED_AST")
        self.enabled = (
            Language is not None
            and Parser is not None
            and os.path.exists(self.grammar_path)
            and not os.path.exists(self.disabled_marker)
        )

        if self.enabled:
            try:
                self.C_LANGUAGE = Language(self.grammar_path, "c")
                self.parser = Parser()
                self.parser.set_language(self.C_LANGUAGE)
            except Exception as e:
                print(f"[WARN] Не удалось инициализировать Tree-sitter: {e}")
                self.enabled = False
                self.parser = None
        else:
            self.parser = None

    def parse(self, code: str):
        if not self.enabled:
            return None
        return self.parser.parse(bytes(code, "utf8"))

    def diff(self, code_old: str, code_new: str):
        """
        Находит различия в AST между старым и новым кодом.
        Возвращает список изменений (в упрощённой форме).
        """
        if not self.enabled:
            return ["[AST disabled]"]

        tree_old = self.parse(code_old)
        tree_new = self.parse(code_new)

        # Заглушка: простое сравнение размеров дерева
        changes = []
        if len(str(tree_old.root_node)) != len(str(tree_new.root_node)):
            changes.append("AST-структура изменилась")
        else:
            changes.append("Изменений в AST-структуре не обнаружено")

        return changes
