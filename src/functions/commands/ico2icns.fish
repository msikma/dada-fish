# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function ico2icns --argument-names infile --description "Converts: .ico → .icns"
  ! _require_cmd "iconutil"; and return 1
  ! _require_cmd "magick"; and return 1
  if not test -f "$infile" || test -z "$infile"
    echo "ico2icns: usage: ico2icns ICO"
    echo
    echo "Only sizes that exist in the .ico are used (16, 32, 64, 128, 256)."
    return 1
  end
  set base (basename "$infile" .ico)
  if test -e "$base.icns"
    echo "ico2icns: error: \"$base.icns\" already exists."
    return 1
  end

  set tmp (mktemp -d)
  if not _ico_extract_pngs "$infile" "$tmp/pngs"
    echo "ico2icns: error: could not read \"$infile\"."
    rm -rf "$tmp"
    return 1
  end

  set slots \
    16 icon_16x16 \
    32 icon_32x32 \
    32 icon_16x16@2x \
    64 icon_32x32@2x \
    128 icon_128x128 \
    256 icon_256x256 \
    256 icon_128x128@2x

  set iconset "$tmp/$base.iconset"
  mkdir -p "$iconset"
  set count 0
  for n in (seq 1 2 (count $slots))
    set size $slots[$n]
    set name $slots[(math $n + 1)]
    set src "$tmp/pngs/icon_$size.png"
    if test -f "$src"
      cp "$src" "$iconset/$name.png"
      set count (math $count + 1)
    end
  end

  if test $count -eq 0
    echo "ico2icns: error: no sizes usable for .icns found in \"$infile\" (need 16, 32, 64, 96, 128 or 256)."
    rm -rf "$tmp"
    return 1
  end
  iconutil --convert icns "$iconset" --output "$base.icns"
  rm -rf "$tmp"
end

_register_command conversion "ico2icns" "fn"
_register_dependency "brew" "imagemagick" "magick"
