# 02 — Отчёт о состоянии сервера (Python)

`system_report.py` собирает: заполнение диска `/`, load average, память,
uptime, состояние служб (`systemctl is-active`) и открытость TCP-портов на localhost.
Вывод — в терминал, при `--json` ещё и в файл (удобно прикладывать к тикету).

```bash
./system_report.py --services ssh,cron --ports 22,80,443 --json report.json
```
Зависимостей нет (Python 3, stdlib). Если systemd нет (контейнер) — служба честно
покажется как `unknown`, отчёт не падает.
