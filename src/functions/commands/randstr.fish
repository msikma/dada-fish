# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function randstr --description "Prints a random string of 16 chars"
  LC_ALL=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 16; echo ''
end

_register_command script "randstr"
