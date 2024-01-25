# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## These functions decorate our common "ls" based commands with some defaults.

function ls
  eza $argv
end

function l
  if _is_work_dir
    set args $args "--git-repos"
  end

  eza -la --git -I Icon\r"|.DS_Store" --no-quotes $args $argv
end

function ll
  eza -lah --git
end

function le
  eza -lah@OM --git
end

function _is_work_dir --description "Checks if the current directory is a work directory"
  set curr (pwd)
  for dir in $DADA_WORK_DIRS
    if [ "$curr" = "$dir" ]
      return 0
    end
  end
  return 1
end
