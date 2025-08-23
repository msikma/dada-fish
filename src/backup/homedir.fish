# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function backup_homedir --description "Backs up various parts of home"
  ! _require_cmd "7zz"; and return 1
  ! _check_rsync_version; and return 1

  set backup_type "homedir"
  set basedir (_get_machine_backup_dir)

  ! _require_needed_dirs "backup_$backup_type" "target" "$basedir"; and return 1

  mkdir -p "$basedir/Home"
  set temp (mktemp -d)
  ! _require_temp_dir "$temp"; and return 1

  _print_backup_start $backup_type (_get_computer_name)

  pushd ~
  set excluded_dirs
  for dir in (find ".cache" -mindepth 1 -maxdepth 1 -type d -exec du -sm {} + | awk '$1 > 80 {print $2}')
    set -a excluded_dirs "-xr!"(basename "$dir")
  end
  7zz a "$temp/Dotfiles.7z" -y -bsp1 -bso0 -snl -snh -bb0 -mx5 -xr!node_modules -xr!.DS_Store $excluded_dirs ".config" ".cache" ".ssh" ".cron" ".gitignore-global" ".gitconfig"
  popd
  if [ -e "$temp/Dotfiles.7z" ]
    rm -f "$basedir/Home/Dotfiles.7z"
    mv "$temp/Dotfiles.7z" "$basedir/Home/Dotfiles.7z"
  else
    echo "error: could not backup homedir dotfiles"
  end
  _make_7zz_backup ~ "$temp/Desktop.7z" "$basedir/Home/Desktop.7z" "Desktop"
  _make_7zz_backup ~ "$temp/Pictures.7z" "$basedir/Home/Pictures.7z" "Pictures"

  if [ -d "$temp" ]
    rm -rf "$temp"
  end
  
  _print_backup_finish $backup_type
  _set_backup_time_now "backup_$backup_type"
end

_register_backup_script "backup_local" "backup_homedir"
