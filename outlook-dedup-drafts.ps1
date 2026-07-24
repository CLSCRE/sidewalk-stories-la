#Requires -Version 5.1
$ErrorActionPreference = "Stop"

try {
    $ol = New-Object -ComObject Outlook.Application
    $ns = $ol.GetNamespace("MAPI")

    # Find trevor@sidewalkstoriesla.org Drafts
    $draftsFolder = $null
    foreach ($store in $ns.Stores) {
        if ($store.DisplayName -eq "trevor@sidewalkstoriesla.org") {
            try {
                $root = $store.GetRootFolder()
                $gmail = $root.Folders | Where-Object { $_.Name -eq "[Gmail]" }
                if ($gmail) {
                    $draftsFolder = $gmail.Folders | Where-Object { $_.Name -eq "Drafts" }
                }
                if (-not $draftsFolder) {
                    $draftsFolder = $root.Folders | Where-Object { $_.Name -eq "Drafts" }
                }
                if ($draftsFolder) { break }
            } catch {
                # continue
            }
        }
    }

    if (-not $draftsFolder) {
        Write-Host "Could not find trevor@sidewalkstoriesla.org Drafts folder." -ForegroundColor Red
        exit 1
    }

    Write-Host "Drafts folder: $($draftsFolder.FolderPath) [$($draftsFolder.Items.Count) items]`n"

    $sidewalkKeywords = @("sidewalk", "mosaic", "jason", "public art", "neighborhood purpose", "fiscal sponsorship", "awesome foundation", "founding board", "pottery room", "namecheap", "google workspace")

    $items = $draftsFolder.Items
    $items.Sort("[ReceivedTime]", $true)

    $candidates = @()
    for ($i = 1; $i -le $items.Count; $i++) {
        try {
            $item = $items.Item($i)
            if ($item -is [Microsoft.Office.Interop.Outlook.MailItem]) {
                $subjectLower = $item.Subject.ToLower()
                $isMatch = $false
                foreach ($kw in $sidewalkKeywords) {
                    if ($subjectLower.Contains($kw)) { $isMatch = $true; break }
                }
                if ($isMatch) {
                    $candidates += [PSCustomObject]@{
                        Item = $item
                        Subject = $item.Subject
                        Normalized = ($item.Subject.ToLower() -replace ":\s+", ":").Trim()
                        Received = $item.ReceivedTime
                        Modified = $item.LastModificationTime
                    }
                } else {
                    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($item) | Out-Null
                }
            } else {
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($item) | Out-Null
            }
        } catch {
            # ignore
        }
    }

    Write-Host "Found $($candidates.Count) Sidewalk-related draft(s).`n"

    # Group by normalized subject, keep most recent (by LastModificationTime, then ReceivedTime)
    $grouped = $candidates | Group-Object -Property Normalized
    $kept = @()
    $deleted = @()
    foreach ($g in $grouped) {
        $best = $g.Group | Sort-Object Modified, Received -Descending | Select-Object -First 1
        $kept += $best
        foreach ($c in $g.Group) {
            if ($c -ne $best) {
                try {
                    $c.Item.Delete()
                    $deleted += [PSCustomObject]@{ Subject = $c.Subject }
                } catch {
                    Write-Host "Could not delete duplicate '$($c.Subject)': $($_.Exception.Message)" -ForegroundColor Yellow
                }
            }
        }
    }

    Write-Host "Kept $($kept.Count) unique draft(s)."
    Write-Host "Deleted $($deleted.Count) duplicate draft(s).`n"

    if ($deleted.Count -gt 0) {
        Write-Host "Deleted duplicates:"
        $deleted | Format-Table -AutoSize
    }

    Write-Host "`nRemaining Sidewalk-related drafts to review:"
    $kept | Sort-Object Modified | Select-Object Subject, Modified | Format-Table -AutoSize

    # Release COM objects for kept items
    foreach ($k in $kept) {
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($k.Item) | Out-Null
    }

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    if ($ns) { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ns) | Out-Null }
    if ($ol) { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ol) | Out-Null }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
