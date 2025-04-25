#!/usr/bin/env fish

set -g USAGE 'usage: interpolate_series PATH'
set -g RIFE_MODEL "rife-models/rife-v4.6"

function get_outpath --argument-names inpath
  set inpath_parent (dirname "$inpath")
  set inpath_base (basename "$inpath")
  echo "$inpath_parent"/"$inpath_base"_interpolated
end

function extract_rgb_data --argument-names infile outfile basedir
  magick "$infile" \
    -alpha off -alpha on \
    -channel A -evaluate set 100% +channel \
    "$basedir"/"$outfile"
end

function extract_mask_data --argument-names infile outfile basedir
  magick "$infile" \
    -alpha extract \
    "$basedir"/"$outfile"
end

function extract_rgb --argument-names infile basedir
  set basename (path basename --no-extension "$infile")
  set rgb "$basename"_rgb.png
  extract_rgb_data "$infile" "$rgb" "$basedir"
  echo "$rgb"
end

function extract_alpha --argument-names infile basedir
  set basename (path basename --no-extension "$infile")
  set alpha "$basename"_alpha.png
  extract_mask_data "$infile" "$alpha" "$basedir"
  echo "$alpha"
end

function interpolate_files --argument-names type a_file b_file basedir
  set ab_file ab_"$type".png
  rife -m "$RIFE_MODEL" -0 "$basedir/$a_file" -1 "$basedir/$b_file" -xzu -o "$basedir/$ab_file" 2> /dev/null
  echo "$ab_file"
end

function merge_files --argument-names ab_rgb ab_alpha basedir
  set composite "ab_composite.png"
  magick "$basedir/$ab_rgb" "$basedir/$ab_alpha" \
    -compose CopyOpacity \
    -composite \
    "$basedir/$composite"
  echo "$composite"
end

function interpolate_image_pair --argument-names a_file b_file basedir
  set a_rgb (extract_rgb "$a_file" "$basedir")
  set a_alpha (extract_alpha "$a_file" "$basedir")
  
  set b_rgb (extract_rgb "$b_file" "$basedir")
  set b_alpha (extract_alpha "$b_file" "$basedir")
  
  set ab_rgb (interpolate_files "rgb" "$a_rgb" "$b_rgb" "$basedir")
  set ab_alpha (interpolate_files "alpha" "$a_alpha" "$b_alpha" "$basedir")
  set ab_composite (merge_files "$ab_rgb" "$ab_alpha" "$basedir")
  
  rm "$basedir/$a_rgb"
  rm "$basedir/$a_alpha"
  rm "$basedir/$b_rgb"
  rm "$basedir/$b_alpha"
  rm "$basedir/$ab_rgb"
  rm "$basedir/$ab_alpha"
  
  echo "$ab_composite"
end

function interpolate_series --argument-names inpath
  ! _require_cmd "rife"; and return 1
  if [ -z "$inpath" -o ! -d "$inpath" ]
    echo "$USAGE"
    return 1
  end
  set basedir (mktemp -d)
  set outpath (get_outpath "$inpath")

  set images (find "$inpath" -type f -mindepth 1 -maxdepth 1 -iname "*.png" | sort)
  set -a images "$images[1]"
  for n in (seq (math (count $images)" - 1"))
    set n_a "$n"
    set n_b (math "$n + 1")
    set idx_a (printf "%06d" (math "( $n - 1 ) * 2"))
    set idx_ab (printf "%06d" (math "$idx_a + 1"))
    set image_a "$images[$n_a]"
    set image_b "$images[$n_b]"
    set image_ab "$basedir/"(interpolate_image_pair "$image_a" "$image_b" "$basedir")

    cp "$image_a" "$basedir/$idx_a.png"
    cp "$image_ab" "$basedir/$idx_ab.png"
    rm "$image_ab"
  end
  mv "$basedir" "$outpath"
end

interpolate_series $argv

#_dada_fish _register_bin media "interpolate_series" "path" "interpolate_series.fish" "Interpolates images in a series"
