# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

# Open Watcom v2.0 base directory.
if [ -d /opt/watcom ]
  set -gx WATCOM /opt/watcom
  if [ (uname -m) = "arm64" ]
    set PATH /opt/watcom/armo64 $PATH
  else
    set PATH /opt/watcom/bino64 $PATH
  end
  set -gx EDDAT /opt/watcom/eddat
  # Target: 286 DOS
  set -gx INCLUDE $WATCOM/h
  set -gx LIB $WATCOM/lib286 $WATCOM/lib286/dos
end