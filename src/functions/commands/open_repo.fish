# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function open_repo --description "Opens this repo in the browser"
  ! _require_cmd "open" "open_npm: error: cannot open URLs on this system"; and return 1

  # Note: only supports NodeJS packages.
  if [ -e "./package.json" ]
    set url (node -e "const a = require('./package.json'); a.homepage && console.log(a.homepage);" 2> /dev/null)
  end

  if [ -z "$url" ]
    echo "open_repo: error: could not find repository URL"
    return 1
  end
  
  echo (set_color yellow)"Opening repository homepage: "(set_color reset)(set_color -u)"$url"
  open "$url"
end

_register_command pkg "open_repo"
