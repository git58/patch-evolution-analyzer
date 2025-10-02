# 🛠️ Troubleshooting — устранение неполадок

## Ошибка: `Permission denied` при запуске скрипта
**Причина:** скрипты не имеют права на исполнение.  
**Решение:**
```bash
chmod +x scripts/*.sh
```

---

## Ошибка: `No module named 'tree_sitter'`
**Причина:** не установлен Python-модуль `tree-sitter`.  
**Решение:**
```bash
pip3 install tree-sitter
```

---

## AST всегда отключён
**Сообщение:** `[AST disabled]`  
**Причины:**
- В `vendor/c/` отсутствует `parser.so`
- Есть маркер `build/parsers/c/DISABLED_AST`
- Ошибка в компиляции `parser.so`
- Конфликт API Tree-sitter

**Решение:**
1. Собрать prebuilt parser.so:
   ```bash
   bash scripts/build_prebuilt.sh
   git add vendor/c/parser.so
   git commit -m "Add prebuilt parser.so"
   ```
2. Проверить, какой API Tree-sitter используется (см. таблицу ниже).  
3. Убедиться, что в логе есть одна из строк:
   - `[AST] Используем API: tree_sitter_languages (lang=c)`
   - `[AST] Используем API: tree_sitter (старый set_language)`
   - `[AST] Используем API: tree_sitter (новый .language property)`
   - или предупреждение `[AST] Не удалось инициализировать Tree-sitter: ...`

### ℹ️ Таблица API Tree-sitter
| Пакет в окружении            | Какой API используется                  | Пример строки в логе                             |
|-------------------------------|------------------------------------------|--------------------------------------------------|
| `tree-sitter-languages`       | Новый API через `get_parser("c")`        | `[AST] Используем API: tree_sitter_languages`    |
| `tree-sitter==0.20.x`         | Старый API через `parser.set_language()` | `[AST] Используем API: tree_sitter (старый set_language)` |
| `tree-sitter>=0.21.x`         | Новый property `parser.language = ...`   | `[AST] Используем API: tree_sitter (новый .language property)` |
| Ничего не установлено / сломано | AST отключён                           | `[AST] Не удалось инициализировать Tree-sitter`  |

---

## ML всегда отключён
**Причина:** нет датасета или модель не обучена.  
**Решение:**
- Проверить `datasets/lkml.csv`
- Убедиться, что формат:
  ```
  diff_text   label
  "- init_timer() + timer_setup()"    багфикс
  ```

---

## Ошибка при распаковке SRPM
**Решение:**
```bash
rpm2cpio source.rpm | bsdtar -xvf -
```

---

## RT-патч не найден
**Решение:**
- Взять патч вручную с kernel.org
- Положить в `patches/rt/`

---

## Python-анализатор завершился с ошибкой
**Сообщение:**  
```
[ERROR] Python-анализатор завершился с ошибкой
```

**Причины:**
- Ошибка в AST-модуле (`parser.so` не найден или повреждён)
- Ошибка в ML-модуле (датасет пустой или сломанный)
- Внутренняя ошибка Python

**Что важно:**
- Даже если Python-анализатор упал, **частичные отчёты и логи сохраняются** в `runs/<timestamp>-<codename>/`
- CI **не должен падать насмерть**: анализатор работает в "graceful" режиме

**Решение:**
1. Проверить `runs/<session>/logs/run.log` — там виден модуль, на котором всё упало.  
2. Исправить ошибку (см. разделы AST / ML выше).  
3. Перезапустить анализ:
   ```bash
   bash scripts/run_analysis.sh
   ```
