# Sidewalk Stories LA: Website SEO and Accessibility Audit

_Audit of the website/ folder based on file review. Prioritized, actionable findings. Does not include live performance testing; items marked as manual checks to perform after launch._

---

## Executive summary

The Sidewalk Stories LA website is a well-structured, responsive static site with strong branding and clear messaging. Most SEO fundamentals are in place: unique titles, meta descriptions, Open Graph tags, and a sitemap. The main gaps are in technical accessibility (keyboard navigation, focus management, ARIA), schema markup, form accessibility, and some internal link consistency. None of these are launch blockers, but the high-priority items should be addressed before major grant submissions or press outreach.

---

## Priority 1: Fix before public launch / grant season

### 1.1 Heading structure: multiple H1s and skipped levels
- **Issue:** Several pages use more than one `<h1>`. For example:
  - `index.html`: hero title is `<h1>`, but sections also use `<h2>` appropriately.
  - `program.html`: four step sections each use `<h2>` after a page-level `<h1>`; the step number headings are styled as large text but are not semantic headings. This is acceptable, but consider whether each step should be an `<h2>` with the step number as a visual element.
  - `contact.html`: the donation card uses `<h2>Choose Your Impact</h2>` inside a section that also has an `<h2>Support the Pilot</h2>`; this creates a valid but slightly confusing outline.
- **Impact:** Screen reader users rely on heading hierarchy to navigate. Multiple top-level headings and inconsistent section labels can make page structure harder to parse.
- **Action:** Ensure exactly one `<h1>` per page. Use `<h2>` for major sections and `<h3>` for subsections. Make decorative step numbers non-semantic spans.

### 1.2 Mobile navigation toggle is not keyboard or screen-reader friendly
- **Issue:** The `.nav-toggle` button has `aria-label="Toggle navigation"` but no `aria-expanded` attribute, no `aria-controls` pointing to the menu, and no visible focus style verification in the CSS.
- **Impact:** Keyboard and screen-reader users may not know whether the menu is open or closed, and may not be able to operate it.
- **Action:** Add `aria-expanded="false"` (toggled by JS), `aria-controls="nav-menu"` with a matching ID, and ensure the button is focusable with a visible focus indicator.

### 1.3 Form inputs lack associated labels / accessible error handling
- **Issue:**
  - Contact form on `contact.html` has explicit `<label for="name">` etc. This is good.
  - Newsletter email input in the CTA section uses an inline placeholder but no visible `<label>` or `aria-label`.
  - Donation buttons are `<button>` elements with nested `<br>` and `<span>`; they are not grouped as a fieldset and have no programmatic grouping.
  - All forms use `action="#"` with no backend or form validation messaging.
- **Impact:** Placeholder-only inputs fail WCAG 3.3.2 (Labels or Instructions). Missing error handling makes it impossible for assistive tech users to know if a submission succeeded.
- **Action:** Add visible labels or `aria-label` to every input. Wrap donation amount buttons in a `<fieldset>` with `<legend>`. Implement real form handling and provide clear error/success messages.

### 1.4 Social media links in footer use `#` hrefs
- **Issue:** Footer social links, Instagram/Facebook/Google links, and several "coming soon" links point to `#`.
- **Impact:** These appear as broken or meaningless links to screen readers and search crawlers. They may be counted as internal broken links.
- **Action:** Either create the social profiles and update the URLs, or remove the links until profiles exist. If kept as placeholders, add `aria-disabled="true"` and remove the `href` attribute.

### 1.5 Missing focus indicators on custom CSS
- **Issue:** The site uses custom buttons, links, and form controls. Without live CSS inspection, it is unclear whether focus outlines are preserved or suppressed.
- **Impact:** Keyboard users may lose track of focus position.
- **Action:** Add `:focus-visible` styles to all interactive elements (links, buttons, form controls) with a high-contrast outline.

---

## Priority 2: Important for SEO and credibility

### 2.1 Schema.org structured data is missing
- **Issue:** No JSON-LD schema is present for:
  - Organization (nonprofit name, email, URL, logo, address)
  - LocalBusiness / Place
  - WebSite (search action)
  - FAQPage (the FAQ page has excellent content for FAQ schema)
  - Article/Event for stories/updates
