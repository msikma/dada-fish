# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function backup_music --description "Backs up music directory"
  ! _check_rsync_version; and return 1

  set backup_type "music"
  set target "/Volumes/Files/Music/Archive/"

  ! _require_needed_dirs "backup_$backup_type" "target" "$target"; and return 1

  _print_backup_start $backup_type (_get_computer_name)


  _copy_rsync "$DADA_FILES_BASE/Music/" "$target" "0" "1"

  if test $status -ne 0
    _print_backup_error $backup_type
    return 1
  end
  
  _print_backup_finish $backup_type
  _set_backup_time_now "backup_$backup_type"
end

_register_backup_script "backup_remote" "backup_music"
