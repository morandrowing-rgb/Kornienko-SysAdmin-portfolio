#!/usr/bin/env bash
# Проверка доступности TCP/HTTP по hosts.csv. Код возврата 1, если хоть один сервис недоступен.
set -uo pipefail
CSV="${1:-$(dirname "$0")/hosts.csv}"; LOG="${LOG_FILE:-$(dirname "$0")/check.log}"; FAIL=0
ts(){ date '+%F %T'; }
while IFS=, read -r name host port type; do
  [[ -z "${name:-}" || "$name" =~ ^# ]] && continue
  if [[ "$type" == "http" ]]; then
    code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "http://${host}:${port}/" 2>/dev/null)"; code="${code:-000}"
    [[ "$code" =~ ^[23] ]] && res="OK http=$code" || { res="FAIL http=$code"; FAIL=1; }
  else
    if timeout 5 bash -c "cat < /dev/null > /dev/tcp/${host}/${port}" 2>/dev/null; then res="OK tcp"; else res="FAIL tcp"; FAIL=1; fi
  fi
  echo "[$(ts)] $name $host:$port $res" | tee -a "$LOG"
done < "$CSV"
exit $FAIL
