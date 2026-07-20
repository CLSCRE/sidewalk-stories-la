import win32com.client

outlook = win32com.client.Dispatch("Outlook.Application")
namespace = outlook.GetNamespace("MAPI")

# Find the draft in the Drafts folder
drafts_folder = namespace.GetDefaultFolder(16)  # 16 = olFolderDrafts
messages = drafts_folder.Items

# Look for the draft by subject
subject_to_find = "New nonprofit idea: your sidewalk app, but for public art and civic repair"
found = False

for msg in messages:
    if subject_to_find in msg.Subject:
        msg.To = "jason@getvisible.com"

        # Clear existing attachments and add correct ones
        while msg.Attachments.Count > 0:
            msg.Attachments.Remove(1)

        import os
        folder = r"C:\Users\tdamy\OneDrive - CLS CRE\CLS CRE\Brokerage\AI - LLMs\Claude Code\Projects Marketplace\Sidewalk Art"
        attachments = [
            os.path.join(folder, "One-Page-Funder-Prospectus.pdf"),
            os.path.join(folder, "Sidewalk_Mosaic_Nonprofit_Financial_Model.xlsx"),  # Excel file
            os.path.join(folder, "Partnership-Outline-for-Jason.pdf")
        ]

        for filepath in attachments:
            if os.path.exists(filepath):
                msg.Attachments.Add(filepath)
                print(f"Attached: {os.path.basename(filepath)}")

        msg.Save()
        print(f"Updated draft email to: jason@getvisible.com with corrected attachments")
        found = True
        break

if not found:
    print("Draft not found. Please check your Outlook Drafts folder.")
