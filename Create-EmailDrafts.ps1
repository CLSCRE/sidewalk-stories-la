#Requires -Version 5.1
<#
.SYNOPSIS
    Creates all pending Sidewalk Stories LA email drafts in Outlook for Trevor's review.
.DESCRIPTION
    Connects to Outlook, removes old duplicate drafts by subject, and saves fresh
    HTML drafts in the Drafts folder. No emails are sent. Trevor must open each
    draft, review, and click Send manually.
#>

$ErrorActionPreference = "Stop"

try {
    $ol = New-Object -ComObject Outlook.Application
    $ns = $ol.GetNamespace("MAPI")
    $draftsFolder = $ns.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderDrafts)

    # Prefer trevor@sidewalkstoriesla.org as sending account if it exists
    $preferredAccount = $null
    foreach ($acct in $ol.Session.Accounts) {
        if ($acct.SmtpAddress -eq "trevor@sidewalkstoriesla.org") {
            $preferredAccount = $acct
            break
        }
    }
    if ($preferredAccount) {
        Write-Host "Using account: $($preferredAccount.SmtpAddress)"
    } else {
        Write-Host "Preferred account trevor@sidewalkstoriesla.org not found; using default Outlook account."
    }

    $signatureHtml = @"
<table cellpadding="0" cellspacing="0" style="border-collapse: collapse; font-family: Calibri, sans-serif; font-size: 11pt; line-height: 1.4; color: #333333;">
<tr>
<td style="padding-right: 14px; vertical-align: top;">
<img src="https://sidewalkstoriesla.org/images/logo-signature.jpg" alt="Sidewalk Stories LA" width="90" style="display: block; border: 0;">
</td>
<td style="border-left: 2px solid #E07B3A; padding-left: 14px; vertical-align: top;">
<p style="margin: 0 0 4px 0;"><strong>Trevor Damyan</strong></p>
<p style="margin: 0 0 4px 0; color: #E07B3A;">Founder, Sidewalk Stories LA</p>
<p style="margin: 0 0 8px 0;">
    <a href="mailto:trevor@sidewalkstoriesla.org" style="color: #2C5F8A; text-decoration: none;">trevor@sidewalkstoriesla.org</a> |
    <a href="https://sidewalkstoriesla.org" style="color: #2C5F8A; text-decoration: none;">sidewalkstoriesla.org</a> |
    <a href="tel:+18054550051" style="color: #2C5F8A; text-decoration: none;">805.455.0051</a>
</p>
<p style="margin: 0 0 4px 0; font-size: 10pt; color: #666666; font-style: italic;">Repairing broken sidewalks. Building community. One mosaic at a time.</p>
<p style="margin: 0;">
    <a href="#" style="color: #2C5F8A; text-decoration: none; font-size: 10pt;">Instagram</a> |
    <a href="#" style="color: #2C5F8A; text-decoration: none; font-size: 10pt;">Facebook</a> |
    <a href="#" style="color: #2C5F8A; text-decoration: none; font-size: 10pt;">LinkedIn</a>
