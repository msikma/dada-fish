# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function backup_work --description "Backs up all work related files"
  ! _check_rsync_version; and return 1
  
  echo "work backup placeholder"
end

_register_backup_script "backup_local" "backup_work"
