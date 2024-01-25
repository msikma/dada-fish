# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _zip_userdata --argument-names basedir fn dir
  pushd "$basedir"
  zip -rq "$fn" "$dir" -x "/**/.DS_Store"
  popd
end

function backup_userdata --description "Backs up user data"
  ! _check_rsync_version; and return 1

  set backup_type "backup_userdata"
  
  set basedir (_get_machine_backup_dir)"/User data"
  set backup_dirs (_get_backup_dirs_for_type "userdata")
  set home ~/
  set temp (mktemp -d)

  if [ (count $backup_dirs) -lt 1 ]
    return
  end

  for n in (seq 1 3 (count $backup_dirs))
    set type $backup_dirs[$n]
    set name $backup_dirs[(math "$n" + 1)]
    set dir $backup_dirs[(math "$n" + 2)]

    set base (basename "$dir")
    set reldir (grealpath -s --relative-to="$home" "$dir")
    set local_fn "$temp/$base.zip"
    set remote_fn "$basedir/$base.zip"
    
    _zip_userdata "$home" "$local_fn" "$reldir"
    
    mv "$local_fn" "$remote_fn"
  end

  rm -rf "$temp"

  _set_backup_time_now "$backup_type"
end

_register_backup_script "backup_local" "backup_userdata"
