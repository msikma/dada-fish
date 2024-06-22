#!/usr/bin/env fish

set curr (dirname (status --current-filename))
set USAGE 'usage: im_repage_horizontal.fish FILE[, FILE, ..]'

function main --argument-names arg
  if begin [ "$arg" = "-h" ]; or [ "$arg" = "--help" ]; end
    echo $USAGE
    exit 0
  end
  set outdir "_out"
  mkdir -p "$outdir"
  set n 0
  for image in $argv
    set base (basename "$image")
    set ext (string split -r . "$base" | tail -n 1)

    magick "$image" -crop 50%x100% +repage -quality 80 -sampling-factor 1x1 "$outdir"/"_Page "(printf "%02d" "$n")".$ext"

    set n (math "$n" + 1)
  end
  set n 0
  find "$outdir" -name ".DS_Store" -type f -delete
  for image in (find "$outdir" -type f | sort)
    set base (basename "$image")
    set ext (string split -r . "$base" | tail -n 1)
    mv "$image" "$outdir"/"Page "(printf "%02d" "$n")".$ext"
    set n (math "$n" + 1)
  end
end

main $argv

#_dada_fish _register_bin media "im_repage_horizontal" "path" "im_repage_horizontal.fish" "Splits input images horizontally to 50/50 output"
