#!/usr/bin/env fish

set USAGE 'usage: find_yt_dupes NEW_DIR OLD_DIR'

function main --argument-names new_dir old_dir
  if not test -d "$new_dir"
    echo "$USAGE"
    return 1
  end
  if not test -d "$old_dir"
    echo "$USAGE"
    return 1
  end
  for file in "$new_dir"/*
    if not test -f "$file"
      continue
    end

    set youtube_id (string match -r '\[([^][]{11})\]' "$file" | tail -n 1)

    if test -n "$youtube_id"
      set found_in_archive (find "$old_dir" -name '*\['"$youtube_id"'\]*' -print -quit)
      if test -n "$found_in_archive"
        echo "#" "$found_in_archive"
        echo "rm" '"'"$file"'"'
      end
    end
  end
end

main $argv

#_dada_fish _register_bin regular "find_yt_dupes" "new old" "find_yt_dupes.fish" "Finds Youtube archive duplicates"
