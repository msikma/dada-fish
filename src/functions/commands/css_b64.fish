# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function css_b64 --description "Converts image to base64 data uri"
  # If invoked via "css_b64 -- filename", do not add the url('..') wrapper.
  if [ "$argv[1]" = '--' ]
    set no_wrapper 1
    set fn "$argv[2]"
  else
    set fn "$argv[1]"
  end
  if [ -z "$fn" ]
    echo "css_b64: usage: css_b64 FILENAME"
    return 1
  end
  if [ ! -f "$fn" ]
    echo "css_b64: error: file \"$fn\" does not exist"
    return 1
  end

  # Retrieves the mime type, e.g. 'image/png'
  set mime (file -bN --mime-type "$fn")

  # Converts the file itself to Base64
  set content (base64 -b 0 < "$fn")

  if [ "$no_wrapper" = 1 ]
    printf "data:%s;base64,%s\n" $mime $content
  else
    printf "url('data:%s;base64,%s')\n" $mime $content
  end
end

_register_command media "css_b64" "fn"
