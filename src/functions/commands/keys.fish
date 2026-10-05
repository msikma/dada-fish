# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function keys --description "Displays the current ssh keys" --argument-names fn
  for n in ~/.ssh/*.pub
    ssh-keygen -lf "$n"
  end
end

_register_command pkg "keys"
