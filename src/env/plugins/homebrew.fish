# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

if [ -d /opt/homebrew/bin ]
  # Apple Silicon
  set PATH /opt/homebrew/bin $PATH
end
if [ -d /usr/local/bin ]
  # Intel
  set PATH /usr/local/bin $PATH
end
