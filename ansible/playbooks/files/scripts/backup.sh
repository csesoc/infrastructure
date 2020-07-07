#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
BACKUP_LOG="/home/csesoc/backup.log"

echo "BACKUP START: $(date)" >> $BACKUP_LOG
curl -fsS --retry 3 -o /dev/null -d "START BACKUP" "https://hc-ping.com/$HEALTHCHECK_UUID/start"
source /root/bin/backup-rancher-data.sh >> $BACKUP_LOG 2>&1
source /root/bin/backup-container-data.sh >> $BACKUP_LOG 2>&1
curl -fsS --retry 3 -o /dev/null -d "END BACKUP" "https://hc-ping.com/$HEALTHCHECK_UUID"
echo "BACKUP END: $(date)" >> /home/csesoc/backup.log
