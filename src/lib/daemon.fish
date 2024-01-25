# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Checks whether the system was invoked with the --daemon argument.
function is_daemon
  if contains -- --daemon $argv
    return 0
  else
    return 1
  end
end
