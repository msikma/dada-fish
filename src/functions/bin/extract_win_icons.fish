#!/usr/bin/env fish

set curr (dirname (status --current-filename))
source "$curr/../../lib/os.fish"

set USAGE 'usage: extract_win_icons fn… [-d|--dest PATH]'

function main --argument-names icon_container
  ! _require_cmd "wrestool"; and return 1

  # Find the destination argument, if provided. Collect files to extract from as well.
  set -a files
  set dest ""
  set next_is_dest 0
  for arg in $argv
    if [ "$next_is_dest" -eq 1 ]
      set dest "$arg"
      set next_is_dest 0
    else if begin [ "$arg" = "-d" ]; or [ "$arg" = "--dest" ]; end
      set next_is_dest 1
    else
      set -a files "$arg"
    end
  end
  if [ "$next_is_dest" -eq 1 ]
    echo "extract_win_icons: error: if -d or --dest is set, a destination path must be provided"
    return 1
  end

  if [ (count $files) -eq 0 ]
    echo "$USAGE"
    return 1
  end

  # Extract icons from all provided files. Use a generated dest if not provided.
  for file in $files
    if [ -d "$file" ]
      continue
    end
    set file_dest "$dest"
    if [ -z "$dest" ]
      set file_dest ./"$file""_icons/"
      if [ ! -d "$file_dest" ]
        mkdir -p "$file_dest"
      end
    end
    if [ ! -d "$file_dest" ]
      echo "extract_win_icons: error: directory $dest does not exist"
      return 1
    end
    wrestool -x -t group_icon -o "$file_dest" "$file"
  end
end

main $argv

#_dada_fish _register_bin regular "extract_win_icons" "fn… [-d]" "extract_win_icons.fish" "Extracts Windows icons from files"
#_dada_fish _register_dependency "brew" "icoutils" "wrestool"
