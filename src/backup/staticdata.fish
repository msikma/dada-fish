# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function backup_data --description "Backs up static data files"
  ! _check_rsync_version; and return 1

  set backup_type "data"
  set basedir (_get_machine_backup_dir)"/Data"

  ! _require_needed_dirs "backup_$backup_type" "target" $basedir; and return 1

  _print_backup_start $backup_type (_get_computer_name)

  # copy_rsync_delete $src $dst
  sleep 1
  
  _print_backup_finish $backup_type
  _set_backup_time_now "backup_$backup_type"
end

_register_backup_script "backup_data" "backup_data"
