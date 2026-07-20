# Sidewalk Stories LA — Domain and Google Workspace Setup

_Domain registration and Google Workspace configuration. Do this as soon as you confirm the name, even before filing Articles of Incorporation._

---

## Step 1: Domain Registration

**Recommended domains to register:**

| Domain | Priority | Cost (approx) |
|---|---|---|
| sidewalkstoriesla.org | **Primary** (nonprofit standard) | ~$12/year at Namecheap |
| sidewalkstoriesla.com | Secondary (redirect to .org) | ~$12/year at Namecheap |

**Why .org first:** Nonprofits use .org as their primary domain. The .com redirects to .org so people who type the wrong extension still land on your site.

**Registrar:** Namecheap (recommended) or Google Domains

**Steps:**
1. Go to namecheap.com
2. Search for "sidewalkstoriesla"
3. Add both .org and .com to cart
4. Enable WHOIS privacy protection (free on Namecheap)
5. Turn on auto-renew
6. Check out (~$24 total for both domains, 1 year)

---

## Step 2: Google Workspace Setup

**Plan:** Google Workspace Business Starter
**Cost:** $6 per user per month
**For Trevor now:** 1 user = $6/month (~$72/year)
**Add Jason later:** 2 users = $12/month (~$144/year)

**Email addresses to create:**

| Name | Email Address | Role |
|---|---|---|
| Trevor Damyan | trevor@sidewalkstoriesla.org | Admin |
| General info | info@sidewalkstoriesla.org | Alias to trevor@ |
| Jason Clement (later) | jason@sidewalkstoriesla.org | User |

**Steps:**

1. Go to workspace.google.com
2. Click "Get Started" or "Start Free Trial" (14-day free trial)
3. Business name: **Sidewalk Stories LA**
4. Number of employees: **1-9**
5. Region: **United States**

**Domain verification:**
1. When asked "Does your business have a domain?", select **Yes, I have one I can use**
2. Enter: **sidewalkstoriesla.org**
3. Google gives you a unique TXT verification record
4. In Namecheap: Domain List → Manage → Advanced DNS
5. Add TXT Record:
   - Type: TXT Record
   - Host: @
   - Value: [paste Google's string]
   - TTL: Automatic
6. Save. Verification takes a few minutes to a few hours.

**MX records (route email to Google):**

In Namecheap Advanced DNS, delete any existing MX records and add these five:

| Type | Host | Value | Priority |
|---|---|---|---|
| MX Record | @ | ASPMX.L.GOOGLE.COM | 1 |
| MX Record | @ | ALT1.ASPMX.L.GOOGLE.COM | 5 |
| MX Record | @ | ALT2.ASPMX.L.GOOGLE.COM | 5 |
| MX Record | @ | ALT3.ASPMX.L.GOOGLE.COM | 10 |
| MX Record | @ | ALT4.ASPMX.L.GOOGLE.COM | 10 |

Save. Email routes to Google within a few hours.

**Create user accounts:**
1. Go to admin.google.com
2. Directory → Users → Add new user
3. Trevor: trevor@sidewalkstoriesla.org (Admin role)
4. Add info@sidewalkstoriesla.org as an alias to Trevor's account
5. Download Gmail and Google Calendar apps on your phone

---

## Step 3: Domain Redirect (.com to .org)

In Namecheap:
1. Go to Domain List → Manage sidewalkstoriesla.com
2. Find "Redirect Domain" or "URL Redirect"
3. Set redirect to: https://sidewalkstoriesla.org
4. Redirect type: 301 (permanent)

This ensures anyone typing .com automatically goes to .org.

---

## Cost Summary

| Item | Cost |
|---|---|
| Domain registration (.org + .com, 1 year) | ~$24 |
| Google Workspace (1 user, 1 year) | ~$72 |
| **Total first year** | **~$96** |

---

## What you get

- Professional email: trevor@sidewalkstoriesla.org
- Google Calendar for scheduling meetings with funders and partners
- Google Drive for storing documents, photos, and the financial model
- Google Docs for collaborating on grant applications with Jason
- Google Meet for video calls with funders and Tracy/Patricia
- Gmail with built-in spam filtering and professional credibility

---

## Next steps after setup

1. Update the One-Page-Funder-Prospectus to show trevor@sidewalkstoriesla.org instead of "(coming soon)"
2. Update the email signature in the Outlook draft to Jason to show the new email
3. Create a simple landing page or redirect to a "coming soon" page
4. Set up a Google Business Profile for local search visibility
