# Store assets — Papyra

Everything for the Google Play listing. All graphics are generated locally from
HTML with headless Chrome; nothing here is a paid/stock asset.

## Contents

| File | What | Play requirement |
|------|------|------------------|
| `play-listing.md` | Title / short / full description in de, en, fr, it, tr + screenshot captions | — |
| `assets/play-icon-512.png` | App icon, 512×512 | Store icon (exact 512×512, PNG) |
| `assets/feature.png` | Feature graphic, 1024×500 | Feature graphic (exact 1024×500) |
| `assets/shot1.png` … `shot5.png` | Phone screenshots, 1080×2160 | 2–8 phone screenshots, 16:9…9:16 |
| `assets/*.html`, `_base.css`, `render.ps1` | Sources to regenerate/localize the graphics | — |

Screenshots, in order: **1** Library · **2** Scan & auto-classify · **3** Search ·
**4** Due dates · **5** Privacy/offline.

## Regenerate / localize the graphics

The PNGs are rendered from the HTML sources. To change captions (e.g. for the
French listing) edit the `.cap` text in `shot1..shot5.html`, then:

```powershell
pwsh store/assets/render.ps1
```

Localized caption strings for all five languages are at the bottom of
`play-listing.md`.

## Still to provide in the Play Console (not in this repo)

- **Privacy policy URL** — host the (already translated) in-app privacy text
  publicly and link it. Required even though the app is fully offline.
- **Data safety form** — declare *no data collected / no data shared*; note the
  app has **no INTERNET permission**.
- Content rating questionnaire, target audience, category, contact email.
