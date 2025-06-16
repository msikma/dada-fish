# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

## Draws a table, given a col_count value (n), followed by:
##   - n width values,
##   - n color values, and finally
##   - n * m values for m rows.
## Columns are truncated with ellipsis if they exceed their column width,
## and widths are determined by a value's visual width (taking escape sequences into account).
function _draw_table
  set -l col_count $argv[1]
  set -l rest $argv[2..-1]

  # Column widths and colors.
  set -l widths $rest[1..$col_count]
  set -l colors $rest[(math "$col_count + 1")..(math "$col_count * 2")]

  # Everything else is row data.
  set -l data $rest[(math "$col_count * 2 + 1")..-1]
  set -l total_rows (math "("(count $data)")" / $col_count)

  for row_index in (seq 0 (math "$total_rows - 1"))
    for col_index in (seq 1 $col_count)
      set -l global_index (math "$row_index * $col_count + $col_index")

      set -l value $data[$global_index]
      set -l color $colors[$col_index]
      set -l width $widths[$col_index]

      set -l value_length (string length -- $value)
      set -l value_width (string length --visible -- $value)
      set -l value_overhead (math "$value_length - $value_width")

      if test $value_width -gt $width
        set -l cut_length (math "$width - 1 + $value_overhead")
        set -l trimmed (string sub -l $cut_length -- "$value")
        set value "$trimmed…"
      else
        set -l padding (string repeat -n (math "$width - $value_width") -- " ")
        set value "$value$padding"
      end

      printf "$color""%s" "$value"(set_color normal)
    end
    echo
  end
end

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
