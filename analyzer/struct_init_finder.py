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
        # Паттерн на инициализацию struct foo bar = { ... }
        self.pattern_init = re.compile(
            rf"{struct_name}\s+\w+\s*=\s*{{", re.MULTILINE
        )
        # Паттерн на memset(&bar, 0, sizeof(struct foo))
        self.pattern_memset = re.compile(
            rf"memset\s*\(\s*&\w+.*sizeof\s*\(\s*struct\s+{struct_name}\s*\)\s*\)",
            re.MULTILINE,
        )
        # Паттерн на упрощённое обнуление: struct foo bar = {0};
        self.pattern_zero = re.compile(
            rf"{struct_name}\s+\w+\s*=\s*{{0}}", re.MULTILINE
        )

    def find_inits(self, code: str) -> List[str]:
        """
        Ищет инициализации struct в тексте кода.
        Возвращает список строк с совпадениями.
        """
        matches = []
        matches.extend(self.pattern_init.findall(code))
        matches.extend(self.pattern_memset.findall(code))
        matches.extend(self.pattern_zero.findall(code))

        return matches if matches else []
