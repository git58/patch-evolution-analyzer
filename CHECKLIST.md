# ✅ Checklist — контрольный список перед демо/запуском

## Подготовка окружения
- [ ] Установлены пакеты: `coccinelle`, `tree-sitter-cli`, `rpm2cpio`, `cpio`, `python3`, `python3-pip`
- [ ] Установлены Python-зависимости: `scikit-learn`, `tree-sitter`
- [ ] Все скрипты в `scripts/` имеют права на исполнение (`chmod +x`)

## Проверка структуры проекта
- [ ] Есть каталоги: `scripts/`, `analyzer/`, `datasets/`, `patches/`, `srpms/`, `kernels/`, `.github/workflows/`
- [ ] В `patches/`, `srpms/`, `kernels/` есть `README.md` с инструкцией
- [ ] В `datasets/` есть `lkml.csv` (даже минимальный)

## CI
- [ ] Workflow `analyze-centos.yml` запускается и собирает отчёт
- [ ] Workflow `analyze-universal.yml` запускается и работает с параметрами

## Локальный запуск
- [ ] `scripts/run_analysis.sh` успешно создаёт папку `runs/<timestamp>-<codename>/`
- [ ] Внутри папки есть логи (`logs/`) и отчёты (`reports/`)
- [ ] `combined-report.md` формируется и читаем

## Отчёты
- [ ] В отчёте есть блоки:
  - AST-анализ (или `[AST disabled]`)
  - Семантический анализ
  - Struct Init Finder
  - ML-классификация (или `[ML disabled]`)
