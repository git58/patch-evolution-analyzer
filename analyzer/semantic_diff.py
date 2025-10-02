"""
Semantic Diff — семантический анализ изменений в коде.
Работает поверх diff'ов, пытается понять смысл изменений.
"""

import difflib

class SemanticDiff:
    def __init__(self):
        pass

    def analyze(self, old_code: str, new_code: str):
        """
        Анализирует различия между версиями кода.
        Возвращает список семантических подсказок.
        """
        diff = list(difflib.unified_diff(
            old_code.splitlines(), new_code.splitlines(),
            lineterm=""
        ))
        hints = []

        for line in diff:
            if line.startswith("-\t") and "init_timer" in line:
                hints.append("Функция init_timer устарела, используйте timer_setup")
            if line.startswith("-") and "cpu_power" in line:
                hints.append("Поле cpu_power удалено → перейти на arch_scale_cpu_capacity()")
            if line.startswith("+") and "raw_spinlock_t" in line:
                hints.append("Появилось raw_spinlock_t → проверить совместимость драйверов")

        if not hints:
            hints.append("Семантических изменений не найдено")

        return hints
