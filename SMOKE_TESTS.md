# 🔥 Smoke-тесты проекта

Минимальные проверки, что проект работает «из коробки».

---

## 1. Локальный запуск

### Установи зависимости
```bash
sudo apt-get install -y coccinelle rpm2cpio cpio python3 python3-pip gcc
pip3 install -r requirements.txt
```

### Сделай скрипты исполняемыми
```bash
chmod +x scripts/*.sh
```

### Запусти анализ на SRPM
```bash
export SRPM_URL="https://download.copr.fedorainfracloud.org/results/kwizart/kernel-longterm-5.10/epel-8-x86_64/09557158-kernel-longterm/kernel-longterm-5.10.244-200.el8.src.rpm"
export KERNEL_VER="5.10"
bash scripts/run_analysis.sh
```

### Проверь отчёты
```bash
ls runs/*/reports/
cat runs/*/reports/combined-report.md | head -50
```

### Проверь логи
- В консоли должно появиться:
  ```
  [INFO] Логи этой сессии сохраняются в: runs/<timestamp>-<codename>/logs/run.log
  ```
- Перейди в указанный файл и убедись, что там есть строки:
  - `Запуск анализа (сессия: ...)`
  - `Запускаем Python-анализатор`
  - `Готово! Отчёты лежат...`

### Проверь AST API
- В `run.log` должна быть строка одного из видов:
  - `[AST] Используем API: tree_sitter_languages (lang=c)`
  - `[AST] Используем API: tree_sitter (старый set_language)`
  - `[AST] Используем API: tree_sitter (новый .language property)`
- Если API не удалось инициализировать, будет предупреждение:
  - `[AST] Не удалось инициализировать Tree-sitter: ...`

---

## 2. CI (GitHub Actions)

### Запусти вручную
- Workflow **Analyze CentOS Patches**
- Workflow **Analyze Universal Kernels**

### Проверки
- ✅ В логах есть шаг `Install deps` → `pip3 install -r requirements.txt`
- ✅ Нет ошибок `Permission denied`
- ✅ Появились артефакты `centos-reports` / `universal-reports`

---

## 3. Pass/Fail критерии
- Отчёты формируются даже при отключённом AST/ML.
- В отчёте есть блоки:
  - `## 🔹 Семантический анализ`
  - `## 🔹 ML-классификация`
- Логи содержат строки:
  - `Логи этой сессии сохраняются в: .../run.log`
  - `Запуск анализа (сессия: ...)`
  - `Готово! Отчёты лежат...`
  - `[AST] Используем API: ...` (или предупреждение об отключении)
