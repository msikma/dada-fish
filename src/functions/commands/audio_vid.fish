# dada-fish <https://github.com/msikma/dada-fish>
# © MIT license

function audio_vid --description "Converts audio+image to video"
  ! _require_cmd "ffmpeg"; and return 1

  if [ (count $argv) -lt 2 ]
    echo "error: missing arguments. usage: audio_vid AUDIO_FILE IMAGE_FILE"
    return 1
  end

  set audio "$argv[1]"
  set image "$argv[2]"
  set basename (_file_base "$audio")
  set video "$basename"".mp4"
  
  ffmpeg -y -loop 1 -framerate 1 -i "$image" -i "$audio" -r 30 -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" -c:v libx264 -tune stillimage -crf 3 -preset superfast -c:a aac -b:a 192k -shortest "$video"
end

_register_command media "audio_vid" "au im"
_register_dependency "brew" "ffmpeg" "ffmpeg"
