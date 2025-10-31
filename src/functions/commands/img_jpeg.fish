# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

# JPEG conversion quality (0-100).
set -g _jpeg_quality 90

function img_jpeg --description "Converts images to JPEG"
  ! _require_cmd "magick"; and return 1
  for filepath in $argv[1..-1]
    set base (_file_base $filepath)
    set ext (_file_ext $filepath | lowercase)

    # Files that are already .jpg or .jpeg are skipped.
    if [ "$ext" = "jpg" -o "$ext" = "jpeg" ]
      echo "img_jpeg: skipping: $filepath"
      continue
    end

    set target "$base.jpg"
    magick -format jpg -compress jpeg -quality "$_jpeg_quality" "$filepath" "$target"
  end
end

_register_command media "img_jpeg" "fn…"
_register_dependency "brew" "imagemagick" "magick"
