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
    echo "$type $pkgname $cmd"
  end
end

## Checks for installed dependencies
function _check_deps
  set deps (_list_deps | uniq | sort)
  for n in $deps
    echo "n: $n"
  end
end
