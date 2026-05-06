# Kurz lezení — landing page

Statická jednostránka pro propagaci horolezeckého kurzu.

## Stack

- HTML + Tailwind CSS v4 (CSS-first config)
- Vanilla JS pro modal a fade-in animace
- Bez build runtime — jen jednorázový `npm run build` na CSS

## Vývoj

```bash
npm install            # Tailwind CLI
npm run watch          # CSS rebuild on change
npm run serve          # http://localhost:8080
```

V jiném terminálu pusť `npm run watch` a v dalším `npm run serve`.

## Build pro produkci

```bash
npm run build          # vyrobí dist/output.css (minified)
```

`dist/output.css` je commitovaná, takže GitHub/GitLab Pages slouží statiku přímo.

## Fotky

Vstupní fotky patří do `img/raw/` (gitignored). Spusť:

```bash
./scripts/process-images.sh
```

Skript zmenší a sjednotí formát (WebP) do:

- `img/hero/`         — max 2400px, kvalita 82
- `img/gallery/`      — max 1600px, kvalita 80
- `img/instructors/`  — čtverec 400×400 a 800×800, kvalita 85, jméno = `<slug>.webp`

Skript je idempotentní (přeskočí už zpracované soubory). Vyžaduje `ImageMagick` (`magick`).

## Přidání instruktora

1. Hoď čtvercovou fotku do `img/raw/instructors/<slug>.jpg`
2. Spusť `./scripts/process-images.sh`
3. Přidej položku do pole v `js/instructors.js`:
   ```js
   { slug: 'jan-novak', name: 'Jan Novák', role: 'Hlavní instruktor', quote: '...', bio: '...' }
   ```

## Struktura

```
.
├── index.html
├── src/input.css         # Tailwind entry + theme + components
├── dist/output.css       # generované, commitované
├── js/instructors.js     # data + modal logic
├── img/                  # zpracované obrázky
└── scripts/
    └── process-images.sh
```

## Deploy

Stránka je hostovaná na **GitHub Pages** z větve `main` (root `/`).
Po pushnutí na `main` se deploy spustí automaticky — nic dalšího není potřeba.

Aktivace (jednorázově, už hotovo):

```bash
gh api -X POST repos/<owner>/hs/pages \
  -F 'source[branch]=main' -F 'source[path]=/'
```

## TODO před spuštěním

V `index.html` jsou zatím placeholdery — vyplnit:

- Název kurzu, datum, místo
- URL Google Docs (více info)
- URL Google Form (přihláška)
- URL Facebook, Instagram
- Kontaktní email
- Text "O kurzu"
- Data instruktorů v `js/instructors.js`
- Reálné fotky v `img/raw/`
