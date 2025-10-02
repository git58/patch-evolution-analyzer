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
**Причина:** отсутствует `parser.so` или файл `DISABLED_AST` в `build/parsers/c/`.  
**Решение:**
- Убедиться, что в `vendor/c/` есть `parser.so`
- Или задать путь к исходникам:
  ```bash
  export GRAMMAR_SRC=/path/to/tree-sitter-c
  bash scripts/build_treesitter.sh c
  ```

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
