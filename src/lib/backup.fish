# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Backups
##
## Functions for writing backups of the machine.

# Minimal required rsync protocol version; checked when running backup scripts.
# Use rsync --help to see the version.
set _rsync_min_protocol_version 31

## Returns the backup directory for the current machine.
function _get_machine_backup_dir
  ! _require_var "DADA_BACKUP_MACHINE_BASEDIR"; and return 1
  echo "$DADA_BACKUP_MACHINE_BASEDIR/"(_get_hostname)
end

## Ensures that a required command is present.
function _check_rsync_version
  if [ ! (command -v "rsync") ]
    echo (status current-command)": error: required command is missing: $cmd"
    return 1
  end
  set rsv (rsync --version | grep -oi "protocol version .*\$" | cut -d' ' -f3)

  if [ $rsv -lt $_rsync_min_protocol_version ]
    echo (status current-command)": error: rsync protocol version is too low (version is $rsv; need at least $_rsync_min_protocol_version)"
    return 1
  end

  return 0
end
