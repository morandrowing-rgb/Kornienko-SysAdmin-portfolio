# 04 — Мониторинг доступности сервисов (Bash)

`check_services.sh` читает `hosts.csv` (`имя,хост,порт,tcp|http`), проверяет каждый
сервис, пишет лог в `check.log` и возвращает код 1 при недоступности — удобно для
cron + уведомления или как бедный аналог healthcheck без отдельной системы мониторинга.

```bash
./check_services.sh hosts.csv; echo "exit=$?"
# cron: */10 * * * * /path/check_services.sh || echo "сервис недоступен" | mail -s alert admin@example
```
Для постоянного мониторинга в проде это не замена Prometheus/Zabbix, а лёгкая
проверка «жив ли сервис прямо сейчас» — в DevOps-портфолио у меня есть отдельный стек Grafana/Loki/Prometheus.
