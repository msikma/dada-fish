# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Prints out an error that occurred internally.
function _log_error --argument-names text
  echo "dada: error: $text"
end
