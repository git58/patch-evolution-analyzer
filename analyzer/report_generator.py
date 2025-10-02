"""
Report Generator — объединяет AST, семантический анализ и ML.
Формирует Markdown-отчёты для каждой версии ядра.
"""

import os
import argparse

from .ast_diff import ASTDiff
from .semantic_diff import SemanticDiff
from .struct_init_finder import StructInitFinder
from .ml_classifier import MLClassifier

class ReportGenerator:
    def __init__(self, session_dir: str):
        self.session_dir = session_dir
        self.ast = ASTDiff()
        self.semantic = SemanticDiff()
        self.ml = MLClassifier()
        self.reports_dir = os.path.join(session_dir, "reports")
        os.makedirs(self.reports_dir, exist_ok=True)

    def analyze_version(self, version: str, old_code: str, new_code: str):
        """Запускает все анализаторы для конкретной версии ядра."""
        report_lines = [f"# 📊 Отчёт по ядру {version}", ""]

        # AST
        ast_changes = self.ast.diff(old_code, new_code)
        report_lines.append("## 🔹 AST-анализ")
        report_lines.extend([f"- {c}" for c in ast_changes])

        # Семантика
        sem_hints = self.semantic.analyze(old_code, new_code)
        report_lines.append("\n## 🔹 Семантический анализ")
        report_lines.extend([f"- {h}" for h in sem_hints])

        # Поиск struct init (пример для sched_domain)
        finder = StructInitFinder("sched_domain")
        struct_hits = finder.find_inits(new_code)
        report_lines.append("\n## 🔹 Инициализации struct sched_domain")
        if struct_hits:
            report_lines.extend([f"- {h}" for h in struct_hits])
        else:
            report_lines.append("- Не найдено")

        # ML классификация
        classification = self.ml.classify(new_code)
        report_lines.append("\n## 🔹 ML-классификация")
        report_lines.append(f"- {classification}")

        return "\n".join(report_lines)

    def save_report(self, version: str, content: str):
        out_path = os.path.join(self.reports_dir, f"report-{version}.md")
        with open(out_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[OK] Сохранён отчёт: {out_path}")

    def save_combined_report(self, versions: list):
        combined_path = os.path.join(self.reports_dir, "combined-report.md")
        with open(combined_path, "w", encoding="utf-8") as f:
            for v in versions:
                f.write(f"# === {v} ===\n\n")
                path = os.path.join(self.reports_dir, f"report-{v}.md")
                if os.path.exists(path):
                    f.write(open(path, encoding="utf-8").read())
                    f.write("\n\n")
        print(f"[OK] Сохранён объединённый отчёт: {combined_path}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--session", required=True, help="Каталог сессии")
    args = parser.parse_args()

    rg = ReportGenerator(args.session)

    # 🔹 Заглушка для тестов: сравниваем фиктивные строки
    versions = ["5.10", "6.1", "6.12"]
    for v in versions:
        old_code = "int cpu_power;" if v == "5.10" else ""
        new_code = "raw_spinlock_t lock;" if v == "6.12" else "timer_setup();"
        content = rg.analyze_version(v, old_code, new_code)
        rg.save_report(v, content)

    rg.save_combined_report(versions)

if __name__ == "__main__":
    main()
