# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function flipcoin --description "Flips a coin (heads or tails)"
  set value (shuf -i 0-1 -n 1)
  if [ "$value" -eq 0 ]
    echo "🌚 tails"
  else
    echo "🌞 heads"
  end
end

_register_command script "flipcoin"
