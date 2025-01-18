#!/usr/bin/env fish

set USAGE 'usage: collect_files PATH'

function collect_files --argument-names dir
  if begin [ "$dir" = "-h" ]; or [ "$dir" = "--help" ]; end
    echo $USAGE
    exit 0
  end
  if [ -z "$dir" ]
    set dir "."
  end
  set outdir "$dir/filetypes"
  mkdir -p "$outdir"
  echo (set_color yellow)"Collecting files by extension from: "(set_color cyan)"$dir"(set_color normal)
  echo (set_color yellow)"Saving to: "(set_color cyan)"$outdir"(set_color normal)

  set files (find "$dir" -mindepth 1 -type f)
  set total_count (count $files)
  set processed 0

  for file in $files
    set processed (math $processed "+" 1)
    set percentage (math (math $processed "*" 100) "/" $total_count)
    set ext (string split -r . "$file" | tail -n 1)
    mkdir -p "$outdir/$ext"
    cp "$file" "$outdir/$ext/"
    printf "\r"(set_color yellow)"Progress: "(set_color cyan)"%.1f%%"(set_color normal) "$percentage"
  end
  echo ""
  echo (set_color yellow)"Done."(set_color normal)
end

collect_files $argv

#_dada_fish _register_bin regular "collect_files" "path" "collect_files.fish" "Collects files by extension"
