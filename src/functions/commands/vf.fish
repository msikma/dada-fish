# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

set -gx DADA_VF_DIR ~/".venv"

function _vf_new --argument-names name
  if [ -z "$name" ]
    echo 'vf: error: input a virtualenv name'
    return
  end
  if [ -d "$DADA_VF_DIR/$name" ]
    echo "vf: error: virtualenv \"$name\" already exists"
    return
  end
  python -m venv create "$DADA_VF_DIR/$name"
end

function _vf_ls
  set vfs (find "$DADA_VF_DIR" -mindepth 1 -maxdepth 1 -type d)
  if [ (count $vfs) -gt 0 ]
    echo 'Virtual environments:'
    echo
  end
  for vf in $vfs
    set cfg "$vf/pyvenv.cfg"
    set line (cat "$cfg" | grep 'python@' | head -n1)
    set ver (echo "$line" | string match -gr 'python@([0-9.]+)')
    echo "* "(set_color green)(basename "$vf")(set_color normal)" ("(set_color yellow)"Python $ver"(set_color normal)")"
  end
end

function _vf_usage --argument-names exit_code
  echo 'usage: vf [-h] {activate, deactivate, ls}'
  echo
  echo 'Manages Python virtual environments.'
  echo
  echo 'arguments:'
  echo '  -h, --help      show this help message and exit'
  echo
  echo 'commands:'
  echo '  new NAME        creates a new venv by name'
  echo '  activate NAME   activates a venv by name'
  echo '  deactivate      deactivates the current venv'
  echo '  connect         connects the current venv to this directory'
  echo '  ls              lists all available venvs'
  return "$exit_code"
end

function _vf_activate --argument-names name
  # If no name is entered, try getting the vf name from the .venv file.
  if [ -z "$name" ]
    if [ -f ./".venv" ]
      set name (cat ./".venv")
    else
      echo "vf: error: no venv name entered"
      return
    end
  end
  source "$DADA_VF_DIR/$name/bin/activate.fish"
end

function _vf_deactivate
  deactivate
end

function _vf_connect
  if [ -f ./".venv" ]
    echo 'already connected??'
    return
  end
  if [ -z "$VIRTUAL_ENV" ]
    echo "vf: error: venv must be activated before using connect"
    return
  end
  set name (basename "$VIRTUAL_ENV")
  echo "$name" > ./".venv"
end

function vf --argument-names arg name --description "Activates Python virtualenvs"
  ! _require_cmd "virtualenv"; and return 1
  
  switch "$arg"
    case "new"
      _vf_new "$name"
    case "ls"
      _vf_ls
    case "activate"
      _vf_activate "$name"
    case "deactivate"
      _vf_deactivate
    case "connect"
      _vf_connect
    case "-h"
      _vf_usage 0
    case "--help"
      _vf_usage 0
    case ""
      _vf_usage 1
    case '*'
      _vf_usage 1
  end
end

_register_command pkg "vf" "…"
#_register_dependency "pip" "virtualenv" "virtualenv"
