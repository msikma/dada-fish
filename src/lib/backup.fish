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
  echo "$DADA_BACKUP_MACHINE_BASEDIR/"(_get_computer_name)
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

## 7zips a directory to a target filename.
function _make_7zz_backup --argument-names basedir local_fn remote_fn source
  pushd "$basedir"
  
  # Unlink the previous backup.
  rm -f "$remote_fn"
  
  # Create a new backup.
  7zz a "$local_fn" -y -bsp1 -bso0 -bb0 -mx5 -xr!node_modules -xr!.DS_Store "$source"

  # Grab the modified date of the source directory, and set the destination file to this same date.
  set source_modified (_get_last_modified "$source")
  set formatted_time (date -r "$source_modified" +"%Y%m%d%H%M.%S")
  touch -t "$formatted_time" "$local_fn"

  popd

  mv "$local_fn" "$remote_fn"
end

## Checks that a number of directories exists and can be backed up or written to.
function _require_needed_dirs --argument-names script_name dir_type
  set required_dirs $argv[3..-1]
  set dir_count (count $required_dirs)
  if [ $dir_count -eq 0 ]
    echo $script_name": error: called _check_needed_dirs with no directory arguments"
    return 1
  end
  for n in (seq 1 $dir_count)
    set required_dir $required_dirs[$n]
    if [ ! -d $required_dir ]
      echo $script_name": error: can't access $dir_type directory: "$required_dir
      return 1
    end
  end

  return 0
end
