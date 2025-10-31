#!/usr/bin/env fish

set USAGE 'usage: find_scans STR'

set curr (dirname (status --current-filename))
source "$curr/../../env/plugins/scans.fish"

function main --argument-names str
  if begin [ "$str" = "-h" ]; or [ "$str" = "--help" ]; end
    echo $USAGE
    exit 0
  end
  if [ -z "$str" ]
    echo $USAGE
    exit 1
  end
  ls "$SCAN_BUNDLES_DIR" | grep -i "$str"
end

main $argv

#_dada_fish _register_bin regular "find_scans" "str" "find_scans.fish" "Finds scan bundles by a given name"
