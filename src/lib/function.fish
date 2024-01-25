# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Returns the description of a defined function. Returns "n/a" if not found.
function _get_function_description --argument-names name
  functions -Dv "$name" | sed -n '5p'
end
