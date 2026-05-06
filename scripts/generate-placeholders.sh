#!/usr/bin/env bash
# Vygeneruje placeholder portréty pro instruktory dokud nedodáme reálné fotky.
# Vytvoří img/instructors/instruktor-NN.webp (a @2x), 20 ks.
# Spusť jen jednou; po nahrazení reálnými fotkami už není potřeba.

set -euo pipefail

if ! command -v magick >/dev/null 2>&1; then
  echo "error: ImageMagick (magick) is not installed" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Paleta tlumených barev v duchu light & minimal
colors=( "#d4c9b8" "#c8b8a3" "#b9a890" "#a89886" "#9e8e7d" "#8a7d6e" "#cfc6b6" "#bfb09a" "#aa9b86" "#988977" "#c2b29a" "#b3a48c" "#a59682" "#988a78" "#8c7e6c" "#d8cdbb" "#c5b6a0" "#b3a48c" "#a3947d" "#94866f" )

for i in $(seq -f "%02g" 1 20); do
  idx=$((10#$i - 1))
  color="${colors[$idx]}"
  for size in 400 800; do
    pt=$((size / 4))
    suffix=""
    [[ $size == 800 ]] && suffix="@2x"
    out="img/instructors/instruktor-${i}${suffix}.webp"
    [[ -f "$out" ]] && continue
    magick -size ${size}x${size} canvas:"${color}" \
      -fill "rgba(255,255,255,0.85)" -gravity center \
      -pointsize $pt -font sans -annotate +0+0 "$i" \
      -strip -quality 85 "$out"
    echo "ph    -> $out"
  done
done

echo "Hotovo."
