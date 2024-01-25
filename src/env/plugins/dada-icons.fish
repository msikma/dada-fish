# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

set -l _icon_parent_dirs "Code" "Code archive" "Design"

for dir in $_icon_parent_dirs
  set dada_folder_icon_path ~/"Files/Work/$dir/dada-folder-icons/icns"
  set dada_icon_path ~/"Files/Work/$dir/dada-icons/icns"

  if [ -d $dada_folder_icon_path ]
    set -g DADA_FOLDER_ICON_DIR $dada_folder_icon_path
  end

  if [ -d $dada_icon_path ]
    set -g DADA_ICON_DIR $dada_icon_path
  end
end
