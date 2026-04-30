#!/usr/bin/env fish

set USAGE 'usage: find_large_images W H'

set curr (dirname (status --current-filename))

function main --argument-names w h
  if begin [ "$w" = "-h" ]; or [ "$w" = "--help" ]; end
    echo $USAGE
    exit 0
  end
  if begin [ -z "$w" ]; or [ -z "$h" ]; end
    echo $USAGE
    exit 1
  end
  set dir "$w""x""$h"
  mkdir -p ./"$dir"
  set files (find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.tif" -o -iname "*.tiff" -o -iname "*.bmp" -o -iname "*.webp" -o -iname "*.avif" \))
  for img in $files
    set dimensions (magick identify -format "%w %h" "$img" 2>/dev/null)
    if test -z "$dimensions"
      continue
    end
    set width (echo $dimensions | cut -d' ' -f1)
    set height (echo $dimensions | cut -d' ' -f2)
    if test $width -lt $w -o $height -lt $h
      continue
    end
    cp -p "$img" ./"$dir"
  end
end

main $argv

#_dada_fish _register_bin regular "find_large_images" "w h" "find_large_images.fish" "Finds images greater than given dimensions"
