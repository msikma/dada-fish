# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function vacuum --description "Vacuums a sqlite3 db" --argument-names src dst
  if test -z "$src"
    echo "usage: vacuum SOURCE_FILE [DESTINATION_FILE]" >&2
    return 1
  end

  if not test -f "$src"
    echo "vacuum: no such file: $src" >&2
    return 1
  end

  if test -z "$dst"
    set -l base (basename -- "$src")
    set -l stem (string replace -r '\.[^.]*$' '' -- "$base")
    set -l ext (string replace -r '^.*(\.[^.]*)$' '$1' -- "$base")
    if test "$ext" = "$base"
      set ext ".sqlite3"
    end
    set dst "$stem"_(date +%s)"$ext"
  end

  if test -e "$dst"
    echo "vacuum: destination already exists: $dst" >&2
    return 1
  end
  
  sqlite3 -- "$src" "VACUUM INTO '$dst'"
end

_register_command pkg "vacuum" "src dst"
