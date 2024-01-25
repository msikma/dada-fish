# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function myip --description "Prints the current IP address"
  # TODO: this should probably be done in a more clever way.
  if [ "$DADA_FISH_ENV" = "desktop" ]
    if [ (command -v ifconfig) ]
      ifconfig | grep inet | grep broadcast | cut -d' ' -f 2 | head -n 1
    else
      hostname -I | cut -d ' ' -f1
    end
  else
    hostname -I | cut -d ' ' -f1
  end
end

_register_command network "myip"
