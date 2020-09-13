#!/bin/bash

readonly lilypond_folder="/lilypond/lilypond/usr/share/lilypond/current"
readonly otf_folder="${lilypond_folder}/fonts/otf"
readonly svg_folder="${lilypond_folder}/fonts/svg"
readonly ly_folder="${lilypond_folder}/ly"

# LilyJAZZ
# See https://github.com/OpenLilyPondFonts/lilyjazz/blob/master/LilyPond-Fonts-Installation-And-Usage.txt
readonly lilyjazz_repo="https://github.com/OpenLilyPondFonts/lilyjazz"

for size in 11 13 14 16 18 20 23 26 brace; do
    wget "${lilyjazz_repo}/raw/master/otf/lilyjazz-${size}.otf" -P "${otf_folder}/"
    wget "${lilyjazz_repo}/raw/master/svg/lilyjazz-${size}.svg" -P "${svg_folder}/"
    wget "${lilyjazz_repo}/raw/master/svg/lilyjazz-${size}.woff" -P "${svg_folder}/"
done

wget "${lilyjazz_repo}/raw/master/supplementary-files/lilyjazz-chord/lilyjazz-chord.otf" -P "${otf_folder}/"
wget "${lilyjazz_repo}/raw/master/supplementary-files/lilyjazz-text/lilyjazz-text.otf" -P "${otf_folder}/"

for stylesheet in jazzchords jazzextras lilyjazz; do
    wget "${lilyjazz_repo}/raw/master/stylesheet/${stylesheet}.ily" -P "${ly_folder}/"
done
