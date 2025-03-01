# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Returns a filename (or directory name) suggestion for a yt-dlp info.json file.
function _ytdlp_get_name --argument-names info_json_fn
  ! _require_cmd "jq"; and return 1
  set title (_sanitize_filename (cat "$info_json_fn" | jq -r ".title"))
  set uploader (_sanitize_filename (cat "$info_json_fn" | jq -r ".uploader"))
  set id (_sanitize_filename (cat "$info_json_fn" | jq -r ".id"))
  # E.g. [uploader name] My Video Title [kOaejxdh2Mx]
  _sanitize_filename "[$uploader] $title [$id]"
end