# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

# Configuration root directory.
set -gx DADA_CONFIG ~/".config/dada-fish/"
set -gx DADA_CACHE ~/".cache/dada-fish/"

# Path to the database.
set -gx DADA_DB "$DADA_CACHE/db.sqlite"

# Path to the sys_vars file.
set -gx DADA_SYS_VARS "$DADA_CACHE/sys_vars.fish"
# Amount of minutes that the sys_vars are cached.
set -gx DADA_SYS_VARS_MAX_AGE_MINS "1"

# Directory where the repo is located.
set -gx DADA_FISH_REPO (realpath "$DADA_FISH/../.git")

# Size of the columns in help lists.
set -g DADA_LEFT_COL_SIZE 17
set -g DADA_RIGHT_COL_SIZE 34
set -g DADA_LEFT_COL_SIZE_LARGE 28
set -g DADA_RIGHT_COL_SIZE_LARGE 68

# By default, we set the env to "desktop".
if [ -z "$DADA_FISH_ENV" ]
  set -gx DADA_FISH_ENV "desktop"
end

# Work directories that have git repos listed.
set -g DADA_WORK_DIRS $DADA_WORK_DIRS ~/"Code" ~/"Work" ~/"Utilities" ~/"Source"
