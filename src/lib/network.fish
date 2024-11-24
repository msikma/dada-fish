# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Returns the current hostname.
function _get_hostname
  if [ (_is_macos) ]
    echo (scutil --get LocalHostName)
  else
    hostname -s
  end
end

## Returns the computer name.
function _get_computer_name
  if [ (_is_macos) ]
    echo (scutil --get ComputerName)
  else
    hostname -s
  end
end

## Prints the current local IP, e.g. "10.0.1.5"
function _get_local_ip
  # TODO: there is probably a better way to do this.
  if [ (command -v ifconfig) ]
    ifconfig | grep inet | grep broadcast | cut -d' ' -f 2 | head -n 1
  else
    hostname -I | cut -d ' ' -f1
  end
end
