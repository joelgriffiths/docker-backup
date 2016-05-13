#!/bin/sh

. `dirname $0`/common/common-functions.in
source `dirname $BASH_SOURCE`/common/common-variables.in "$@"

# backup path
bak="$backupdir/`date "+%Y-%m-%d-%S"`"

# pull backup
if [ "$1" = 'pull' ]; then
  if [ "$2" ]; then
    bak="$backupdir/$2"
  fi
  bak="$bak.tar.gz"
  if host_has -f "$bak"; then
    dest=${3:-'.'}
    echo "Pulling backup ${2:-"today's backup"} to $dest"
    host_pull $bak $dest
    exit $?
  fi
  echo "Cannot find backup file $bak"
  exit 1
fi

# backup lock
if host_has -d "$bak"; then
  >&2 echo 'Backup directory exists'
  >&2 echo 'Other backup task may be in progress'
  exit 1
fi

echo 'Creating backup file...'
# backup applications in the machine
host_mkdir $bak/conf $bak/data #$bak/logs
for app in $apps; do
  echo "Backing up $app..."
  host_cp `get "$app" 'conf'` $bak/conf
  host_cp `get "$app" 'data'` $bak/data
  #host_cp `get "$app" 'logs'` $bak/logs
done

# create .tar.gz file
echo 'Compressing files...'
host_tar "$bak"
host_rm "$bak" #$bak.tar.gz
echo 'Done'
