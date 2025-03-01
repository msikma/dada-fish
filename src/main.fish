# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

# Set the source root directory for Dada Fish.
set -g DADA_FISH (status current-dirname)

source "$DADA_FISH/system/init.fish"
source "$DADA_FISH/system/log.fish"
source "$DADA_FISH/system/setup.fish"
source "$DADA_FISH/system/vars.fish"

source "$DADA_FISH/lib/archiving.fish"
source "$DADA_FISH/lib/cron.fish"
source "$DADA_FISH/lib/cache.fish"
source "$DADA_FISH/lib/backup.fish"
source "$DADA_FISH/lib/columns.fish"
source "$DADA_FISH/lib/init.fish"
source "$DADA_FISH/lib/datetime.fish"
source "$DADA_FISH/lib/db.fish"
source "$DADA_FISH/lib/deps.fish"
source "$DADA_FISH/lib/filetypes.fish"
source "$DADA_FISH/lib/fs.fish"
source "$DADA_FISH/lib/function.fish"
source "$DADA_FISH/lib/icons.fish"
source "$DADA_FISH/lib/include.fish"
source "$DADA_FISH/lib/network.fish"
source "$DADA_FISH/lib/os.fish"
source "$DADA_FISH/lib/prompt.fish"
source "$DADA_FISH/lib/register.fish"
source "$DADA_FISH/lib/repo.fish"
source "$DADA_FISH/lib/util.fish"

source "$DADA_FISH/functions/types.fish"
source "$DADA_FISH/functions/aliases.fish"
source "$DADA_FISH/functions/system/dada.fish"
source "$DADA_FISH/functions/system/help.fish"
source "$DADA_FISH/functions/system/ls.fish"
source "$DADA_FISH/functions/system/recache.fish"

if is_daemon $argv
  _dada_daemon_init
else if is_deps $argv
  _dada_deps_init
else
  _dada_interactive_init
end
