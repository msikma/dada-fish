# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

# Activates virtual environments if applicable.
function activate_vf \
  --description 'Activates virtualenv if applicable' \
  --on-variable dirprev

  if begin
    [ "$NO_DIRPREV_HOOK" = 1 ]; or \
    [ ! -f ./".venv" ]; or \
    status --is-command-substitution; end
    return
  end

  set name (cat ./".venv")
  vf activate "$name"
end
