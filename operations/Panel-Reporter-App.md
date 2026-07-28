# Sidewalk Stories LA - Panel Reporter (build our own)

Updated 2026-07-27. Own the tech path. Jason optional, not a blocker.

## What shipped

### Tier 0+ site form
- website/report-panel.html
  - photo upload with client-side compress
  - Use my location GPS
  - Leaflet map pin click/drag
  - reverse geocode via OpenStreetMap Nominatim
  - saves to browser localStorage
  - optional Formspree/webhook via website/js/panel-config.js
  - Google Form remains as backup link

### Tier 1 app (PWA)
- website/app/index.html - map + list
- website/app/report.html - mobile-first report flow
- website/app/admin.html - PIN-gated triage, status, CSV/JSON export
- website/app/sw.js + manifest.webmanifest - installable on phone
- Shared store: website/js/panel-store.js

## Default admin PIN
sidewalk2026
Change in website/js/panel-config.js -> adminPin

## Wire cloud email (optional)
1. Create Formspree form at https://formspree.io
2. Set formspreeEndpoint in website/js/panel-config.js
3. Redeploy site

Or set webhookUrl to Google Apps Script / Make.com / n8n JSON POST URL.

## Data model
- Primary: localStorage key ssla_panel_reports_v1
- Same origin shares site form + app
- Admin export downloads JSON/CSV
- Multi-device shared inbox needs Formspree/webhook

## Local test
cd website
python -m http.server 8080
Then open http://localhost:8080/report-panel.html and http://localhost:8080/app/

## Deploy
Push GitHub Pages as usual. Paths are relative under website/.

## Jason
Keep board seat/title. Do not block pilot on campaign stack or Adam IP.
