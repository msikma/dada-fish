# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function backup_data --description "Backs up static data files"
  ! _check_rsync_version; and return 1

  set backup_type "data"
  set basedir (_get_machine_backup_dir)

  ! _require_needed_dirs "backup_$backup_type" "target" "$basedir/Data/"; and return 1
  ! _require_needed_dirs "backup_$backup_type" "target" "$basedir/Storage/"; and return 1

  _print_backup_start $backup_type (_get_computer_name)

  _copy_rsync ~/"Files/Data/" "$basedir/Data/" "0" "1"
  _copy_rsync ~/"Files/Storage/" "$basedir/Storage/" "0" "1"

  if test $status -ne 0
    _print_backup_error $backup_type
    return 1
  end
  
  _print_backup_finish $backup_type
  _set_backup_time_now "backup_$backup_type"
end

_register_backup_script "backup_local" "backup_data"
