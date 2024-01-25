# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

set -gx DEVKITPRO /opt/devkitpro
set -gx DEVKITARM "$DEVKITPRO/devkitARM"
set -gx CTRULIB "$DEVKITPRO/libctru"
set -gx CTRBANNERTOOL "/$UDIR/msikma/.bin/misc-bin/bannertool"
set -l CITRADIR /Applications/Citra

if [ -d $DEVKITPRO ]
  set PATH $DEVKITPRO/tools/bin/ $PATH
  set PATH $DEVKITPRO/pacman/bin/ $PATH
end
if [ -d $DEVKITARM/bin ]
  set PATH $DEVKITARM/bin $PATH
end
if [ -e $CITRADIR/nightly/citra ]
  set PATH $CITRADIR/nightly/ $PATH
else if [ -e $CITRADIR/canary/citra ]
  set PATH $CITRADIR/canary/ $PATH
end
