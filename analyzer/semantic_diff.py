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
        diff = list(
            difflib.unified_diff(
                old_code.splitlines(), new_code.splitlines(), lineterm=""
            )
        )
        hints = []

        for line in diff:
            # Устаревшие API
            if line.startswith("-") and "init_timer" in line:
                hints.append("Функция init_timer устарела → использовать timer_setup()")
            if line.startswith("-") and "cpu_power" in line:
                hints.append("Поле cpu_power удалено → перейти на arch_scale_cpu_capacity()")

            # Новые конструкции
            if line.startswith("+") and "raw_spinlock_t" in line:
                hints.append("Добавлен raw_spinlock_t → проверить совместимость драйверов")
            if line.startswith("+") and "this_cpu_read" in line:
                hints.append("Добавлен вызов this_cpu_read → проверить NUMA-безопасность")
            if line.startswith("+") and "pr_warn" in line:
                hints.append("Добавлен pr_warn → возможно, фикс или диагностика")

            # Удаление конструкций
            if line.startswith("-") and "smp_mb__before_atomic" in line:
                hints.append("Удалён барьер smp_mb__before_atomic → проверить атомарность кода")

        if not hints:
            hints.append("Семантических изменений не найдено")

        return hints
