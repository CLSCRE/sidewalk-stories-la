# Formspree Setup Instructions for Sidewalk Stories LA

## What Formspree Gives You

Formspree is a free form backend. It collects submissions from your website and emails them to you. No server code required.

Free plan includes:
- 50 submissions per month
- File uploads up to 1 MB
- Email notifications
- No credit card required

## Step 1: Create Your Account

1. Go to https://formspree.io/register
2. Sign up with **trevor@sidewalkstoriesla.org**
3. Verify your email address

## Step 2: Create One Form

1. In the Formspree dashboard, click **New Form**
2. Name it: `Sidewalk Stories LA Website`
3. Formspree will give you an endpoint like:
   ```
   https://formspree.io/f/xnqkevzy
   ```

## Step 3: Replace the Placeholder in the Website

Find every file that contains `YOUR_FORM_ID` and replace it with your real Formspree ID.

Files to update:
- `website/contact.html` (2 forms: contact + newsletter)
- `website/volunteer.html` (1 volunteer form)
- `website/stories.html` (1 newsletter form)
- `website/report-panel.html` (1 panel report form)

Example replacement:
```
https://formspree.io/f/YOUR_FORM_ID
```
becomes:
```
https://formspree.io/f/xnqkevzy
```

Use the same Formspree endpoint for all forms. The hidden `form-type` field tells you which form was submitted.

## Step 4: Test Submissions

1. Submit the contact form on https://sidewalkstoriesla.org/contact.html
2. Check trevor@sidewalkstoriesla.org for the notification
3. Verify the subject line and form-type field are correct

## Step 5: Optional Upgrades

- Add a custom **thank-you page** redirect with:
  ```html
  <input type="hidden" name="_next" value="https://sidewalkstoriesla.org/thank-you.html">
  ```
- Add CAPTCHA protection (enabled by default on free plan)
- Upgrade to paid plan if you exceed 50 submissions/month

## Current Form Subjects

| Form | Subject Line | Hidden form-type |
|------|--------------|------------------|
| Contact | New contact form message - Sidewalk Stories LA | contact |
| Newsletter | New newsletter subscriber - Sidewalk Stories LA | newsletter |
| Volunteer | New volunteer application - Sidewalk Stories LA | volunteer |
| Panel Report | New cracked panel report - Sidewalk Stories LA | panel-report |

## Note on File Uploads

The panel report form allows photo uploads. Formspree free plan supports files. Make sure your form tag includes:
```html
enctype="multipart/form-data"
```
This is already set in `report-panel.html`.