- **Impact:** Google may not produce rich results for the organization, FAQ, or events. This reduces visibility in search.
- **Action:** Add JSON-LD to every page. Start with Organization schema on all pages and FAQPage schema on `faq.html`.

### 2.2 Canonical links are missing
- **Issue:** No `<link rel="canonical">` tags on any page.
- **Impact:** Search engines may index duplicate versions of pages (e.g., with/without `.html`, with query parameters from social traffic).
- **Action:** Add canonical URLs to every page head, matching the `og:url` value.

### 2.3 Sitemap is incomplete
- **Issue:** `sitemap.xml` only lists index, about, program, and contact pages. It omits `faq.html`, `volunteer.html`, `stories.html`, `press-kit.html`, `photo-credits.html`, and `404.html`.
- **Impact:** Newer pages may not be discovered or indexed as quickly.
- **Action:** Update `sitemap.xml` to include all public HTML pages except `404.html`.

### 2.4 robots.txt is correct but minimal
- **Issue:** `robots.txt` allows all and references the sitemap. This is fine.
- **Action:** No change needed unless a staging or draft folder is added; then disallow that folder.

### 2.5 Twitter Card meta tags are incomplete
- **Issue:** Most pages have `twitter:card` but not `twitter:image`. Only the home page has full Twitter description.
- **Impact:** Twitter sharing may not show the intended preview image.
- **Action:** Add `twitter:image`, `twitter:title`, and `twitter:description` to every page to match Open Graph data.

### 2.6 Page title length and keyword optimization
- **Current titles are good but could be stronger:**
  - `Get Involved | Sidewalk Stories LA`: clear
  - `About Us | Sidewalk Stories LA`: clear
  - `Our Program | Sidewalk Stories LA`: consider `Youth Mosaic Pilot Program | Sidewalk Stories LA`
  - `FAQ | Sidewalk Stories LA`: consider `FAQ: Sidewalk Mosaics, Donations, Volunteering | Sidewalk Stories LA`
- **Action:** Keep titles under 60 characters while including primary keywords like "sidewalk mosaic," "youth public art," or "Los Angeles nonprofit" where natural.

---

## Priority 3: Accessibility and usability improvements

### 3.1 Alt text is generally good but could be more descriptive
- **Strengths:** Most images have alt text, e.g., "Cracked and damaged sidewalk panel in Los Angeles" and "Children working on mosaic and craft projects with a teaching artist."
- **Gaps:**
  - Decorative mosaic tile backgrounds in the hero do not have `role="img"` or alt attributes. If purely decorative, they should have `alt=""` and `role="presentation"` or be implemented as CSS backgrounds.
  - Team/artist placeholder images could describe the role rather than the generic "Teaching Artist" alt text.
- **Action:** Mark decorative SVG/background images as decorative. Make functional images (before/after slider, gallery) have meaningful alt text.

### 3.2 Before/after slider is not accessible
- **Issue:** The `.before-after-slider` uses divs with background images and a `.slider-handle`. There is no keyboard control, no ARIA role, no label, and no alternative text describing the two states.
- **Impact:** Screen-reader and keyboard users cannot interact with or understand the comparison.
- **Action:** Add `role="slider"`, `aria-valuemin="0"`, `aria-valuemax="100"`, `aria-valuenow="50"`, `aria-label="Before and after comparison"`, and keyboard event handlers for left/right arrows.

### 3.3 FAQ accordion needs ARIA roles
- **Issue:** `faq.html` uses clickable `<div class="faq-question">` elements. They are not buttons and have no `aria-expanded`, `aria-controls`, or keyboard handlers.
- **Impact:** Screen-reader and keyboard users cannot expand/collapse answers.
- **Action:** Convert each question to a `<button>` with `aria-expanded` and `aria-controls` pointing to the answer panel. Ensure answers are hidden with `display:none` or `visibility:hidden` when collapsed.

### 3.4 Donation buttons do not indicate selection state
- **Issue:** The donation amount buttons on `contact.html` are plain buttons with no `aria-pressed` or radio-group semantics.
- **Impact:** Users cannot tell which amount is selected.
- **Action:** Convert to a radio button group styled as buttons, or add `aria-pressed` and update via JavaScript.

### 3.5 Newsletter input lacks a label
- **Issue:** The newsletter email input on `contact.html` and `stories.html` uses a placeholder only.
- **Action:** Add a visible `<label>` or `aria-label="Email address for newsletter"`.

