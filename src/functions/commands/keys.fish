# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function keys --description "Displays the current ssh keys"
  set rows
  for n in ~/.ssh/*.pub
    set parts (string match -r '^(\d+) (\S+) (.*) \((\S+)\)$' -- (ssh-keygen -lf "$n"))
    or continue
    set -a rows (string join \t (basename "$n") $parts[5] $parts[2] $parts[3] $parts[4])
  end
  begin
    printf "%s\n" (string join \t FILE TYPE BITS FINGERPRINT COMMENT)
    printf "%s\n" $rows
  end | column -t -s \t
end

_register_command pkg "keys"