</p>
</td>
</tr>
</table>
"@

    function Wrap-Body($bodyText) {
        $escapedBody = $bodyText -replace "&", "&amp;" -replace "<", "&lt;" -replace ">", "&gt;"
        return @"
<html>
<body style="font-family: Calibri, sans-serif; font-size: 11pt; line-height: 1.4; color: #333333;">
<div style="font-family: Calibri, sans-serif; font-size: 11pt; line-height: 1.4; color: #333333;">
$escapedBody
</div>
<br>
$signatureHtml
</body>
</html>
"@
    }

    function Remove-OldDrafts($subject) {
        $items = $draftsFolder.Items
        $items.Sort("[ReceivedTime]", $true)
        $matches = @()
        foreach ($item in $items) {
            try {
                if ($item -is [Microsoft.Office.Interop.Outlook.MailItem] -and $item.Subject -eq $subject) {
                    $matches += $item
                }
            } catch {
                # Skip non-mail items
            }
        }
        foreach ($m in $matches) {
            try {
                $m.Delete()
                Write-Host "  Deleted old draft: '$subject'"
            } catch {
                Write-Host "  Could not delete old draft '$subject': $($_.Exception.Message)"
            }
        }
    }

    function New-OutlookDraft($to, $cc, $subject, $bodyText) {
        Remove-OldDrafts -subject $subject
        $mail = $ol.CreateItem([Microsoft.Office.Interop.Outlook.OlItemType]::olMailItem)
        $mail.To = $to
        if ($cc) { $mail.CC = $cc }
        $mail.Subject = $subject
        $mail.HTMLBody = Wrap-Body -bodyText $bodyText
        if ($preferredAccount) {
            try {
                $mail.SendUsingAccount = $preferredAccount
            } catch {
                Write-Host "  Could not set sending account: $($_.Exception.Message)"
            }
        }
        $mail.Save()
        Write-Host "Created draft: '$subject' -> $to"
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($mail) | Out-Null
    }

    $emails = @(
        @{
            To = "jason@getvisible.com"
            CC = ""
            Subject = "Sidewalk Stories LA update: website is live, nonprofit is forming"
            Body = @"
Hi Jason,

Thanks again for the quick reply. I wanted to follow up on two things.

First, the website is now live at sidewalkstoriesla.org and the two PDFs I mentioned are hosted there:

Partnership outline: https://sidewalkstoriesla.org/documents/Partnership-Outline-for-Jason.pdf
One page funder prospectus: https://sidewalkstoriesla.org/documents/One-Page-Funder-Prospectus.pdf

Second, before we schedule a real call I want to lock down the IP question. You said the underlying tech is obviously yours, but that you built it for Adam's campaign. Is this a product that Adam or his team owns? Or is it yours to license? That answer changes whether we are talking about a license, a rebuild, or something else, and I do not want to walk in assuming the wrong thing.

On the ADA / curb ramp trigger you flagged: I filed a customer service request with the city and heard back from Cultural Affairs. It looks like a mosaic in the public right of way most likely needs Cultural Affairs Commission review, and the material / anti slip / right of way rules sit with Bureau of Street Services and Bureau of Engineering. I am tracking it down. Your point about the real per panel cost is exactly why I want to get you on the phone before I commit to a budget.

Can we grab 30 minutes this week or next? I will bring the full model and the three partnership structures we could use.

Trevor
"@
        },
        @{
            To = "mason.ng@lacity.org"
            CC = ""
            Subject = "Re: Public art / sidewalk mosaic review: next steps"
            Body = @"
Hi Mason,

Thank you for the detailed guidance. A few follow ups:

1. How do I request the free voluntary early review for a sidewalk panel mosaic? Is there a specific form, or do I email this address with a concept package?

2. I will contact Bureau of Street Services and Bureau of Engineering directly for the design, material, anti slip, and right of way requirements. If you have a specific contact there you recommend, please send it my way.

3. I have already connected with Valerie Washburn at Mid-City West Neighborhood Council about potential Neighborhood Purpose Grant support and a board meeting intro. Would a letter or resolution of support from the NC help fast track the Cultural Affairs Commission review?

4. For the liability insurance: you noted the licensed concrete contractor carries it. Does that coverage extend to the youth mosaic activity itself, or only the concrete repair? I want to confirm before we bring kids into the public right of way.

I am happy to put together a short concept package with panel location, materials, renderings, and insurance details once I know what format you need.

Thanks again,
Trevor
"@
        },
        @{
            To = "sidewalks@lacity.org"
            CC = ""
            Subject = "Re: Sidewalk repair / mosaic art permit question: follow up"
            Body = @"
Hi,

Thank you for the clear direction. I have submitted a Customer Service Request to LA's Central District through the Angeleno portal for the mosaic art installation itself, using 7951 Blackburn Ave as the reference address until we select a specific pilot panel.

I understand that the mosaic work does not qualify under a regular A Permit in the Sidewalk Rebate Program. We will still need a separate standard concrete repair permit for the underlying sidewalk panel before the mosaic goes in, correct? If so, is that also handled through the CSR process, or do I file that as a separate permit application with StreetsLA / BOE?

I will also follow up with Bureau of Street Services and Bureau of Engineering for the material and safety requirements. If there is a specific contact at Central District you recommend for the art installation CSR, please let me know.

Thanks,
Trevor
"@
        },
        @{
            To = "vwashburn@midcitywest.org"
            CC = ""
            Subject = "Re: Neighborhood Purpose Grants and board meeting intro: Sidewalk Stories LA"
            Body = @"
Hi Valerie,

Thank you for the quick response and for the information on Neighborhood Purpose Grants. I would love to take you up on the 2 minute public comment intro at an upcoming Board or Executive Committee meeting.

Could you let me know the date and time of the next meeting where I could do a brief intro? I will keep it to 2 minutes, explain the mission, and mention that we are based in the Fairfax / Mid-City West area.

I will also keep an eye out for the 2026-27 Neighborhood Purpose Grant application process once the deadlines are set.

Thanks again,
Trevor
"@
        },
        @{
            To = "StreetsLA.ERT@lacity.org"
            CC = ""
            Subject = "Material and safety requirements for sidewalk panel mosaic art"
            Body = @"
Hi,

I am the founder of Sidewalk Stories LA, a California nonprofit public benefit corporation. We repair damaged public sidewalk panels and transform them into community built mosaic art, designed and installed by neighborhood youth working with a professional teaching artist alongside a licensed concrete crew.

I am reaching out because the Department of Cultural Affairs indicated that design, material, anti slip, and right of way requirements for a mosaic installed on a public sidewalk panel are managed by Bureau of Street Services and Bureau of Engineering.

Our planned materials are weather resistant ceramic tile, grout, and sealant on a typical 4 foot by 6 foot sidewalk panel, with all concrete repair handled first by a licensed concrete crew under a separate city permit.

Could you point me to:

1. Any standard specifications or requirements for anti slip surfaces on sidewalk art or inlays.
2. The right of way permit or approval process that applies to a mosaic installed at sidewalk level.
3. A contact at Bureau of Engineering who handles public art / sidewalk panel installations if StreetsLA is not the right office for this specific question.

I have also filed a Customer Service Request with Central District through the Angeleno portal. Happy to share the request number once I receive it.

Thank you for any guidance.

Trevor Damyan
Founder, Sidewalk Stories LA
"@
        },
        @{
            To = "AskUs@CommunityPartners.Zendesk.com"
            CC = ""
            Subject = "Fiscal sponsorship inquiry: Sidewalk Stories LA"
            Body = @"
Hi,

I am the founder of Sidewalk Stories LA, a new California nonprofit public benefit corporation based in Los Angeles. Our mission is to repair broken sidewalk panels and transform them into community built mosaics designed and installed by local youth working with professional teaching artists and licensed concrete crews.

We are in the process of filing our Articles of Incorporation and applying for 501(c)(3) status. We would like to explore a fiscal sponsorship relationship with Community Partners for our first 12 to 18 months so we can begin receiving tax deductible donations and grants while our standalone 501(c)(3) application is pending.

Could you please direct me to the right intake contact or process for new fiscal sponsorship inquiries? I have already reviewed the application portal at portal.communitypartners.org/full-application and would appreciate guidance on whether our project is a fit before submitting a full application.

Our pilot plan covers 10 panels in Year 1 in the Fairfax / Mid-City West area, with a projected budget of $38,700 and diversified revenue from small grants, corporate sponsors, and individual donations.

Thank you for any guidance.

Trevor Damyan
Founder, Sidewalk Stories LA
"@
        },
        @{
            To = "awesome@awesomefoundation.org"
            CC = "losangeles@awesomefoundation.org"
            Subject = "Awesome Foundation LA grant application: Sidewalk Stories LA"
            Body = @"
Hi Awesome Foundation LA team,

I am applying for a $1,000 Awesome Foundation LA grant to fund the first community built sidewalk mosaic panel in Los Angeles through Sidewalk Stories LA.

The idea is simple: residents report damaged sidewalk panels, the community votes on which one matters most, and each month a panel gets repaired and transformed into a mosaic designed and built by neighborhood kids working with a professional teaching artist and a licensed concrete crew.

The $1,000 would cover ceramic tile, grout, sealant, and safety supplies for our pilot panel in the Fairfax / Mid-City West neighborhood. It is a small, visible, awesome public art and safety win that can be replicated across the city.

You can learn more at https://sidewalkstoriesla.org and view our one page prospectus at https://sidewalkstoriesla.org/documents/One-Page-Funder-Prospectus.pdf.

I would love to present this at an upcoming Awesome Foundation LA pitch night.

Thanks for considering it.

Trevor Damyan
Founder, Sidewalk Stories LA
"@
        },
        @{
            To = "[PATRICIA_EMAIL_NEEDED]"
            CC = ""
            Subject = "Following up: sidewalk mosaic nonprofit idea"
            Body = @"
Hi Patricia,

Hope you are doing well. It is Trevor from The Pottery Room.

I am launching a nonprofit here in LA called Sidewalk Stories LA. The idea is to repair broken sidewalk panels and turn them into community mosaics designed and built by local kids working with a teaching artist and a concrete crew.

I remember you mentioned you have done some sidewalk and public mosaic art before. I would love to pick your brain about it. Specifically:

Your experience with mosaic work on sidewalks or public right of way.
How city permitting worked for the projects you have done.
Whether you might be interested in being the teaching artist for our pilot.

No pressure at all. Just thought you would be the perfect person to talk to first. Want to grab coffee or a quick call this week?

Trevor
"@
        },
        @{
            To = "[CANDIDATE_EMAIL_NEEDED]"
            CC = ""
            Subject = "Joining the founding board of Sidewalk Stories LA"
            Body = @"
Hi [Name],

I am launching a nonprofit called Sidewalk Stories LA. We repair broken sidewalk panels and transform them into community built mosaics designed and installed by neighborhood youth working with professional teaching artists and licensed concrete crews.

I am recruiting one independent founding board member to serve alongside me as the organization files its Articles of Incorporation and applies for 501(c)(3) status. The ideal candidate brings experience in one of these areas: arts education, nonprofit law, community organizing, or youth program operations in Los Angeles.

Board responsibilities would be standard for a startup nonprofit: attend quarterly meetings, help shape strategy and fundraising, review financials, and support the mission. There is no compensation in Year 1; this is a founding volunteer role with real governance influence.

If you are interested, I would love to send you the one page prospectus and schedule a 20 minute call to answer any questions.

Thank you for considering it.

Trevor Damyan
Founder, Sidewalk Stories LA
"@
        }
    )

    Write-Host "`nCreating $($emails.Count) draft emails in Outlook...`n"
    $created = @()
    foreach ($e in $emails) {
        try {
            New-OutlookDraft -to $e.To -cc $e.CC -subject $e.Subject -bodyText $e.Body
            $created += [PSCustomObject]@{
                Subject = $e.Subject
                To = $e.To
            }
        } catch {
            Write-Host "FAILED to create draft '$($e.Subject)': $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`nDone. Created $($created.Count) of $($emails.Count) drafts.`n"
    $created | Format-Table -AutoSize

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    if ($ns) { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ns) | Out-Null }
    if ($ol) { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ol) | Out-Null }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
