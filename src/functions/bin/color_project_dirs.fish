#!/usr/bin/env fish

set curr (dirname (status --current-filename))
source "$curr/../../system/vars.fish"
source "$curr/../../env/plugins/dada-icons.fish"
source "$curr/../../lib/os.fish"
source "$curr/../../lib/icons.fish"

set USAGE 'usage: color_project_dirs [path] [-h|--help] [-d|--dry-run]'

function _is_nodejs --argument-names dir
  if [ -f "$dir/package.json" ]
    return 0
  end
  return 1
end

function _is_php --argument-names dir
  if [ -f "$dir/composer.json" -o -f "$dir/composer.lock" ]
    return 0
  end
  return 1
end

function _is_python --argument-names dir
  if [ -f "$dir/setup.cfg" -o -f "$dir/setup.py" ]
    return 0
  end
  return 1
end

function main --argument-names arg1 arg2
  ! _require_cmd "fileicon"; and return 1

  set dryrun 0
  if begin [ "$arg1" = "-h" ]; or [ "$arg1" = "--help" ]; end
    echo $USAGE
    exit 0
  end
  if begin [ "$arg1" = "-d" ]; or [ "$arg1" = "--dry-run" ]; end
    set dryrun 1
    set basedir "$arg2"
  end
  if [ -z "$dir" ]
    set basedir "."
  end

  set ic_folders (_find_folder_icons)
  set ic_others (_find_other_icons)
  set icons $ic_folders $ic_others
  
  set dirs (find "$basedir" -type d -maxdepth 1 -mindepth 1 | sort)
  for dir in $dirs
    set color (set_color black)
    set icon "-"
    set type "-"

    # Determine what kind of project this is.
    if _is_nodejs "$dir"
      set color (set_color green)
      set icon "green"
      set type "NodeJS"
    else if _is_php "$dir"
      set color (set_color blue)
      set icon "darkblue"
      set type "PHP"
    else if _is_python "$dir"
      set color (set_color magenta)
      set icon "violet"
      set type "Python"
    else
      # Nothing found, so do nothing.
      set type "-"
    end

    printf "%s%-20s%s %s\n" "$color" "$dir" (set_color reset) "$type"

    # Actually change the icon.
    if [ "$dryrun" -eq 0 -a "$type" != "-" ]
      set target_icon
      for n in (seq (count $icons))
        set icon_path $icons[(math $n + 1)]
        set name (basename "$icon_path" ".icns")
        if [ "$name" = "$icon" ]
          set target_icon "$icon_path"
          break
        end
      end

      if [ -z "$target_icon" ]
        echo "color_project_dirs: error: can't find icon file: $icon"
        return 1
      end

      fileicon -q set "$dir" "$target_icon"
    end
  end
end

main $argv

#_dada_fish _register_bin regular "color_project_dirs" "path" "color_project_dirs.fish" "Colors project folders according to their type"
#_dada_fish _register_dependency "brew" "fileicon" "fileicon"
