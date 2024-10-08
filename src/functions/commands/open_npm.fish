# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function open_npm --description "Opens this npm pkg in the browser"
  ! _require_cmd "open" "open_npm: error: cannot open URLs on this system"; and return 1
  ! _require_cmd "jq"; and return 1

  set pkg_name (jq -r ".name" < "./package.json" 2> /dev/null)

  if [ -z "$pkg_name" -o "$pkg_name" = "null" ]
    echo "open_npm: error: not an npm project"
    return 1
  end

  set pkgurl "https://www.npmjs.com/package/$pkg_name"
  echo (set_color yellow)"Opening npm package url: "(set_color reset)(set_color -u)"$pkgurl"
  open "$pkgurl"
end

_register_command pkg "open_npm"
_register_dependency "brew" "jq" "jq"
