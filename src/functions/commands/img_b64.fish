# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function img_b64 --description "Converts image to base64 <img>"
  ! _require_cmd "magick"; and return 1

  set fn "$argv[1]"
  if [ -z "$fn" ]
    echo "img_b64: usage: img_b64 FILENAME"
    return 1
  end
  if [ ! -f "$fn" ]
    echo "img_b64: error: file \"$fn\" does not exist"
    return 1
  end

  # Retrieves the mime type, e.g. 'image/png'
  set mime (file -bN --mime-type "$fn")

  # Converts the file itself to Base64
  set content (base64 -b 0 < "$fn")

  # Detect file dimensions.
  set width (magick identify -ping -format "%w" "$fn"[0])
  set height (magick identify -ping -format "%h" "$fn"[0])

  printf "<img src=\"data:%s;base64,%s\" width=\"$width\" height=\"$height\" />\n" $mime $content
end

_register_command media "img_b64" "fn"
_register_dependency "brew" "magick" "imagemagick"
