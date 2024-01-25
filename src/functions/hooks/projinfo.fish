# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

# Listens for directory change and attempts to run projinfo if applicable.
function display_project_info \
  --description 'Displays project info after changing to a project directory' \
  --on-variable dirprev

  # Run a quick check to see if this is a project directory.
  if begin
    [ ! -f ./package.json ]; and \
    [ ! -f ./requirements.txt ]; and \
    [ ! -f ./setup.py ]; and \
    [ ! -f ./setup.cfg ]; and \
    [ ! -f ./composer.json ]; end
    return
  end

  # Return if this is isn't a command directly run by the user themselves in the shell.
  if status --is-command-substitution
    return
  end

  # Check if displaying project info has temporarily been turned off, e.g. for a script.
  if begin
    [ "$NO_DIRPREV_HOOK" = 1 ]; or \
    [ (count $dirprev) -lt 3 ]; end
    return
  end

  # Display project info.
  projinfo
end
