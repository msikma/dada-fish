# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function dada_reload --description "Reloads the system"
  source "$DADA_FISH/main.fish"
end

_register_command system "dada_reload"
