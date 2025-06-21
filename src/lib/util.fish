# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

# If a string can't be sanitized to a proper filename, use this fallback value instead.
set -g _SANITIZE_FALLBACK "(empty)"

# Python program for sanitizing strings. We do this in Python since it can easily filter out emoji.
set -g sanitize_python_src '
import re

def sanitize_string(string):
  if not string:
    return ""

  emoji_pattern = re.compile(
    "["
    "\U0001F600-\U0001F64F"  # emoticons
    "\U0001F300-\U0001F5FF"  # symbols & pictographs
    "\U0001F680-\U0001F6FF"  # transport & map symbols
    "\U0001F700-\U0001F77F"  # alchemical symbols
    "\U0001F780-\U0001F7FF"  # Geometric Shapes Extended
    "\U0001F800-\U0001F8FF"  # Supplemental Arrows-C
    "\U0001F900-\U0001F9FF"  # Supplemental Symbols and Pictographs
    "\U0001FA00-\U0001FA6F"  # Chess Symbols
    "\U0001FA70-\U0001FAFF"  # Symbols and Pictographs Extended-A
    "\U00002702-\U000027B0"  # Dingbats
    "\U000024C2-\U0001F251" 
    "]+",
    flags=re.UNICODE
  )
  string = emoji_pattern.sub("", string)
  string = re.sub(r"[/\\:*?\"<>|]", "_", string)
  string = re.sub(r"_+", "_", string)
  string = re.sub(r"\s+", " ", string)
  string = string.strip(" .")
  
  reserved_names = {
    "com1", "com2", "com3", "com4", "com5", "com6", "com7", "com8", "com9",
    "lpt1", "lpt2", "lpt3", "lpt4", "lpt5", "lpt6", "lpt7", "lpt8", "lpt9",
    "con", "nul", "prn"
  }
  
  if string.lower() in reserved_names:
    return ""
  
  return string

if __name__ == "__main__":
  import sys
  input_string = sys.argv[1]
  print(sanitize_string(input_string))
'

## Replaces non-filename characters with underscores.
function _sanitize_filename_part --argument-names string
  echo "$string" | string replace -ra '[/\\:*?"<>|]' '_' | string replace -ra '_+' '_' | string replace -ra '\s+' ' ' | string trim -c ' .'
end

## Replaces various characters (emoji, pictograms, etc.) and reserved filesystem characters.
function _sanitize_string --argument-names string
  set sanitized (echo "$sanitize_python_src" | python3 - "$string")
  if [ -n "$sanitized" ]
    echo "$sanitized"
  else
    echo "$_SANITIZE_FALLBACK"
  end
end

## Sanitizes a filename.
function _sanitize_filename --argument-names string
  set parts (string split "." "$string")
  if test (count $parts) -eq 1
    _sanitize_string "$string"
  else
    set name (string join "." $parts[1..-2])
    set ext "$parts[-1]"
    echo (_sanitize_string "$name").(_sanitize_string "$ext")
  end
end
