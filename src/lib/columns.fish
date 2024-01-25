# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Draws a series of key-value columns.
## These should be colorized via _add_col_color first.
function _draw_kv_columns --argument-names col_count
  set lines $argv[2..-1]
  
  # Dividing by 8 and rounding up, since we make groups of 4 in _add_col_color,
  # but we want to make sure we always have pairs of two.
  set col_lines (math "ceil("(count $lines)" / 8) * 4")
  set col_left_size "$DADA_LEFT_COL_SIZE"
  set col_right_size "$DADA_RIGHT_COL_SIZE"
  
  for n in (seq 1 4 "$col_lines")
    for offset in "0" "$col_lines"
      set k_color $lines[(math "$n + $offset + 0")]
      set k_text $lines[(math "$n + $offset + 1")]
      set v_color $lines[(math "$n + $offset + 2")]
      set v_text $lines[(math "$n + $offset + 3")]

      printf "%s%-"$DADA_LEFT_COL_SIZE"s%s%-"$DADA_RIGHT_COL_SIZE"s " "$k_color" "$k_text" "$v_color" "$v_text"
    end
    printf "\n"
  end
end

## Injects colors into a list meant for the _draw_kv_columns function.
function _add_col_color --argument-names color
  set color (set_color "$color")
  set reset (set_color normal)

  set items $argv[2..-1]
  set amount (count $items)
  
  for n in (seq 1 2 $amount)
    echo $color
    echo $items[$n]
    echo $reset
    echo $items[(math "$n + 1")]
  end
end
