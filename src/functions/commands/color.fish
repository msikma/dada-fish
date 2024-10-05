# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _print_icons --argument-names title
  echo (set_color green)"$title:"(set_color reset)
  set icons $argv[2..-1]
  set width 0
  for n in (seq (count $icons))
    set icon $icons[$n]
    set name (basename "$icon" ".icns")
    set name_width (string length -V "$name")
    set width (math "$width" + "$name_width")
    if [ $n -gt 1 ]
      printf (set_color -d yellow)", "(set_color reset)
    end
    if [ "$width" -gt 70 ]
      set width 0
      printf "\n"
    end
    printf (set_color yellow)"$name"(set_color reset)
  end
  printf "\n"
end

function color --description "Sets icon to a file or directory" --argument-names iconname
  ! _require_cmd "fileicon"; and return 1

  set ic_folders (_find_folder_icons)
  set ic_others (_find_other_icons)
  set icons $ic_folders $ic_others

  if [ (count $icons) -eq 0 ]
    echo "color: error: no icon files were found on the system."
    return 1
  end

  if [ -z "$iconname" -o -z "$argv[2]" ]
    echo "color: usage: color ICON_NAME FN…"
    if [ (count $ic_folders) -gt 0 ]
      echo
      _print_icons "Folder icons" $ic_folders
    end
    if [ (count $ic_others) -gt 0 ]
      echo
      _print_icons "Other icons" $ic_others
    end
    echo
    return 1
  end

  set files $argv[2..-1]

  # Check if the requested icon exists.
  set target_icon
  for n in (seq (count $icons))
    set icon $icons[$n]
    set name (basename "$icon" ".icns")
    if [ "$name" = "$iconname" ]
      set target_icon "$icon"
      break
    end
  end
  if [ -z "$target_icon" ]
    echo "color: error: can't find icon file: $iconname"
    return 1
  end

  # Check if every target exists.
  for n in (seq (count $files))
    set target $files[$n]
    if [ ! -d "$target" -a ! -f "$target" ]
      echo "color: error: can't find file or directory: $target"
      return 1
    end
  end

  # Set the requested icon to every file.
  for n in (seq (count $files))
    set target $files[$n]
    fileicon set "$target" "$target_icon"
  end
end

_register_command regular "color" "color fn…"
_register_dependency "brew" "fileicon" "fileicon"
