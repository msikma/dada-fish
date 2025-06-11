# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function ico_pack --argument-names infile --description "Converts: .icoset → .ico"
  ! _require_cmd "magick"; and return 1
  if not test -d "$infile" || test -z "$infile"
    echo "ico_pack: usage: ico_pack ICOSET"
    echo
    echo "ICOSET must be a directory with .png files inside."
    echo "For example: "(set_color blue)"ico_pack"(set_color cyan)" ./my_icon.icoset"(set_color black)" # generates my_icon.ico"(set_color normal)
    return 1
  end
  set basedir (basename "$infile" .icoset)
  if test -e "$basedir".ico
    echo "ico_pack: error: \"$basedir.ico\" already exists."
    return 1
  end
  set png_files (find "$infile" -name "*.png" | sort -V)
  set valid_sizes 16 24 32 48 64 96 128 192 256
  for file in $png_files
    set base (basename "$file")
    set width (magick identify -format "%w" "$file")
    set height (magick identify -format "%h" "$file")
    if test "$width" -ne "$height"
      echo "ico_pack: error: $base - not a square image: $width""x""$height"
      return 1
    end
    if not contains "$width" $valid_sizes
      echo "ico_pack: error: $base - invalid size: $width""x""$height (must be in: $valid_sizes)"
      return 1
    end
  end
  magick $png_files "$basedir".ico
end

_register_command conversion "ico_pack" "fn"
_register_dependency "brew" "imagemagick" "magick"
