# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function open_repo --description "Opens this repo in the browser"
  ! _require_cmd "open" "open_npm: error: cannot open URLs on this system"; and return 1
  ! _require_cmd "jq"; and return 1

  # Note: only supports NodeJS packages.
  if [ -e "./package.json" ]
    set url (jq -r ".homepage" < "./package.json" 2> /dev/null)
  end

  if [ -z "$url" -o "$url" = "null" ]
    echo "open_repo: error: could not find repository URL"
    return 1
  end
  
  echo (set_color yellow)"Opening repository homepage: "(set_color reset)(set_color -u)"$url"
  open "$url"
end

_register_command pkg "open_repo"
_register_dependency "brew" "jq" "jq"