---

## Priority 4: Performance and technical checks

### 4.1 Image optimization
- **Issue:** Image file names suggest they are full-resolution stock photos (e.g., `og-image.jpg`, `trevor-damyan.jpg`). Without file sizes, it is unclear whether images are optimized.
- **Impact:** Large hero images can slow first paint, especially on mobile.
- **Action:** Compress all images to WebP where possible, provide responsive `srcset` for gallery and hero images, and lazy-load below-the-fold images.

### 4.2 Google Fonts loading
- **Issue:** The site loads two Google Fonts families with `display=swap`. This is good practice.
- **Action:** Consider self-hosting fonts if privacy or performance becomes a concern.

### 4.3 CSS and JS delivery
- **Issue:** One CSS file and one JS file are loaded per page. This is reasonable for a small static site.
- **Action:** Verify CSS is minified and that unused styles are removed. Add `defer` to the JS script tag if it does not need to block rendering.

### 4.4 Missing 301 redirects and trailing slash handling
- **Issue:** GitHub Pages may serve `index.html` for `/`, but direct links to `/about` or `/program` without `.html` could 404 depending on server configuration.
- **Action:** Confirm GitHub Pages handles extensionless URLs or standardize all internal links to include `.html`. Add canonical tags to reduce confusion.

---

## Priority 5: Content and link issues

### 5.1 Inconsistent navigation between pages
- **Issue:** Some pages include "Volunteer" in the main nav; `stories.html` and `press-kit.html` omit it. The 404 page has a different nav set.
- **Impact:** Users may feel navigation is inconsistent.
- **Action:** Standardize the main navigation across all pages, including 404.

### 5.2 Press kit download links are non-functional placeholders
- **Issue:** `press-kit.html` download buttons use `onclick="alert('coming soon...')"` and `#` hrefs.
- **Impact:** This is acceptable pre-launch but should be replaced with real assets as soon as the logo pack and fact sheet are ready.
- **Action:** Create logo pack PNG/SVG and fact sheet PDF, then update links.

### 5.3 Stories page shows "0 of 10 panels complete"
- **Issue:** This is accurate pre-launch but will need to be updated as panels progress.
- **Action:** Plan a content update workflow for the stories page after each panel completion.

### 5.4 Photo credits page
- **Issue:** `photo-credits.html` exists but was not audited in detail.
- **Action:** Ensure all stock photography is properly credited and licensed for public use.

---

## Recommended action plan

| Priority | Task | Owner | Timeline |
|---|---|---|---|
| 1 | Fix mobile nav ARIA and focus management | Web dev | Before launch |
| 1 | Add visible labels / aria-labels to all forms | Web dev | Before launch |
| 1 | Replace `#` social links or mark them disabled | Web dev / Trevor | Before launch |
| 1 | Verify and improve focus indicators | Web dev | Before launch |
| 2 | Add JSON-LD Organization and FAQPage schema | Web dev | Before grant submissions |
| 2 | Add canonical links to all pages | Web dev | Before launch |
| 2 | Update sitemap.xml with all public pages | Web dev | Before launch |
| 2 | Complete Twitter Card meta tags | Web dev | Before launch |
| 3 | Make before/after slider keyboard/screen-reader accessible | Web dev | Post-launch |
| 3 | Refactor FAQ accordion to use buttons and ARIA | Web dev | Post-launch |
| 4 | Optimize images and add lazy loading | Web dev | Post-launch |
| 4 | Confirm GitHub Pages URL handling and canonicals | Web dev | Before launch |
| 5 | Standardize navigation across all pages | Web dev | Before launch |
| 5 | Prepare real press kit assets | Trevor / design | Month 1 |

---

## Quick wins checklist

- [ ] Add `aria-expanded`, `aria-controls`, and focus styles to `.nav-toggle`
- [ ] Add labels to newsletter inputs
- [ ] Add JSON-LD Organization schema to every page
- [ ] Add JSON-LD FAQPage schema to `faq.html`
- [ ] Add canonical links to every page
- [ ] Update `sitemap.xml` with all public pages
- [ ] Replace placeholder social links or add `aria-disabled`
- [ ] Add `twitter:image` to every page
- [ ] Verify all donation buttons have selection state
- [ ] Standardize navigation across all HTML files
