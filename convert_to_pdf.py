import markdown
from weasyprint import HTML, CSS
import os

folder = r"C:\Users\tdamy\OneDrive - CLS CRE\CLS CRE\Brokerage\AI - LLMs\Claude Code\Projects Marketplace\Sidewalk Art"

# Convert markdown files to PDF using weasyprint
def md_to_pdf(md_path, pdf_path):
    with open(md_path, 'r', encoding='utf-8') as f:
        md_text = f.read()
    html_body = markdown.markdown(md_text)
    full_html = f"""
    <html>
    <head>
    <style>
        @page {{ margin: 50px 45px; }}
        body {{ font-family: Calibri, Arial, sans-serif; font-size: 11pt; line-height: 1.5; color: #333333; margin: 0; }}
        h1 {{ font-size: 20pt; color: #2C5F8A; margin-top: 24pt; margin-bottom: 12pt; font-weight: bold; }}
        h2 {{ font-size: 14pt; color: #2C5F8A; margin-top: 18pt; margin-bottom: 8pt; font-weight: bold; border-bottom: 1px solid #2C5F8A; padding-bottom: 4pt; }}
        h3 {{ font-size: 12pt; color: #444444; margin-top: 14pt; margin-bottom: 6pt; font-weight: bold; }}
        p {{ margin-bottom: 10pt; text-align: left; }}
        table {{ border-collapse: collapse; width: 100%; margin: 12pt 0; }}
        th, td {{ border: none; border-bottom: 1px solid #DDDDDD; padding: 8pt 4pt; text-align: left; font-size: 10.5pt; vertical-align: top; }}
        th {{ background-color: #2C5F8A; color: white; font-weight: bold; border-bottom: 2px solid #1a3a5c; }}
        tr:last-child td {{ border-bottom: 2px solid #2C5F8A; }}
        ul, ol {{ margin-bottom: 10pt; padding-left: 20pt; }}
        li {{ margin-bottom: 6pt; }}
        strong {{ color: #2C5F8A; }}
        em {{ color: #666666; font-size: 10pt; }}
        hr {{ border: none; border-top: 1px solid #CCCCCC; margin: 20pt 0; }}
    </style>
    </head>
    <body>
    {html_body}
    </body>
    </html>
    """
    HTML(string=full_html).write_pdf(pdf_path)
    print(f"Created PDF: {pdf_path}")

# Convert One Page Funder Prospectus
md_to_pdf(
    os.path.join(folder, "One-Page-Funder-Prospectus.md"),
    os.path.join(folder, "One-Page-Funder-Prospectus.pdf")
)

# Convert Partnership Outline
md_to_pdf(
    os.path.join(folder, "Partnership-Outline-for-Jason.md"),
    os.path.join(folder, "Partnership-Outline-for-Jason.pdf")
)

print("All conversions complete.")
