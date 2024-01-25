# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

set PATH /usr/bin $PATH
set PATH /bin /usr/sbin /sbin $PATH
set PATH /usr/local/sbin $PATH
set PATH /usr/local/bin $PATH
set PATH ~/.bin $PATH

set -x EDITOR nano
set -x GIT_EDITOR nano
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8

# Allow the internal scripts to be found.
set PATH "$DADA_CONFIG/src/functions/bin/" $PATH

# Include the user's configuration.
if [ -e ~/".config/dada-fish/config.fish" ]
  source ~/".config/dada-fish/config.fish"
end

# Include machine-specific env settings if any.
if [ -e ~/".config/env.fish" ]
  source ~/".config/env.fish"
end

# Whether this is designated as a remote server instead of a local machine.
# This causes the hostname to be displayed in the prompt.
set DADA_IS_SERVER (if test -e ~/".dada-server"; echo "1"; end)
