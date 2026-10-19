#!/usr/bin/env bash
# Резервное копирование: tar-архив + rsync-зеркало + ротация + лог.
# Использование: ./backup.sh [--dry-run] [конфиг]
# Переменные можно задать в backup.conf (см. backup.conf.example) или окружением.
set -euo pipefail
DRY_RUN=0; CONFIG=""
for a in "$@"; do case "$a" in --dry-run) DRY_RUN=1;; *) CONFIG="$a";; esac; done
[[ -n "$CONFIG" && -f "$CONFIG" ]] && { set -a; source "$CONFIG"; set +a; }
SOURCE_DIRS="${SOURCE_DIRS:-/etc /home}"
DEST_DIR="${DEST_DIR:-/var/backups/mybackup}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
DATE="$(date +%F_%H%M%S)"; LOG_FILE="${DEST_DIR}/backup.log"
run(){ if [[ $DRY_RUN -eq 1 ]]; then echo "[dry-run] $*"; else "$@"; fi; }
mkdir -p "$DEST_DIR" 2>/dev/null || { DEST_DIR="$(pwd)/.backup-test"; mkdir -p "$DEST_DIR"; LOG_FILE="${DEST_DIR}/backup.log"; echo "Нет прав на исходный DEST, использую $DEST_DIR"; }
echo "[$(date '+%F %T')] Старт бэкапа -> $DEST_DIR" | tee -a "$LOG_FILE"
ARCHIVE="${DEST_DIR}/backup-${DATE}.tar.gz"
# shellcheck disable=SC2086
if [[ $DRY_RUN -eq 1 ]]; then echo "[dry-run] tar -czf $ARCHIVE $SOURCE_DIRS"; echo "[dry-run] sha256sum $ARCHIVE"; else
  tar -czf "$ARCHIVE" $SOURCE_DIRS 2>>"$LOG_FILE"; sha256sum "$ARCHIVE" > "${ARCHIVE}.sha256"
  echo "Архив: $ARCHIVE ($(du -h "$ARCHIVE" | cut -f1))" | tee -a "$LOG_FILE"
fi
if command -v rsync >/dev/null; then
  # shellcheck disable=SC2086
  run rsync -a --delete $SOURCE_DIRS "${DEST_DIR}/mirror/"
else echo "rsync не найден — зеркало пропущено (архив создан)"; fi
# Ротация: удалить архивы старше RETENTION_DAYS
if [[ $DRY_RUN -eq 1 ]]; then echo "[dry-run] find $DEST_DIR -name 'backup-*.tar.gz' -mtime +$RETENTION_DAYS -delete";
else find "$DEST_DIR" -maxdepth 1 -name 'backup-*.tar.gz' -mtime +"$RETENTION_DAYS" -print -delete >>"$LOG_FILE" 2>&1 || true; fi
echo "[$(date '+%F %T')] Готово" | tee -a "$LOG_FILE"
