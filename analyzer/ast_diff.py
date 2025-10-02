"""
AST Diff — сравнение AST-деревьев с помощью Tree-sitter.
Если AST отключён или не собран, возвращает пустой результат.
"""

import os
from tree_sitter import Language, Parser

class ASTDiff:
    def __init__(self, grammar_path="build/parsers/c/parser.so"):
        self.enabled = os.path.exists(grammar_path)
        if self.enabled:
            Language.build_library("build/my-languages.so", [grammar_path])
            self.C_LANGUAGE = Language(grammar_path, "c")
            self.parser = Parser()
            self.parser.set_language(self.C_LANGUAGE)
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

        # Заглушка: сравниваем просто размер дерева
        changes = []
        if len(str(tree_old.root_node)) != len(str(tree_new.root_node)):
            changes.append("AST-структура изменилась")
        return changes
