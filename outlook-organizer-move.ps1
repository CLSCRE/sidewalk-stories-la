#Requires -Version 5.1
$ErrorActionPreference = "Stop"

try {
    $ol = New-Object -ComObject Outlook.Application
    $ns = $ol.GetNamespace("MAPI")

    # Find target folder: trevor@clscre.com > Inbox > Sidewalk Stories LA
    $targetFolder = $null
    foreach ($store in $ns.Stores) {
        if ($store.DisplayName -eq "trevor@clscre.com") {
            $root = $store.GetRootFolder()
            $inbox = $root.Folders | Where-Object { $_.Name -eq "Inbox" }
            if ($inbox) {
                $targetFolder = $inbox.Folders | Where-Object { $_.Name -like "*Sidewalk*" }
                if ($targetFolder) { break }
            }
        }
    }

    if (-not $targetFolder) {
        Write-Host "Target folder 'Sidewalk Stories LA' not found under trevor@clscre.com Inbox." -ForegroundColor Red
        exit 1
    }
    Write-Host "Target folder: $($targetFolder.FolderPath) [$($targetFolder.Items.Count) items before run]"

    $patterns = @(
        "jason@getvisible.com",
        "mason.ng@lacity.org",
        "sidewalks@lacity.org",
        "vwashburn@midcitywest.org",
        "dca.review@lacity.org",
        "outreach@midcitywest.org",
        "artsforla.org",
        "communitypartners.org",
        "communitypartners.zendesk.com",
        "awesomefoundation.org",
        "sidewalkstoriesla.org",
        "sidewalkstoriesla.com"
    )

    $namePatterns = @(
        "Patricia",
        "Pottery Room",
        "Tracy"
    )

    function Match-Email($item) {
        if ($item -isnot [Microsoft.Office.Interop.Outlook.MailItem]) { return $false }
        if ($item.Parent.EntryID -eq $targetFolder.EntryID) { return $false }

        $haystack = (
            $item.SenderEmailAddress + " " +
            $item.SenderName + " " +
            $item.To + " " +
            $item.CC + " " +
            $item.BCC + " " +
            $item.Subject + " " +
            $item.Body
        ).ToLower()

        foreach ($p in $patterns) {
            if ($haystack.Contains($p.ToLower())) { return $true }
        }
        foreach ($p in $namePatterns) {
            if ($haystack.Contains($p.ToLower())) { return $true }
        }
        if ($item.Subject -and $item.Subject.ToLower().Contains("sidewalk")) { return $true }
        return $false
    }

    $relevantNames = @("Inbox", "Sent Items", "Sent Mail", "Drafts", "Important", "Archive", "Trash", "Deleted Items")

    function Collect-RelevantFolders($folder, [ref]$list) {
        if ($folder.DefaultItemType -eq [Microsoft.Office.Interop.Outlook.OlItemType]::olMailItem) {
            if ($relevantNames -contains $folder.Name) {
                $list.Value += $folder
            }
        }
        foreach ($sub in $folder.Folders) {
            Collect-RelevantFolders -folder $sub -list $list
        }
    }

    $foldersToScan = @()
    foreach ($store in $ns.Stores) {
        if ($store.DisplayName -notin @("trevor@clscre.com", "tdamyan@gmail.com", "trevor@sidewalkstoriesla.org", "trevor@districtbridgecapital.com")) { continue }
        try {
            $root = $store.GetRootFolder()
            Collect-RelevantFolders -folder $root -list ([ref]$foldersToScan)
        } catch {
            Write-Host "Could not read store $($store.DisplayName): $($_.Exception.Message)"
        }
    }

    Write-Host "`nScanning $($foldersToScan.Count) targeted folders...`n"

    $moved = @()
    $skipped = 0
    $scanned = 0

    foreach ($folder in $foldersToScan) {
        if ($folder.EntryID -eq $targetFolder.EntryID) { continue }

        $items = $folder.Items
        $count = $items.Count
        $scanned += $count
        if ($count -eq 0) { continue }

        Write-Host "Scanning $($folder.FolderPath) [$count items]"

        $candidates = $items
        if ($count -gt 1000) {
            try {
                $filter = '@SQL="urn:schemas:httpmail:subject" LIKE ''%sidewalk%'''
                $candidates = $items.Restrict($filter)
                Write-Host "  Pre-filtered to $($candidates.Count) candidates"
            } catch {
                $candidates = $items
                Write-Host "  Pre-filter failed; scanning full folder"
            }
        }

        $candidateCount = $candidates.Count
        for ($i = $candidateCount; $i -ge 1; $i--) {
            try {
                $item = $candidates.Item($i)
                if (Match-Email -item $item) {
                    $subject = $item.Subject
                    $sender = $item.SenderEmailAddress
                    $received = $item.ReceivedTime
                    try {
                        $item.Move($targetFolder) | Out-Null
                        $moved += [PSCustomObject]@{
                            Received = $received
                            Sender = $sender
                            Subject = $subject
                            Source = $folder.FolderPath
                        }
                    } catch {
                        Write-Host "  Could not move '$subject': $($_.Exception.Message)" -ForegroundColor Yellow
                        $skipped++
                    }
                }
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($item) | Out-Null
            } catch {
                # ignore non-mail or access errors
            }
        }

        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($candidates) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($items) | Out-Null
    }

    Write-Host "`nDone."
    Write-Host "Scanned $scanned items across $($foldersToScan.Count) folders."
    Write-Host "Moved $($moved.Count) email(s) to '$($targetFolder.Name)'."
    Write-Host "Target folder now has $($targetFolder.Items.Count) items."
    if ($skipped -gt 0) { Write-Host "Skipped $skipped item(s) due to errors." }

    if ($moved.Count -gt 0) {
        $moved | Sort-Object Received | Format-Table -AutoSize
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
