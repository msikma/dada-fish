# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

# Various functions that print information about the user's system.

set _uname (uname)

# Returns whether the current system is macOS or another Unix-like.
function _is_macos
  # Check if the 'defaults' command exists.
  command -v defaults
end

# Returns a human-readable version number for the current OS.
function _get_os_version
  if [ (_is_macos) ]
    set os_name (sw_vers -productName)
    set os_version (sw_vers -productVersion)
    echo "$os_name $os_version"
  else
    lsb_release -d | cut -d":" -f2 | xargs
  end
end

# Returns a human-readable kernel string.
function _get_kernel_version
  if [ (_is_macos) ]
    uname -v | sed -e 's/:.*;/;/g'
  else
    uname -v
  end
end

## Ensures that a required variable is present.
function _require_var --argument-names var errmsg
  set -q "$argv[1]"
  or begin
    if [ -z "$errmsg" ]
      echo "error: required variable is not set: $argv[1]"
    else
      echo "$errmsg"
    end
    return 1
  end
  return 0
end

## Ensures that a required command is present.
function _require_cmd --argument-names cmd errmsg
  if [ ! (command -v "$cmd") ]
    if [ -z "$errmsg" ]
      echo "error: required command is missing: $cmd"
    else
      echo "$errmsg"
    end
    return 1
  end
  return 0
end
