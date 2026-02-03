#!/usr/bin/env fish

set curr (dirname (status --current-filename))
source "$curr/../../lib/os.fish"

set USAGE 'usage: bw_set_date [-h|--help] FILE[, FILE, ..]

Sets the file creation dates of Brood War .rep files to their played date.'

function bw_set_date
  ! _require_cmd "gdate"; and return 1
  ! _require_cmd "screp"; and return 1
  ! _require_cmd "jq"; and return 1
  if test (count $argv) -lt 1
    echo "$USAGE"
    exit 1
  end
  for fn in $argv
    set filedate (screp -computed=false -indent=false "$fn" | jq -r ".Header.StartTime" 2> /dev/null)
    if test "$filedate" = ""
      echo (set_color yellow)"$fn"(set_color normal)": not a Brood War replay file"(set_color normal)
      continue
    end
    set formatted_filedate (gdate -d "$filedate" "+%m/%d/%Y %H:%M:%S")
    echo (set_color yellow)"$fn"(set_color normal)": setting date "(set_color cyan)"\"$filedate\""(set_color normal)
    SetFile -d "$formatted_filedate" -m "$formatted_filedate" "$fn"
  end
end

bw_set_date $argv

#_dada_fish _register_bin games "bw_set_date" "fn…" "bw_set_date.fish" "Sets dates of BW replays to their played date"
