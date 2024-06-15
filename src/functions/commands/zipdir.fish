# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

# Default compression level (0-9).
set -g _default_level '6'

function zipdir --description "Zips a directory (also: zipdir{n})" --argument-names dirpath level
  ! _require_cmd "gstat"; and return 1
  ! _require_cmd "gls"; and return 1

  set usage "usage: zipdir0..9 [--help] dir"

  if [ (string match -r '^-h$|^--help$' -- "$dirpath") ]
    echo "$usage"
    echo
    echo "Zips a directory to a .zip file with the same name."
    return
  end

  if [ -z "$level" ]
    set level "$_default_level"
  end

  # Sanity check on the input.
  if [ ! -e "$dirpath" ]
    echo "zipdir: error: not found: $dirpath"
    return 1
  end
  set here (pwd)
  set source_dir (realpath "$dirpath")
  if [ "$here" = "$source_dir" ]
    echo 'zipdir: error: cannot zip current working directory'
    return 1
  end
  if [ ! -d "$source_dir" ]
    echo "zipdir: error: not a directory: $source_dir"
    return 1
  end

  set source_parent (realpath "$source_dir/..")
  set target_basename (basename $dirpath)
  set target_name "$target_basename.zip"
  set target_path "$here"/"$target_name"
  
  echo (set_color yellow)"Zipping to: "(set_color cyan)$target_name(set_color normal)
  echo
  pushd "$source_parent"
  time zip -$level -db -Xovr "$target_path" "./$target_basename" -x "*.DS_Store" # | grep --color=never "total bytes"
  # Set the access time to the source directory's.
  touch -r "./$target_basename" "$target_path"
  echo
  popd

  set result_path "./$target_name"
  set result_filesize (gls -lh "$target_path" | awk '{print $5}')
  set result_date (gdate -d @(gstat --format=%Y "$target_path"))

  echo (set_color --bold green)"Source:" (set_color reset)"$source_dir"
  echo (set_color --bold cyan)"Target:" (set_color reset)"$result_path"
  echo (set_color --bold yellow)" Level:" (set_color reset)"$level"
  echo (set_color --bold yellow)"  Time:" (set_color reset)"123 millis"
  echo (set_color --bold red)"  Size:" (set_color reset)"$result_filesize"
  echo (set_color --bold red)"Modify:" (set_color reset)"$result_date"
end

# Create zipdir{0..9}. These do not appear separately in the help command.
for n in (seq 0 9)
  eval "function zipdir$n --description \"zipdir at compression level $n\" --argument-names dirpath; zipdir \"\$dirpath\" '$n'; end"
end

_register_dependency "brew" "coreutils" "gstat"
_register_dependency "brew" "coreutils" "gls"
_register_command archiving "zipdir" "dir level"
