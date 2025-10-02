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
sudo apt-get install -y coccinelle rpm2cpio cpio python3 python3-pip gcc
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

## 🛠 Полезные команды

### Показать логи последней сессии
```bash
scripts/show_last_log.sh
```

Пример вывода:
```
[INFO] Последняя сессия: 2025-10-02-1811-rare-koala
[INFO] Путь к логам: runs/2025-10-02-1811-rare-koala/logs/run.log
--------------------------------------------------
[INFO] Логи этой сессии сохраняются в: runs/2025-10-02-1811-rare-koala/logs/run.log
[INFO] Запуск анализа (сессия: runs/2025-10-02-1811-rare-koala)
[INFO] Ищем RT-патч для 5.10...
[OK] Найден RT-патч: https://www.kernel.org/pub/linux/kernel/projects/rt/5.10/patch-5.10.244-rt138.patch.gz
...
```

### Посмотреть объединённый отчёт
```bash
cat runs/*/reports/combined-report.md | less
```

### Пересобрать prebuilt parser.so
```bash
bash scripts/build_prebuilt.sh
```

### Пример вывода объединённого отчёта
После запуска анализа в `runs/<timestamp>-<codename>/reports/combined-report.md` появится отчёт.  

#### ✅ Идеальный сценарий (AST и ML работают)
```
# 📊 Отчёт по ядру 6.12 (идеальный сценарий)

## 🔹 AST-анализ
- AST-структура изменилась: поле `cpu_power` отсутствует
- Обнаружено новое API: `arch_scale_cpu_capacity()`

## 🔹 Семантический анализ
- Поле `cpu_power` удалено → перейти на arch_scale_cpu_capacity()
- Функция init_timer устарела → использовать timer_setup()

## 🔹 Инициализации struct sched_domain
- Найдена инициализация: `struct sched_domain sd = { ... };`

## 🔹 ML-классификация
- оптимизация (уверенность 87%)

📌 Рекомендации:
- Заменить все использования `cpu_power` на `arch_scale_cpu_capacity()`
- Обновить инициализации `sched_domain` под новое поле
```

#### ⚠️ Fallback-сценарий (AST и ML отключены)
```
# 📊 Отчёт по ядру 6.12 (fallback-сценарий)

## 🔹 AST-анализ
- [AST disabled]

## 🔹 Семантический анализ
- Семантических изменений не найдено

## 🔹 Инициализации struct sched_domain
- Не найдено

## 🔹 ML-классификация
- [ML disabled]

📌 Рекомендации:
- Перепроверьте вручную совместимость изменений в scheduler
- Рассмотрите возможность обновления датасета ML и подключения AST
```

---

## 📌 Полезные файлы
- [CHECKLIST.md](CHECKLIST.md) — контрольный список перед запуском
- [SMOKE_TESTS.md](SMOKE_TESTS.md) — быстрые проверки
- [FAQ.md](FAQ.md) — ответы на частые вопросы
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — устранение неполадок
- [ROADMAP.md](ROADMAP.md) — план развития проекта
