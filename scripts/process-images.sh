#!/usr/bin/env bash
# Zpracování fotek: zmenšení a sjednocení velikosti, výstup ve WebP.
#
# Vstup:
#   img/raw/hero/*.{jpg,jpeg,png,heic}        -> img/hero/<name>.webp           (max 2400w)
#   img/raw/gallery/*.{jpg,jpeg,png,heic}     -> img/gallery/<name>.webp        (max 1600w)
#   img/raw/instructors/<slug>.{jpg,...}      -> img/instructors/<slug>.webp    (čtverec 400)
#                                              + img/instructors/<slug>@2x.webp (čtverec 800)
#
# Idempotentní: přeskočí soubory, jejichž výstup už existuje a je novější než vstup.
# Vyžaduje: ImageMagick 7+ (příkaz `magick`).

set -euo pipefail

if ! command -v magick >/dev/null 2>&1; then
  echo "error: ImageMagick (magick) is not installed" >&2
  echo "  hint: 'sudo apt install imagemagick' nebo 'brew install imagemagick'" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

needs_rebuild() {
  local src="$1" dst="$2"
  [[ ! -f "$dst" ]] && return 0
  [[ "$src" -nt "$dst" ]] && return 0
  return 1
}

count=0; skipped=0

# ---- Hero ----
shopt -s nullglob nocaseglob
for src in img/raw/hero/*.{jpg,jpeg,png,heic,webp}; do
  base="$(basename "$src")"
  name="${base%.*}"
  dst="img/hero/${name}.webp"
  if needs_rebuild "$src" "$dst"; then
    echo "hero  -> $dst"
    magick "$src" -auto-orient -resize '2400x>' -strip -quality 82 "$dst"
    count=$((count+1))
  else
    skipped=$((skipped+1))
  fi
done

# ---- Hero list (for random selection on page load) ----
# Pulls from both img/hero/ and img/gallery/ so all available photos
# can rotate as the hero background. Loaded synchronously in <head>
# so the random pick happens before the browser starts loading the
# hero <img>, avoiding a flash of the wrong image.
manifest="js/hero-list.js"
{
  printf 'window.HERO_IMAGES = ['
  first=1
  for f in img/hero/*.webp img/gallery/*.webp; do
    [[ -f "$f" ]] || continue
    if [[ $first -eq 1 ]]; then
      printf '\n  "%s"' "$f"
      first=0
    else
      printf ',\n  "%s"' "$f"
    fi
  done
  printf '\n];\n'
} > "$manifest"
echo "hero  -> $manifest"

# ---- Gallery ----
for src in img/raw/gallery/*.{jpg,jpeg,png,heic,webp}; do
  base="$(basename "$src")"
  name="${base%.*}"
  dst="img/gallery/${name}.webp"
  if needs_rebuild "$src" "$dst"; then
    echo "gal   -> $dst"
    magick "$src" -auto-orient -resize '1600x>' -strip -quality 80 "$dst"
    count=$((count+1))
  else
    skipped=$((skipped+1))
  fi
done

# ---- Instructors (square crop) ----
for src in img/raw/instructors/*.{jpg,jpeg,png,heic,webp}; do
  base="$(basename "$src")"
  name="${base%.*}"
  dst1="img/instructors/${name}.webp"
  dst2="img/instructors/${name}@2x.webp"

  if needs_rebuild "$src" "$dst1"; then
    echo "instr -> $dst1"
    magick "$src" -auto-orient -resize '400x400^' -gravity center -extent 400x400 -strip -quality 85 "$dst1"
    count=$((count+1))
  else
    skipped=$((skipped+1))
  fi
  if needs_rebuild "$src" "$dst2"; then
    echo "instr -> $dst2"
    magick "$src" -auto-orient -resize '800x800^' -gravity center -extent 800x800 -strip -quality 85 "$dst2"
    count=$((count+1))
  else
    skipped=$((skipped+1))
  fi
done

shopt -u nullglob nocaseglob
echo
echo "Hotovo. zpracováno=${count} přeskočeno=${skipped}"
