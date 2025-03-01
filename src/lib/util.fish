# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Replaces non-filename characters with underscore and trims.
function _sanitize_filename_part --argument-names string
  echo "$string" | string replace -ra '[/\\:*?"<>|]' '_' | string replace -ra '\s+' ' ' | string trim -c ' .'
end

## Sanitizes a filename.
function _sanitize_filename --argument-names string
  set parts (string split "." "$string")
  if test (count $parts) -eq 1
    _sanitize_filename_part "$string"
  else
    set name (string join "." $parts[1..-2])
    set ext "$parts[-1]"
    echo (_sanitize_filename_part "$name").(_sanitize_filename_part "$ext")
  end
end