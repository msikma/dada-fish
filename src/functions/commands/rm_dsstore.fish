# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _remove_dsstore_dir --argument-names dir dry_run quiet
  if [ ! -d "$dir" ]
    echo "remove_dsstore.fish: directory not found: $dir"
    return
  end
  
  set args
  if [ "$dry_run" -eq "0" ]
    set -a args "-delete"
  end
  if [ "$quiet" -eq "0" ]
    set -a args "-print"
  end

  find "$dir" -name ".DS_Store" -type f $args
end

function rm_dsstore --description "Removes .DS_Store files"
  set usage "usage: rm_dsstore [--quiet] [--help] [--dry-run] dirs"
  set dry_run "0"
  set quiet "0"
  set dirs
  for arg in $argv
    if [ (string match -r '^-h$|^--help$' -- "$arg") ]
      echo "$usage"
      echo
      echo "Removes .DS_Store files recursively from one or more given directories."
      echo "Run with --dry-run to only print the files instead."
      return
    end
    if [ (string match -r '^--dry-run$' -- "$arg") ]
      set dry_run "1"
      continue
    end
    if [ (string match -r '^-q|^--quiet$' -- "$arg") ]
      set quiet "1"
      continue
    end
    if [ ! (string match -r '^--' -- "$arg") ]
      set -a dirs "$arg"
    end
  end
  
  if ! set -q "dirs[1]"
    echo "$usage"
    return 1
  end
  for dir in $dirs
    _remove_dsstore_dir "$dir" "$dry_run" "$quiet"
  end
end

_register_command script "rm_dsstore" "path"
