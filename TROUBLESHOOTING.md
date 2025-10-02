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

**Решение:**
1. Собрать prebuilt parser.so:
   ```bash
   bash scripts/build_prebuilt.sh
   git add vendor/c/parser.so
   git commit -m "Add prebuilt parser.so"
   ```
2. Убедиться, что в логе видно строку:
   ```
   [WARN] Используем prebuilt-грамматику: vendor/c/parser.so
   [OK] AST будет доступен через prebuilt (...)
   ```
3. Проверить, что нет файла `build/parsers/c/DISABLED_AST`

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
