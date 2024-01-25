# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function cclear --description "Clears the screen and buffer"
  clear; printf '\e[3J'
end

_register_command regular "cclear"
