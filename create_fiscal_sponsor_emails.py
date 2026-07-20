import win32com.client
import os

outlook = win32com.client.Dispatch("Outlook.Application")
base_path = os.path.dirname(os.path.abspath(__file__))

# --- Email 1: Community Partners ---
mail1 = outlook.CreateItem(0)
mail1.To = "partnerships@communitypartners.org"
mail1.Subject = "Fiscal sponsorship inquiry: Sidewalk Stories LA (youth public art pilot)"

html1 = """<html>
<head>
<style>
body { font-family: Calibri, sans-serif; font-size: 11pt; line-height: 1.4; color: #333333; }
p { margin: 0 0 12pt 0; }
strong { color: #2C5F8A; }
</style>
</head>
<body>
<p>Hi there,</p>
<p>My name is Trevor Damyan, and I am the founder of Sidewalk Stories LA, a new project that repairs broken sidewalks in Los Angeles and transforms them into community mosaics designed and built by neighborhood youth working alongside professional teaching artists.</p>
<p>We are preparing to launch a 10 panel pilot in the Fairfax / Mid City West neighborhood in Year 1, with a total budget of roughly $39,000. The program is fundable, visually compelling, and aligned with multiple grant streams (youth arts, public safety, civic improvement). We have a full prospectus, financial model, grant calendar, and city outreach already in motion.</p>
<p>Before we file a standalone 501(c)(3), we want to explore fiscal sponsorship to unlock grant eligibility immediately and reduce Year 1 overhead. Community Partners comes highly recommended as the gold standard for LA based social impact projects.</p>
<p>I have attached our one page prospectus and would love 20 minutes on your calendar to discuss whether Sidewalk Stories LA would be a fit for your fiscal sponsorship program.</p>
<p>Thank you for your time, and I look forward to hearing from you.</p>
<p>Trevor Damyan<br>
Founder, Sidewalk Stories LA<br>
trevor@sidewalkstoriesla.org</p>
</body>
</html>"""

mail1.HTMLBody = html1
att1 = os.path.join(base_path, "One-Page-Funder-Prospectus.pdf")
if os.path.exists(att1):
    mail1.Attachments.Add(att1)
mail1.Save()
print("Draft 1 saved: Community Partners (partnerships@communitypartners.org)")

# --- Email 2: Arts for LA ---
mail2 = outlook.CreateItem(0)
mail2.To = "info@artsforla.org"
mail2.Subject = "Fiscal sponsorship inquiry: Sidewalk Stories LA (youth sidewalk mosaic pilot)"

html2 = """<html>
<head>
<style>
body { font-family: Calibri, sans-serif; font-size: 11pt; line-height: 1.4; color: #333333; }
p { margin: 0 0 12pt 0; }
strong { color: #2C5F8A; }
</style>
</head>
<body>
<p>Hi there,</p>
<p>My name is Trevor Damyan, and I am the founder of Sidewalk Stories LA, a project that turns cracked sidewalk panels in Los Angeles into small public mosaics designed and installed by neighborhood kids with teaching artists.</p>
<p>Our pilot starts this fall: 10 panels in the Fairfax / Mid City West neighborhood, $39,000 total budget, and a clear path to standalone 501(c)(3) status in Year 2. We have grant prospects lined up at the LA County Arts Commission, City of LA DCA, and California Community Foundation, all of which require nonprofit status or fiscal sponsorship.</p>
<p>We are reaching out to Arts for LA because your network and mission alignment with public art and youth arts education in Los Angeles are exactly what a project like ours needs in its first year. We would love to explore whether Arts for LA would consider fiscally sponsoring Sidewalk Stories LA for our pilot.</p>
<p>I have attached our one page prospectus and would welcome a brief call to discuss fit, fee structure, and next steps.</p>
<p>Thank you for your time.</p>
<p>Trevor Damyan<br>
Founder, Sidewalk Stories LA<br>
trevor@sidewalkstoriesla.org</p>
</body>
</html>"""

mail2.HTMLBody = html2
att2 = os.path.join(base_path, "One-Page-Funder-Prospectus.pdf")
if os.path.exists(att2):
    mail2.Attachments.Add(att2)
mail2.Save()
print("Draft 2 saved: Arts for LA (info@artsforla.org)")

print("\nBoth fiscal sponsor outreach drafts saved to Outlook.")
