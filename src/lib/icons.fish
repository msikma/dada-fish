# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Returns all folder icons found on the system.
function _find_folder_icons
  if [ -d "$DADA_FOLDER_ICON_DIR" ]
    find "$DADA_FOLDER_ICON_DIR" -maxdepth 1 -mindepth 1 -type f -name "*.icns" | sort
  end
end

## Returns all miscellaneous icons found on the system.
function _find_other_icons
  if [ -d "$DADA_ICON_DIR" ]
    find "$DADA_ICON_DIR" -maxdepth 1 -mindepth 1 -type f -name "*.icns" | sort
  end
end
