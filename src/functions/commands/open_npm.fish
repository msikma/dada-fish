# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function open_npm --description "Opens this npm pkg in the browser"
  ! _require_cmd "open" "open_npm: error: cannot open URLs on this system"; and return 1

  set pkgname (node -e "const a = require('./package.json'); a.name && console.log(a.name);" 2> /dev/null)

  if [ -z "$pkgname" ]
    echo "open_npm: error: not an npm project"
    return 1
  end

  set pkgurl "https://www.npmjs.com/package/$pkgname"
  echo (set_color yellow)"Opening npm package url: "(set_color reset)(set_color -u)"$pkgurl"
  open "$pkgurl"
end

_register_command pkg "open_npm"
