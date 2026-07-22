# Sidewalk Stories LA — Google Forms Setup

Created: 2026-07-22
Google Workspace account: trevor@sidewalkstoriesla.org

## Forms Created

| Purpose | URL |
|---------|-----|
| Contact / General Inquiry | https://docs.google.com/forms/d/1LyTMs1pAP3ic8c2INb0HfvbPsH0vcxeJvVnfRm4TPV8/viewform |
| Volunteer Application | https://docs.google.com/forms/d/1AuagaXUeHHP3mgH_djSkvtEe0yIOQFft_c_HEIlNoAs/viewform |
| Report a Cracked Panel | https://docs.google.com/forms/d/1JMVj2oDDDO1RTxgYqG8_KZ1rADkjvbi8vvEiVhZUK6c/viewform |
| Newsletter Signup | https://docs.google.com/forms/d/1MdFq_dfMVNTUVNWPq4chPxowsknLQFg0c8fkNyhTUUY/viewform |

## Pages Using Each Form

- **Contact form** — `website/contact.html`
- **Volunteer application** — `website/volunteer.html`
- **Panel report** — `website/report-panel.html`
- **Newsletter** — `website/contact.html` and `website/stories.html`

## Manual Steps Still Required in Google Forms UI

1. **Link responses to Google Sheets**
   - Open each form.
   - Go to the **Responses** tab.
   - Click **Link to Sheets**.
   - Create a new spreadsheet or select an existing one.
   - This gives you a live dashboard of submissions.

2. **Add file upload question to the Panel Report form**
   - The Google Forms API cannot create file upload questions automatically.
   - Open the Panel Report form.
   - Add a new question after "Describe the Damage".
   - Question type: **File upload**.
   - Label: "Upload a Photo".
   - Allow only images.
   - Required: Yes or No depending on preference.

3. **Enable email notifications for new responses**
   - In each form, go to **Responses > More (three dots) > Get email notifications for new responses**.
   - This sends an email to trevor@sidewalkstoriesla.org every time someone submits.

4. **Confirm sharing settings**
   - Each form is set to "anyone with the link can respond."
   - If you see a "restricted" warning, click **Send > Change anyone with the link**.

## Notes

- All forms were created via the Google Forms API under the Google Cloud project "Sidewalk Stories LA Tools" using OAuth credentials.
- The website now links directly to Google Forms using large call-to-action buttons.
- Formspree placeholders have been removed.
