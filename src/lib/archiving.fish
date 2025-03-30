# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

# Escapes XML entities, e.g. & to &amp;
function _escape_entities --argument-names string
  set escaped (echo "$string" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g' -e "s/'/\&apos;/g")
  # Also: remove invisible control chars (except tab, newline, carriage return).
  echo "$escaped" | tr -d '\000-\010\013\014\016-\037'
end

# Writes a .webloc file.
function _write_webloc --argument-names url target_basename
  set escaped (_escape_entities "$url")
  set content "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>URL</key>
	<string>$escaped</string>
</dict>
</plist>"
  echo "$content" > "$target_basename.webloc"
end

## Returns a filename (or directory name) suggestion for a yt-dlp info.json file.
function _ytdlp_get_name --argument-names info_json_fn
  ! _require_cmd "jq"; and return 1
  set title (_sanitize_filename (cat "$info_json_fn" | jq -r ".title"))
  set uploader (_sanitize_filename (cat "$info_json_fn" | jq -r ".uploader"))
  set upload_date (_sanitize_filename (cat "$info_json_fn" | jq -r ".upload_date"))
  set id (_sanitize_filename (cat "$info_json_fn" | jq -r ".id"))
  # E.g. 20190101 [uploader name] My Video Title [kOaejxdh2Mx]
  _sanitize_filename "$upload_date [$uploader] $title [$id]"
end

## Finds the yt-dlp .info.json file in a given directory.
function _ytdlp_find_info_json --argument-names dir
  set files (find "$dir" -type f -maxdepth 1 -mindepth 1 -iname "*.info.json")
  if test (count $files) -le 1
    echo "$files[1]"
  else
    # If we've found multiple files, that usually means this is a playlist.
    # Some .info.json files will have type "video" and one will have "playlist".
    # Find the "playlist" item and use that one.
    set playlist_files
    for file in $files
      if test (cat "$file" | jq -r "._type") = "playlist"
        set -a playlist_files $file
      end
    end
    # Just in case we still have multiple files here, get the shortest one.
    # Or, if we don't have any playlist files at all, pick the shortest from the others.
    # This is because the "main" item will likely be the shortest, as others
    # will have (part 1) etc. in their filename.
    if test (count $playlist_files) -gt 0
      set relevant_files $playlist_files
    else
      set relevant_files $files
    end
    set sorted (
      for file in $relevant_files
        echo $file | awk '{ print length($0), $0 }'
      end | sort -n | cut -d' ' -f2-
    )
    echo "$sorted[1]"
  end
end