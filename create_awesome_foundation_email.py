import win32com.client

outlook = win32com.client.Dispatch("Outlook.Application")
mail = outlook.CreateItem(0)

mail.To = "la@awesomefoundation.org"
mail.Subject = "Awesome Foundation LA application: Sidewalk Stories LA"

html_body = """<html>
<head>
<style>
body { font-family: Calibri, sans-serif; font-size: 11pt; line-height: 1.4; color: #333333; }
p { margin: 0 0 12pt 0; }
strong { color: #2C5F8A; }
</style>
</head>
<body>
<p>Hi Awesome Foundation LA,</p>
<p>I am Trevor Damyan, founder of Sidewalk Stories LA. We are a brand new nonprofit project in Los Angeles that repairs cracked sidewalk panels and transforms them into community mosaics built by neighborhood kids working with professional teaching artists.</p>
<p>Here is the idea in one sentence: a resident snaps a photo of a dangerous sidewalk panel through our mobile app, the neighborhood votes on which one matters most, and each month the winning panel gets repaired by a licensed concrete crew and turned into a small public mosaic led by local youth.</p>
<p>We are launching a 10 panel pilot this fall in the Fairfax / Mid City West neighborhood. The first panel needs roughly $1,000 in mosaic materials: tile, grout, sealant, and safety gear for the kids. An Awesome Foundation grant would directly fund the very first mosaic and give us early momentum to show funders, sponsors, and the city that this model works.</p>
<p>We already have a financial model, grant pipeline, city outreach in progress, and a live website. What we need now is the first $1,000 to prove the concept on the street.</p>
<p>Learn more at sidewalkstoriesla.org. Happy to answer any questions.</p>
<p>Trevor Damyan<br>
Founder, Sidewalk Stories LA<br>
trevor@sidewalkstoriesla.org<br>
<a href="https://sidewalkstoriesla.org">sidewalkstoriesla.org</a></p>
</body>
</html>"""

mail.HTMLBody = html_body
mail.Save()
print("Awesome Foundation LA application draft saved to Outlook (la@awesomefoundation.org).")
