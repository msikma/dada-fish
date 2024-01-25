# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

set FUJI_BRYCE_DIR ~/"Files/VMs/FujiXP/Shared/Bryce/"
set VESUVIUS_BRYCE_DIR ~/"Files/VMs/VesuviusXP/Files/Bryce/"

if [ -d "$FUJI_BRYCE_DIR" ]
  set -gx DADA_BRYCE_DIR "$FUJI_BRYCE_DIR"
else
  set -gx DADA_BRYCE_DIR "$VESUVIUS_BRYCE_DIR"
end
