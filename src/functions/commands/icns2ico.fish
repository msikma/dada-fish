# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function icns2ico --argument-names infile --description "Converts: .icns → .ico"
  ! _require_cmd "iconutil"; and return 1
  ! _require_cmd "magick"; and return 1
  if not test -f "$infile" || test -z "$infile"
    echo "icns2ico: usage: icns2ico ICNS"
    return 1
  end
  set base (basename "$infile" .icns)
  if test -e "$base.ico"
    echo "icns2ico: error: \"$base.ico\" already exists."
    return 1
  end

  set tmp (mktemp -d)
  if not iconutil --convert iconset "$infile" --output "$tmp/$base.iconset"
    echo "icns2ico: error: could not read \"$infile\"."
    rm -rf "$tmp"
    return 1
  end

  set widths
  set files
  for file in (find "$tmp/$base.iconset" -name "*.png" | sort -V)
    set width (magick identify -format "%w" "$file")
    set height (magick identify -format "%h" "$file")
    if test "$width" -ne "$height"; or contains "$width" $widths
      continue
    end
    set -a widths "$width"
    set -a files "$file"
  end

  set pngs
  for size in 16 32 48 64 96 128 256
    set i (contains -i -- "$size" $widths)
    if test -n "$i"
      set -a pngs $files[$i]
      continue
    end
    set -l sources
    for larger in $widths
      if test "$larger" -gt "$size"
        set -a sources "$larger"
      end
    end
    if test (count $sources) -eq 0
      continue
    end
    set best (printf "%s\n" $sources | sort -n | head -n 1)
    set out "$tmp/scaled_$size.png"
    set j (contains -i -- "$best" $widths)
    magick "$files[$j]" -filter Lanczos -resize "$size""x""$size" "$out"
    set -a pngs "$out"
  end

  if test (count $pngs) -eq 0
    echo "icns2ico: error: no usable sizes found in \"$infile\"."
    rm -rf "$tmp"
    return 1
  end
  magick $pngs "$base.ico"
  rm -rf "$tmp"
end

_register_command conversion "icns2ico" "fn"
_register_dependency "brew" "imagemagick" "magick"
