#!/usr/bin/env fish

# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

serverinfo

echo "   Other information:"

# Print the 'reboot required' message if it exists.
if [ -e /var/run/reboot-required ]
  echo ""
  echo (set_color red)(cat /var/run/reboot-required)(set_color normal)
end

# Show any updates that are available.
if [ -e /var/lib/update-notifier/updates-available ]
  cat /var/lib/update-notifier/updates-available
end

# Display screen sessions, if any.
if type -q screen
  screen -ls
end
