# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Makes a new executable script (note: a filename ending in .py2 or .py3 will result in a .py file with appropriate shebang).
## Invoke like: 'newx file.fish' or 'newx file.js', etc.
function newx \
  --argument-names fn \
  --description "Makes a new executable script"
  # Retrieve file extension and filename (even in cases like my.file.js; it will yield 'my.file' and 'js').
  set bn (_file_base $fn)
  set ext (_file_ext $fn)

  # Ensure we keep linebreaks.
  _ext_shebang $ext | read -lz she

  # When using .py2 or .py3 we really want .py in the actual filename.
  # .py2 is used to ensure the shebang runs Python 2, but the actual filename is .py.
  set ext (_clean_py_ext $ext)

  # If no file extension, give a warning.
  if [ $bn = $ext ]
    echo 'newx: warning: no file extension was given (using bash shebang)'
    set she (_ext_shebang 'bash')
    set fn "$bn"
  else
    set fn "$bn.$ext"
  end

  echo "$she" > $fn
  chmod +x $fn
  stat -f "%Sp %N:" $fn
  echo -n $she
end

## Turns 'py2' and 'py3' into just 'py' for Python shell scripts; leaves others intact
function _clean_py_ext --argument-names ext
  switch $ext
  case 'py2'
    echo 'py'
  case 'py3'
    echo 'py'
  case '*'
    echo $ext
  end
end

## Prints an appropriate shebang for a file extension
function _ext_shebang --argument-names ext
  # Global prefix for each type.
  echo -n '#!/usr/bin/env '

  switch $ext
  case 'js'
    echo 'node'
  case 'py'
    echo 'python3'
  case 'py2'
    echo 'python2'
    echo '# coding=utf8'
  case 'py3'
    echo 'python3'
  case 'php'
    echo 'php'
  case 'rb'
    echo 'ruby'
  case 'sh'
    echo 'bash'
  case 'bash'
    echo 'bash'
  case 'fish'
    echo 'fish'
  case '*'
    echo '?'
  end
end

_register_command script "newx" "fn"
