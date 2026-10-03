# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function _ico_extract_pngs --argument-names infile outdir
  set tmp (mktemp -d)
  if not magick "$infile" "$tmp/frame_%d.png"
    rm -rf "$tmp"
    return 1
  end
  mkdir -p "$outdir"
  for frame in (find "$tmp" -name "frame_*.png" | sort -V)
    set width (magick identify -format "%w" "$frame")
    set height (magick identify -format "%h" "$frame")
    set name "icon_$width"
    if test "$width" -ne "$height"
      set name "icon_$width""x""$height"
    end
    set dest "$outdir/$name.png"
    set n 2
    while test -e "$dest"
      set dest "$outdir/$name""_""$n.png"
      set n (math $n + 1)
    end
    mv "$frame" "$dest"
  end
  rm -rf "$tmp"
end

function ico_expand --argument-names infile --description "Converts: .ico → .icoset"
  ! _require_cmd "magick"; and return 1
  if not test -f "$infile" || test -z "$infile"
    echo "ico_expand: usage: ico_expand ICO"
    echo
    echo "Extracts all sizes in the .ico file as .png files into a directory."
    return 1
  end
  set base (basename "$infile" .ico)
  if test -e "$base.icoset"
    echo "ico_expand: error: \"$base.icoset\" already exists."
    return 1
  end
  if not _ico_extract_pngs "$infile" "$base.icoset"
    echo "ico_expand: error: could not read \"$infile\"."
    rm -rf "$base.icoset"
    return 1
  end
end

_register_command conversion "ico_expand" "fn"
_register_dependency "brew" "imagemagick" "magick"
