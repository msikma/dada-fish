# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _7zz_userdata --argument-names basedir local_fn remote_fn source
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

function backup_userdata --description "Backs up user data"
  ! _require_cmd "7zz"; and return 1
  ! _check_rsync_version; and return 1

  set backup_type "userdata"
  
  set home ~/
  set basedir (_get_machine_backup_dir)"/User data"
  set backup_dirs (_get_backup_dirs_for_type "$backup_type")
  if [ (count $backup_dirs) -lt 1 ]
    return 0
  end

  # Verify that our target directory is writable.
  ! _require_needed_dirs "backup_$backup_type" "target" $basedir; and return 1

  # Verify that our temp dir is usable.
  set temp (mktemp -d)
  ! _require_temp_dir "$temp"; and return 1

  echo "Backing up "(set_color yellow)"$backup_type"(set_color normal)" for "(set_color green)(_get_hostname)(set_color reset)":"
  echo ""
  for n in (seq 1 3 (count $backup_dirs))
    set type $backup_dirs[$n]
    set name $backup_dirs[(math "$n" + 1)]
    set dir $backup_dirs[(math "$n" + 2)]

    set base (basename "$dir")
    set relative_source (grealpath -s --relative-to="$home" "$dir")
    set local_fn "$temp/$base.zip"
    set remote_fn "$basedir/$base.zip"
    
    echo (set_color yellow)"$name"(set_color reset)": "(set_color reset)"$dir"(set_color reset)

    if not test -e "$dir"
      echo (set_color red)"Could not stat the source directory."(set_color reset)
      continue
    end

    set orig_lm (_get_last_modified "$dir")
    set dest_lm (_get_last_modified "$remote_fn")

    if [ "$dest_lm" -lt "$orig_lm" ]
      # The destination file is outdated (or it doesn't exist). Make the backup.
      _7zz_userdata "$home" "$local_fn" "$remote_fn" "$relative_source"
    else
      # No need to do anything.
      echo (set_color blue)"No need to backup."(set_color reset)
    end
  end

  if [ -d "$temp" ]
    rm -rf "$temp"
  end

  _set_backup_time_now "backup_$backup_type"
end

_register_backup_script "backup_local" "backup_userdata"
_register_dependency "brew" "sevenzip" "7zz"
