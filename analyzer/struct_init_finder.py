"""
Struct Init Finder — поиск инициализаций структур.
Используется при изменении состава struct, чтобы подсказать, где в коде
нужно адаптировать инициализацию.
"""

import re
from typing import List

class StructInitFinder:
    def __init__(self, struct_name: str):
        self.struct_name = struct_name
        self.pattern = re.compile(rf"{struct_name}\s+\w+\s*=\s*{{", re.MULTILINE)

    def find_inits(self, code: str) -> List[str]:
        """
        Ищет инициализации struct в тексте кода.
        Возвращает список строк с совпадениями.
        """
        matches = self.pattern.findall(code)
        return matches if matches else []
