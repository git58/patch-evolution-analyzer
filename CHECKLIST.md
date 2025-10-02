# ✅ Checklist — контрольный список перед демо/запуском

## Подготовка окружения
- [ ] Установлены пакеты: `coccinelle`, `rpm2cpio`, `cpio`, `python3`, `python3-pip`, `gcc`
- [ ] Установлены Python-зависимости: `scikit-learn`, `tree-sitter`
- [ ] Все скрипты в `scripts/` имеют права на исполнение (`chmod +x`)
- [ ] Собран prebuilt parser.so:
  ```bash
  bash scripts/build_prebuilt.sh
  git add vendor/c/parser.so
  git commit -m "Add prebuilt parser.so"
  ```

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
- [ ] Проверить логи последней сессии:
  ```bash
  scripts/show_last_log.sh
  ```

## Отчёты
- [ ] В отчёте есть блоки:
  - AST-анализ (или `[AST disabled]`)
  - Семантический анализ
  - Struct Init Finder
  - ML-классификация (или `[ML disabled]`)
