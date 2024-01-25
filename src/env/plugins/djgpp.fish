# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

set -x DJGPP_PREFIX /usr/local/djgpp
set -x DJGPP_CC /usr/local/djgpp/bin/i586-pc-msdosdjgpp-gcc
set -x DJGPP_RANLIB /usr/local/djgpp/bin/i586-pc-msdosdjgpp-ranlib
set -x DJDIR /usr/local/djgpp/djgpp.env

# Allegro root directory to activate, e.g. ~/source/liballeg.4.4.2-osx.
if [ -d "$DADA_ALLEGRO_DIR/tools/" ]
  set PATH "$DADA_ALLEGRO_DIR/tools/" $PATH
end
# DJGPP root directory, e.g. ~/source/djgpp.
if [ -d "$DJGPP_PREFIX/bin/" ]
  set PATH "$DJGPP_PREFIX/bin/" $PATH
end
