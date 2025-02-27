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

## Runs rsync on a source and destination directory.
##
## The arguments used to run rsync are -ahEANS8, which expands to the following:
##
## -a, --archive          archive mode; equals -rlptgoD (no -H,-A,-X)
##  └ -r, --recursive     recurse into directories
##  └ -l, --links         copy symlinks as symlinks
##  └ -p, --perms         preserve permissions
##  └ -t, --times         preserve modification times
##  └ -g, --group         preserve group
##  └ -o, --owner         preserve owner (super-user only)
##  └ -D                  same as --devices --specials
##     └ --devices        preserve device files (super-user only)
##     └ --specials       preserve special files
## -h, --human-readable   output numbers in a human-readable format
## -E, --executability    preserve the file's executability
## -A, --acls             preserve ACLs (implies --perms)
## -N, --crtimes          preserve create times (newness)
## -S, --sparse           turn sequences of nulls into sparse blocks
## -8, --8-bit-output     leave high-bit chars unescaped in output
##
## If 'delete' is passed as 1, this will delete files that are in the destination
## but not in the source.
##
## To exclude directories, pass any number of paths (relative to the source path)
## as the last arguments, after 'delete'.
##
## Note: this doesn't copy extended attributes (-X) which won't work on btrfs.
## Change if we're upgrading to a better fs.
##
function _copy_rsync --argument-names src dst quiet delete
  set excl $argv[5..-1]
  set excl_arg
  for n in $excl
    set excl_arg $excl_arg "--exclude=$n"
  end
  if [ -n "$quiet" -a "$quiet" -eq 1 ]
    set q 'q'
  end
  if [ -n "$delete" -a "$delete" -eq 1 ]
    set d '--delete'
  end

  rsync -ahEANS8"$q" $d --progress $excl_arg --exclude=".*" --exclude="Icon*" --exclude='node_modules' --stats "$src" "$dst"
end

## Finds projects for backup purposes.
function _find_projects --argument-names dir basedir
  if [ -z "$basedir" ]
    set basedir "./"
  end
  # We'll return 3 items per project: the name, the full directory where it's located, and its relative basedir.
  # See src/backup/work.fish for a usage example.
  set items
  set dirs (find "$dir" -type d -maxdepth 1 -mindepth 1 | sort)
  for dir in $dirs
    set dirname (basename "$dir")
    if string match -q '@*' -- "$dirname"
      set nested_items (_find_projects "$dir" "$basedir""$dirname/")
      set items $items $nested_items
    else
      set items $items "$dir" "$dirname" "$basedir"
    end
  end
  printf '%s\n' $items
end

## 7zips a directory to a target filename.
function _make_7zz_backup --argument-names basedir local_fn remote_fn source
  ! _require_cmd "7zz"; and return 1
  
  pushd "$basedir"
  
  # Unlink the previous backup.
  rm -f "$remote_fn"
  
  # Create a new backup.
  7zz a "$local_fn" -y -bsp1 -bso0 -snl -snh -bb0 -mx5 -xr!node_modules -xr!.DS_Store "$source"

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
    echo $script_name": error: called _require_needed_dirs with no directory arguments"
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

## Prints the name of this backup script and the computer's hostname if provided. Also starts the timer.
function _print_backup_start --argument-names backup_type target_name
  echo
  echo -n "Backing up "(set_color yellow)"$backup_type"(set_color normal)
  if [ (count $target_name) -ne 0 ]
    echo " for "(set_color green)"$target_name"(set_color reset)":"
  else
    echo ":"(set_color normal)
  end
  _timer_start
end

## Stops the timer and prints how long the backup took.
function _print_backup_finish --argument-names backup_type
  set timer_val (_timer_end)
  set timer_h (_duration_humanized $timer_val)
  echo
  echo (set_color cyan)"Done in "(set_color yellow)"$timer_h"(set_color cyan)"."(set_color normal)
  echo
end

## Stops the timer and prints an error message.
function _print_backup_error --argument-names backup_type
  set timer_val (_timer_end)
  set timer_h (_duration_humanized $timer_val)
  echo
  echo (set_color red)"Ran for "(set_color yellow)"$timer_h"(set_color red)" and exited abnormally. Backup NOT completed."(set_color normal)
  echo
end
