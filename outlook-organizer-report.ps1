#Requires -Version 5.1
$ErrorActionPreference = "Stop"

try {
    $ol = New-Object -ComObject Outlook.Application
    $ns = $ol.GetNamespace("MAPI")

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
        Write-Host "Target folder not found." -ForegroundColor Red
        exit 1
    }

    $items = $targetFolder.Items
    $items.Sort("[ReceivedTime]", $true)

    Write-Host "Target folder: $($targetFolder.FolderPath)"
    Write-Host "Total items: $($items.Count)"
    Write-Host "`nMost recent 30 items:`n"

    $report = @()
    $count = [Math]::Min(30, $items.Count)
    for ($i = 1; $i -le $count; $i++) {
        try {
            $item = $items.Item($i)
            $report += [PSCustomObject]@{
                Received = $item.ReceivedTime
                Sender = $item.SenderName
                SenderEmail = $item.SenderEmailAddress
                Subject = $item.Subject
            }
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($item) | Out-Null
        } catch {
            # ignore
        }
    }

    $report | Format-Table -AutoSize

    # Count by key sender
    Write-Host "`nCounts by key sender/domain:`n"
    $all = @()
    for ($i = 1; $i -le $items.Count; $i++) {
        try {
            $item = $items.Item($i)
            $addr = $item.SenderEmailAddress
            if ($addr.Contains("@")) {
                $domain = $addr.Split("@")[1]
            } else {
                $domain = $addr
            }
            $all += [PSCustomObject]@{ Domain = $domain }
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($item) | Out-Null
        } catch {}
    }
    $all | Group-Object -Property Domain | Sort-Object Count -Descending | Select-Object -First 20 | Format-Table -AutoSize

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    if ($ns) { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ns) | Out-Null }
    if ($ol) { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ol) | Out-Null }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
