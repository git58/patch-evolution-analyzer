# 🐞 Patch Evolution Analyzer

Инструмент для анализа эволюции патчей ядра Linux с помощью **Coccinelle**, **Tree-sitter** и эвристик.  
Цель — помочь мейнтейнерам переносить изменения из старых версий ядра в новые (в том числе при отсутствии готовых патчей для нужной версии).

---

## 📂 Структура проекта
```
analyzer/        # Python-модули анализа (AST, ML, семантика, отчёты)
scripts/         # Скрипты сборки, загрузки патчей, логгера
vendor/          # prebuilt Tree-sitter грамматики
models/          # обученные ML-модели (создаются автоматически)
datasets/        # датасеты (например, LKML для обучения ML)
patches/         # RT и кастомные патчи
srpms/           # SRPM пакеты (исходники ядер)
kernels/         # исходники vanilla и patched ядер
runs/            # результаты запусков (отчёты, логи)
.github/workflows/ # GitHub Actions для CI
```

---

## 🚀 Быстрый старт

### Зависимости
```bash
sudo apt-get install -y coccinelle tree-sitter-cli rpm2cpio cpio python3 python3-pip
pip3 install scikit-learn tree-sitter
chmod +x scripts/*.sh
```

### Запуск анализа
```bash
export SRPM_URL="https://download.copr.fedorainfracloud.org/results/kwizart/kernel-longterm-5.10/epel-8-x86_64/09557158-kernel-longterm/kernel-longterm-5.10.244-200.el8.src.rpm"
export KERNEL_VER="5.10"
bash scripts/run_analysis.sh
```

---

## 📑 Выходные данные
Все результаты сохраняются в `runs/<timestamp>-<codename>/`:
- `logs/` — логи и fallback-инфо
- `reports/`:
  - `report-<version>.md` — отчёт по конкретной версии ядра
  - `combined-report.md` — объединённый отчёт по всем версиям

---

## 📌 Полезные файлы
- [CHECKLIST.md](CHECKLIST.md) — контрольный список перед запуском
- [SMOKE_TESTS.md](SMOKE_TESTS.md) — быстрые проверки
- [FAQ.md](FAQ.md) — ответы на частые вопросы
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — устранение неполадок
- [ROADMAP.md](ROADMAP.md) — план развития проекта
