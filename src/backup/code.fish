# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function backup_code --description "Backs up all code projects"
  ! _require_cmd "7zz"; and return 1
  ! _check_rsync_version; and return 1
  
  set home ~/
  set remote_basedir (_get_machine_backup_dir)"/Code/"

  set backup_type "code"

  # Verify that our target directory is writable.
  ! _require_needed_dirs "backup_$backup_type" "target" "$remote_basedir"; and return 1
  
  _print_backup_start $backup_type (_get_computer_name)
  echo ""

  for type_dir in (find "$DADA_CODE_BASE" -type d -mindepth 1 -maxdepth 1)
    set type (basename "$type_dir")
    echo (set_color cyan)"Code type: "(set_color yellow)"$type"(set_color normal)
    set projects_basedir "$DADA_CODE_BASE/$type"
    set remote_projects_basedir "$remote_basedir/$type"
    set projects (_find_projects "$projects_basedir")
    for n in (seq 1 3 (count $projects))
      set temp (mktemp -d)
      ! _require_temp_dir "$temp"; and return 1

      # Full path where the project is located.
      set proj_dir $projects[$n]
      # Name of the project (name of the directory, to be used for the filename).
      set proj_name $projects[(math $n + 1)]
      # Relative directory from $projects_basedir, e.g. "./" or "./@templates/".
      set proj_reldir $projects[(math $n + 2)]

      set local_fn "$temp/$proj_name.7z"
      set local_dir "$projects_basedir/$proj_reldir"
      set remote_dir "$remote_projects_basedir/$proj_reldir"
      set remote_fn "$remote_dir/$proj_name.7z"
      mkdir -p "$remote_dir"

      _make_7zz_backup "$local_dir" "$local_fn" "$remote_fn" "$proj_dir"

      if [ -e "$remote_fn" ]
        set filesize (du -h "$remote_fn" | awk '{print $1}')
        echo (set_color cyan)" • "(set_color yellow)"$proj_name: "(set_color green)"$filesize"(set_color normal)
      else
        echo (set_color cyan)" • "(set_color yellow)"$proj_name: "(set_color red)"backup failed"(set_color normal)
      end

      if [ -d "$temp" ]
        rm -rf "$temp"
      end
    end
  end
  
  _print_backup_finish $backup_type
  _set_backup_time_now "backup_$backup_type"
end

_register_backup_script "backup_local" "backup_code"
