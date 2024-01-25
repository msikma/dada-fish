# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

set reset (set_color reset)

set -gx LESS_TERMCAP_mb (set_color -o yellow)
set -gx LESS_TERMCAP_md (set_color -o green)
set -gx LESS_TERMCAP_me "$reset"
set -gx LESS_TERMCAP_se "$reset"
set -gx LESS_TERMCAP_so (set_color -o yellow)
set -gx LESS_TERMCAP_ue "$reset"
set -gx LESS_TERMCAP_us (set_color -ou red)
