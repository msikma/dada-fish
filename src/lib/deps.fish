# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Dependencies
##
## Functions for checking whether dependencies are installed properly.

## Lists out all the dependencies.
function _list_deps
  for n in (seq 1 3 (count $_DADA_DEPS))
    set type $_DADA_DEPS[$n]
    set pkgname $_DADA_DEPS[(math "$n + 1")]
    set cmd $_DADA_DEPS[(math "$n + 2")]
    echo "$pkgname|$cmd|$type"
  end
end

## Lists out all install commands for dependencies.
function _list_dep_install_cmds
  set deps (_list_deps | sort | uniq)
  for n in $deps
    set split (string split "|" $n)
    set pkgname "$split[1]"
    set cmd "$split[2]"
    set type "$split[3]"
    if ! command -v "$cmd" > /dev/null 2>&1
      if [ "$type" = "brew" ]
        echo "brew install $pkgname # for $cmd"
      else if [ "$type" = "pip" ]
        echo "pip install $pkgname # for $cmd"
      else
        echo "type: $type; pkgname: $pkgname; cmd: $cmd"
      end
    end
  end
end

## Checks for installed dependencies and prompts the user to install them.
function _check_deps
  set deps (_list_dep_install_cmds)
  if [ (count $deps) -eq 0 ]
    echo "All dependencies installed."
  else
    echo "The following dependencies are not yet installed:"
    echo ""
    for dep in $deps
      echo "$dep"
    end
  end
end