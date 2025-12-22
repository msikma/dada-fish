# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

# If a string can't be sanitized to a proper filename, use this fallback value instead.
set -g _SANITIZE_FALLBACK "(empty)"

# Python program for sanitizing strings. We do this in Python for flexibility.
# This is the strict version that removes everything outside the BMP.
set -g sanitize_strict_python_src '
import re
import unicodedata

def sanitize_string(string):
  if not string:
    return ""

  sub_pattern = re.compile(
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
  string = unicodedata.normalize("NFC", string)
  string = sub_pattern.sub("", string)
  string = re.sub(r"[/\\:*?\"<>|]", "_", string)
  string = re.sub(r"_+", "_", string)
  string = re.sub(r"\s+", " ", string)
  string = string.strip(" .")
  
  reserved_names = {
    "con", "prn", "aux", "nul",
    *(f"com{i}" for i in range(1, 10)),
    *(f"lpt{i}" for i in range(1, 10)),
  }
  
  if string.lower() in reserved_names:
    return ""
  
  return string

if __name__ == "__main__":
  import sys
  input_string = sys.argv[1]
  print(sanitize_string(input_string))
'

# Python program that sanitizes strings but only removes emoji and other problematic characters.
set -g sanitize_regular_python_src '
import re
import unicodedata

sub_pattern = re.compile(
  "["
  "\U0001F600-\U0001F64F"            # emoticons
  "\U0001F300-\U0001F5FF"            # symbols & pictographs
  "\U0001F680-\U0001F6FF"            # transport & map symbols
  "\U0001F900-\U0001F9FF"            # Supplemental Symbols & Pictographs
  "\U0001FA70-\U0001FAFF"            # Symbols & Pictographs Extended-A
  "\u2600-\u26FF"                    # Misc symbols (weather, etc.)
  "\u2700-\u27BF"                    # Dingbats
  "]+",
  flags=re.UNICODE
)

def sanitize_string(string):
  if not string:
    return ""

  string = unicodedata.normalize("NFC", string)
  string = sub_pattern.sub("", string)
  string = re.sub(r"[/\\:*?\"<>|]", "_", string)
  string = re.sub(r"_+", "_", string)
  string = re.sub(r"\s+", " ", string)
  string = string.strip(" .")

  reserved_names = {
    "con", "prn", "aux", "nul",
    *(f"com{i}" for i in range(1, 10)),
    *(f"lpt{i}" for i in range(1, 10)),
  }
  
  if string.lower() in reserved_names:
    return ""

  return string

if __name__ == "__main__":
  import sys
  input_string = sys.argv[1]
  print(sanitize_string(input_string))
'

# Python program that limits a string's length, Unicode compliant.
set -g sanitize_length_python_src '
import unicodedata

def sanitize_string(string, max_length):
  if not string:
    return ""

  string = unicodedata.normalize("NFC", string)
  return string[:max_length]

if __name__ == "__main__":
  import sys
  input_string = sys.argv[1]
  max_length = int(sys.argv[2])
  print(sanitize_string(input_string, max_length))
'

## Replaces non-filename characters with underscores.
function _sanitize_filename_part --argument-names string
  echo "$string" | string replace -ra '[/\\:*?"<>|]' '_' | string replace -ra '_+' '_' | string replace -ra '\s+' ' ' | string trim -c ' .'
end

## Replaces characters outside of the BMP and reserved filesystem characters.
function _sanitize_string_strict --argument-names string
  set sanitized (echo "$sanitize_strict_python_src" | python3 - "$string")
  if [ -n "$sanitized" ]
    echo "$sanitized"
  else
    echo "$_SANITIZE_FALLBACK"
  end
end

## Replaces various characters (emoji, pictograms, etc.) and reserved filesystem characters.
function _sanitize_string --argument-names string max_length
  if test -z "$max_length"
    set max_length 50
  end
  set sanitized (echo "$sanitize_regular_python_src" | python3 - "$string")
  if [ -n "$sanitized" ]
    set sanitized (echo "$sanitize_length_python_src" | python3 - "$sanitized" "$max_length")
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
