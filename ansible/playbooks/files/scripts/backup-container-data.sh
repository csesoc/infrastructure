#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR=$(mktemp -d)
trap 'rm -r "${BACKUP_DIR}"' EXIT

main() {
  echo "Begin container backup!"
  pushd "${BACKUP_DIR}" >/dev/null
  mkdir "./data";
  cp -r "/containers" "./data"
  echo $(date -u +"%Y-%m-%dT%H-%M-%SZ") > "./data/backup.txt"
  tar --exclude-from='/containers/tarignore' -cvzf "container-data.tar.gz" "./data"
  ls -l --block-size=M "container-data.tar.gz"
  echo "Begin SCP!"
  scp "container-data.tar.gz" csesoc@cse.unsw.edu.au:~/backups/wheatley/
  echo "End SCP!"
}


main "$@"
