#!/usr/bin/env fish

set curr (dirname (status --current-filename))
source "$curr/../../lib/os.fish"

set USAGE 'usage: extract_win_icons fn dest'

function main --argument-names icon_container dest
  ! _require_cmd "wrestool"; and return 1

  if [ -z "$icon_container" ]
    echo "$USAGE"
    return 1
  end
  if [ -z "$dest" ]
    set dest ./"$icon_container""_icons/"
    if [ ! -d "$dest" ]
      mkdir -p "$dest"
    end
  end
  if [ ! -d "$dest" ]
    echo "extract_win_icons: error: directory $dest does not exist"
    return 1
  end
  
  wrestool -x -t group_icon -o "$dest" "$icon_container"
end

main $argv

#_dada_fish _register_bin regular "extract_win_icons" "path" "extract_win_icons.fish" "Extracts Windows icons from files"
#_dada_fish _register_dependency "brew" "wrestool" "icoutils"
