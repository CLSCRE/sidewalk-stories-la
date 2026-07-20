import win32com.client
import os

outlook = win32com.client.Dispatch("Outlook.Application")

def create_draft(to, subject, body_text, cc=""):
    mail = outlook.CreateItem(0)
    mail.To = to
    if cc:
        mail.CC = cc
    mail.Subject = subject

    html_body = f"""
<html>
<head>
<style>
body {{ font-family: Calibri, sans-serif; font-size: 11pt; line-height: 1.4; color: #333333; }}
p {{ margin: 0 0 12pt 0; }}
ul {{ margin: 0 0 12pt 0; padding-left: 24pt; }}
li {{ margin-bottom: 6pt; }}
strong {{ color: #2C5F8A; }}
</style>
</head>
<body>
{body_text}
</body>
</html>"""

    mail.HTMLBody = html_body
    mail.Save()
    print(f"Draft saved: {subject}")

# Email 1: Safe Sidewalks LA / Bureau of Engineering
body1 = """<p>Hi,</p>
<p>I am writing on behalf of a new California nonprofit public benefit corporation called Sidewalk Stories LA. We repair broken sidewalk panels and transform them into community-built mosaic art, designed and installed by neighborhood youth working with a professional teaching artist and a licensed concrete crew.</p>
<p>Our pilot program targets the Fairfax / Mid-City West neighborhood, where we have identified several damaged sidewalk panels that create daily hazards for seniors and people with mobility challenges.</p>
<p>I have three questions about how our nonprofit can work within existing city programs:</p>
<p><strong>1. Safe Sidewalks LA Rebate Program and Nonprofit Partnerships</strong></p>
<p>Can a nonprofit partner with an adjacent property owner to manage the sidewalk repair and mosaic installation? Specifically, could the property owner apply for the rebate, and the nonprofit serve as the project manager and contractor coordinator? Or does the property owner need to be the sole applicant and manage the work directly?</p>
<p><strong>2. Right-of-Way Work Permits</strong></p>
<p>What permits does a nonprofit need to repair and install mosaic art on a public sidewalk panel? Is this handled through the Bureau of Engineering, StreetsLA, or another department? What is the typical timeline and cost for such a permit?</p>
<p><strong>3. Liability and Insurance Requirements</strong></p>
<p>When neighborhood youth (ages 8 to 16) participate in public art installation on a sidewalk panel, what liability insurance or waivers does the city require? Does the city require the nonprofit to carry general liability insurance naming the city as additional insured?</p>
<p>Our Year 1 pilot budget is $38,700 for 10 panels. Each panel costs approximately $2,700, including concrete repair, mosaic materials, a teaching artist stipend, and permits. We want to make sure we are following all city requirements before we begin.</p>
<p>I would welcome a brief call or email exchange with the appropriate person in your office. I am happy to share our pilot plan, insurance certificates, and any other documentation you need.</p>
<p>Thank you for your time and guidance.</p>
<p>Trevor Damyan<br>
Founder, Sidewalk Stories LA<br>
Email: trevor@sidewalkstoriesla.org<br>
Website: sidewalkstoriesla.org<br>
Address: 7951 Blackburn Ave, Los Angeles, CA 90048</p>
"""

