#!/usr/bin/env bash
# Запросы к LDAP/AD из Linux. Требует ldap-utils; без сервера — только проверка синтаксиса (bash -n).
# Переменные: LDAP_HOST, LDAP_BASE, LDAP_USER (опц., для bind), LDAP_PASS (опц.)
set -euo pipefail
LDAP_HOST="${LDAP_HOST:-ldap://dc01.example.local}"
LDAP_BASE="${LDAP_BASE:-DC=example,DC=local}"
echo "1) Все пользователи:"; echo "ldapsearch -x -H $LDAP_HOST -b $LDAP_BASE '(objectClass=user)' cn mail"
echo "2) Отключённые (AD): userAccountControl=514"; echo "ldapsearch -x -H $LDAP_HOST -b $LDAP_BASE '(&(objectClass=user)(userAccountControl=514))' cn"
echo "3) Компьютеры домена:"; echo "ldapsearch -x -H $LDAP_HOST -b $LDAP_BASE '(objectClass=computer)' cn operatingSystem"
if [[ "${RUN:-0}" == "1" ]]; then ldapsearch -x -H "$LDAP_HOST" -b "$LDAP_BASE" "(objectClass=user)" cn mail; else echo "Сухой режим: поставьте RUN=1 для реального запроса."; fi
