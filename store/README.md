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
| `privacy/index.html` | Privacy policy — self-contained page, all 5 languages, brand-styled | Privacy policy URL |
| `privacy/privacy.md` | Plain-text mirror of the privacy policy | — |

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

## Publishing the privacy policy

The policy is written (`privacy/index.html`, all 5 languages). Two steps remain:

1. **Set a real contact.** In `privacy/index.html` (and `privacy.md`) replace
   `privacy@papyra.app` and the provider name with a real, monitored address.
2. **Host it and copy the URL.** Any static host works. Quickest: enable GitHub
   Pages on this repo and link `…/store/privacy/` — or drag the file onto
   Netlify Drop, Cloudflare Pages, etc. Paste the resulting URL into the Play
   Console “Privacy policy” field.

## Still to provide in the Play Console (not in this repo)

- **Data safety form** — declare *no data collected / no data shared*; note the
  app has **no INTERNET permission**.
- Content rating questionnaire, target audience, category, contact email.
