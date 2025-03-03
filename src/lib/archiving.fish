# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

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
    # We've found multiple files. This is usually the case for SOOP items,
    # which are actually playlists divided into multiple items (which get merged).
    # Since the playlist .info.json files will have "(part 1)" etc. in it,
    # and a longer id, we can sort by length and get the first one.
    set sorted (
      for file in $files
        echo $file | awk '{ print length($0), $0 }'
      end | sort -n | cut -d' ' -f2-
    )
    echo "$sorted[1]"
  end
end