# Email 2: DCA Public Art
body2 = """
<p>Hi,</p>
<p>I am the founder of Sidewalk Stories LA, a California nonprofit public benefit corporation launching a pilot program in the Fairfax / Mid-City West neighborhood.</p>
<p>Our program repairs broken sidewalk panels and transforms them into community-built mosaic art. Neighborhood kids work with a professional teaching artist to design and install the mosaic on the newly repaired concrete surface.</p>
<p>I am writing to understand whether this type of project requires review by the Cultural Affairs Commission, and if so, what the process, timeline, and fee structure looks like.</p>
<p><strong>Project details:</strong></p>
<ul>
<li>Location: Public sidewalk panels in the Fairfax / Mid-City West area</li>
<li>Surface area: Typical LA sidewalk panel (approximately 4 feet by 6 feet)</li>
<li>Materials: Weather-resistant ceramic tile, grout, and sealant</li>
<li>Artist: Licensed teaching artist with public mosaic experience</li>
<li>Youth participants: 6 to 10 neighborhood kids per panel, supervised by the artist and nonprofit staff</li>
<li>Structural work: Licensed concrete crew handles all concrete repair under city permit</li>
</ul>
<p><strong>My questions:</strong></p>
<ol>
<li>Does a mosaic installed on a public sidewalk panel require Cultural Affairs Commission review?</li>
<li>If yes, what is the submission process, typical timeline, and any associated fees?</li>
<li>Are there design guidelines or restrictions for artwork in the public right-of-way (e.g., height limits, material restrictions, anti-slip requirements)?</li>
<li>Does the city require the artist to carry professional liability insurance or a specific license for public right-of-way work?</li>
<li>Are there any existing city programs (like PWIAP) that could fund or fast-track this type of community-driven public art?</li>
</ol>
<p>Our first panel is planned for late 2026 or early 2027, so we have time to navigate the approval process properly. I would welcome a brief conversation with someone in your office who can guide us through the requirements.</p>
<p>Thank you for your time.</p>
<p>Trevor Damyan<br>
Founder, Sidewalk Stories LA<br>
Email: trevor@sidewalkstoriesla.org<br>
Website: sidewalkstoriesla.org</p>
"""

# Email 3: Mid-City West Neighborhood Council
body3 = """
<p>Hi,</p>
<p>My name is Trevor Damyan, and I live at 7951 Blackburn Ave in the Fairfax / Mid-City West neighborhood. I am writing to introduce a new nonprofit I have founded called Sidewalk Stories LA, and to ask about your community improvement grant process.</p>
<p><strong>What we do:</strong></p>
<p>Sidewalk Stories LA repairs broken and hazardous sidewalk panels and transforms them into small public mosaics, designed and built by neighborhood kids working alongside a professional teaching artist and a licensed concrete crew.</p>
<p>The process is simple:</p>
<ol>
<li>Residents photograph damaged sidewalk panels through a mobile app.</li>
<li>The community votes on which panel matters most.</li>
<li>A licensed crew repairs the panel.</li>
<li>Neighborhood kids and a teaching artist design and install a mosaic.</li>
<li>We celebrate the finished panel and move to the next one.</li>
</ol>
<p><strong>Our pilot:</strong></p>
<p>We are launching with 10 panels in Year 1, starting in the streets I walk every day near Blackburn and Melrose. Each panel costs $2,700 all in (concrete repair, tile, artist stipend, city permit) and engages 6 to 10 local youth in public art creation.</p>
<p><strong>Why this matters for our neighborhood:</strong></p>
<p>I see the same cracked and lifted sidewalk panels every day on my walks. They are hazards for seniors, people with wheelchairs, and parents with strollers. The city repair backlog is measured in years. We want to fix them ourselves, with community involvement, and turn each repair into a moment of neighborhood pride.</p>
<p><strong>My questions:</strong></p>
<ol>
<li>Does the Mid-City West Neighborhood Council offer community improvement grants that could support a project like this?</li>
<li>What is the typical award size and application timeline?</li>
<li>Would you be open to a brief presentation at an upcoming council or committee meeting?</li>
<li>Can you recommend a specific damaged sidewalk panel in the district that the council considers a priority?</li>
</ol>
<p>I would love to attend an upcoming meeting, introduce myself and the project, and learn how we can partner with the Neighborhood Council to make this pilot successful.</p>
<p>Thank you for your time and for everything you do for our neighborhood.</p>
<p>Trevor Damyan<br>
Founder, Sidewalk Stories LA<br>
Email: trevor@sidewalkstoriesla.org<br>
Website: sidewalkstoriesla.org<br>
Address: 7951 Blackburn Ave, Los Angeles, CA 90048</p>
"""

create_draft("sidewalks@lacity.org", "Question about nonprofit-managed sidewalk repair and mosaic art in public right-of-way", body1)
create_draft("dca.review@lacity.org", "Public art review process for community mosaic on sidewalk panel", body2, cc="DCA.PublicArt@lacity.org")
create_draft("outreach@midcitywest.org", "New nonprofit repairing sidewalks and creating public art in the neighborhood", body3, cc="board@midcitywest.org")

print("All three city email drafts saved to Outlook.")
