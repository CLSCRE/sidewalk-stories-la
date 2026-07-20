import win32com.client
import os

outlook = win32com.client.Dispatch("Outlook.Application")
draft = outlook.CreateItem(0)  # 0 = olMailItem

draft.To = "jason@getvisible.com"
draft.Subject = "New nonprofit idea: your sidewalk app, but for public art and civic repair"

html_body = """
<html>
<head>
<style>
body { font-family: Calibri, Arial, sans-serif; font-size: 11pt; line-height: 1.4; color: #333333; }
p { margin: 0 0 12pt 0; }
</style>
</head>
<body>
<p>Hi Jason,</p>

<p>I have been thinking about that sidewalk photo app you built for the campaign, and I want to run an idea by you that puts it to work in a completely different direction.</p>

<p>The problem is simple, and you have probably seen it yourself walking around LA. Sidewalks are cracked, lifted, and honestly dangerous in a lot of neighborhoods. Seniors trip, wheelchairs get stuck, and the repair responsibility is stuck in a tug of war between property owners and the city. So damaged panels just sit there for years.</p>

<p>Here is what I want to do about it. I am launching a nonprofit, and we are calling it Sidewalk Stories LA for now. The idea is to turn those broken sidewalk panels into small public mosaics, designed and built by neighborhood kids working alongside a professional teaching artist and a licensed concrete crew. Residents snap a photo of a damaged section through an app, the community votes on which one matters most, and each month the top panel gets repaired and turned into a mosaic. Part civic fix, part public art, part youth program.</p>

<p>I am writing you specifically because you already built the exact technical backbone this needs. Your campaign app, the one where people photograph sidewalk damage and tag location automatically, is a real head start that most nonprofits launching a civic tech program would spend six months and fifty thousand dollars trying to build from scratch. I want to bring you in as the technology and platform partner while I handle the artist relationships, grant funding, permitting, and community outreach.</p>

<p>I have attached three things for you to look at:</p>

<p>1. <strong>One Page Funder Prospectus</strong> (PDF): the pitch we are using with grant officers and sponsors<br>
2. <strong>Financial Model</strong> (Excel): the Pilot Scenario shows a 10 panel Year 1 plan that is actually fundable<br>
3. <strong>Partnership Outline</strong> (PDF): three ways we could structure your role, from board member to advisor</p>

<p>Also, if you are open to it, I would love to run this concept through that new feedback tool you developed. Send me whatever you need from my side, and I will drop it in to see what kind of insights we get back before we sit down together.</p>

<p>The nonprofit structure would put you in a founding role with real credit and governance. No salary in year one; it is a startup nonprofit, so nobody gets paid until we close grants. But your existing app work would factor heavily into the organization, and we would lock in your role, title, and IP terms before anything is filed.</p>

<p>Early numbers put a single mosaic panel at about $2,500 to $3,000 all in: concrete repair, mosaic materials, teaching artist stipend, and city permit. At a modest pace, this is a real, fundable program, not a side project.</p>

<p>Grab time with me this week? I will walk you through the numbers, show you the full model, and we can figure out what a real partnership looks like.</p>

<p>Let me know what your calendar looks like.</p>

<p>Trevor Damyan<br>
Founder, Sidewalk Stories LA</p>
</body>
</html>"""

draft.HTMLBody = html_body

# Attach files: 2 PDFs + 1 Excel
folder = r"C:\Users\tdamy\OneDrive - CLS CRE\CLS CRE\Brokerage\AI - LLMs\Claude Code\Projects Marketplace\Sidewalk Art"
attachments = [
    os.path.join(folder, "One-Page-Funder-Prospectus.pdf"),
    os.path.join(folder, "Sidewalk_Mosaic_Nonprofit_Financial_Model.xlsx"),  # Excel file
    os.path.join(folder, "Partnership-Outline-for-Jason.pdf")
]

for filepath in attachments:
    if os.path.exists(filepath):
        draft.Attachments.Add(filepath)
        print(f"Attached: {os.path.basename(filepath)}")
    else:
        print(f"Warning: File not found - {filepath}")

draft.Save()
print("Draft saved to Outlook Drafts folder with HTML formatting (11pt) and attachments")
