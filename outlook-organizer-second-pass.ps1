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
    Write-Host "Target folder: $($targetFolder.FolderPath) [$($targetFolder.Items.Count) items before second pass]"

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
        "sidewalkstoriesla.com",
        "Patricia",
        "Pottery Room",
        "Tracy",
        "praxis.la",
        "Namecheap",
        "Google Workspace"
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
        return $false
    }

    function Get-Folder($storeName, $folderName) {
        foreach ($store in $ns.Stores) {
            if ($store.DisplayName -ne $storeName) { continue }
            try {
                $root = $store.GetRootFolder()
                $folder = $root.Folders | Where-Object { $_.Name -eq $folderName }
                if ($folder) { return $folder }
            } catch {
                return $null
            }
        }
        return $null
    }

    function Get-GmailSubfolder($storeName, $subName) {
        foreach ($store in $ns.Stores) {
            if ($store.DisplayName -ne $storeName) { continue }
            try {
                $root = $store.GetRootFolder()
                $gmail = $root.Folders | Where-Object { $_.Name -eq "[Gmail]" }
                if (-not $gmail) { return $null }
                $sub = $gmail.Folders | Where-Object { $_.Name -eq $subName }
                return $sub
            } catch {
                return $null
            }
        }
        return $null
    }

    $foldersToScan = @()
    $foldersToScan += Get-Folder "tdamyan@gmail.com" "Inbox"
    $foldersToScan += Get-GmailSubfolder "tdamyan@gmail.com" "Important"
    $foldersToScan += Get-GmailSubfolder "tdamyan@gmail.com" "Sent Mail"

    $foldersToScan = $foldersToScan | Where-Object { $_ -ne $null }

    # Restrict to last 30 days for speed
    $cutoff = (Get-Date).AddDays(-30)
    Write-Host "`nSecond pass: scanning $($foldersToScan.Count) Gmail folders for items received after $($cutoff.ToShortDateString())...`n"

    $moved = @()
    $skipped = 0
    $scanned = 0

    foreach ($folder in $foldersToScan) {
        $items = $folder.Items
        $items.Sort("[ReceivedTime]", $true)

        # Restrict to recent items
        $filter = "[ReceivedTime] >= '" + $cutoff.ToString("g") + "'"
        try {
            $recentItems = $items.Restrict($filter)
            Write-Host "Scanning $($folder.FolderPath): $($recentItems.Count) items since $($cutoff.ToShortDateString())"
        } catch {
            $recentItems = $items
            Write-Host "Scanning $($folder.FolderPath): date filter failed, scanning all $($items.Count) items"
        }

        $count = $recentItems.Count
        $scanned += $count

        for ($i = $count; $i -ge 1; $i--) {
            try {
                $item = $recentItems.Item($i)
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
                # ignore
            }
        }

        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($recentItems) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($items) | Out-Null
    }

    Write-Host "`nSecond pass done."
    Write-Host "Scanned $scanned recent items across $($foldersToScan.Count) folders."
    Write-Host "Moved $($moved.Count) additional email(s)."
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
