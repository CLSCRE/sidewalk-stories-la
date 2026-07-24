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
        Write-Host "Target folder not found." -ForegroundColor Red
        exit 1
    }

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

    Write-Host "Target folder: $($targetFolder.FolderPath) [$($targetFolder.Items.Count) items]"
    Write-Host "Return drafts to: $($draftsFolder.FolderPath)`n"

    $items = $targetFolder.Items
    $count = $items.Count
    $returned = @()

    for ($i = $count; $i -ge 1; $i--) {
        try {
            $item = $items.Item($i)
            if ($item -is [Microsoft.Office.Interop.Outlook.MailItem]) {
                # Unsent = draft
                if ($item.Sent -eq $false) {
                    $subject = $item.Subject
                    try {
                        $item.Move($draftsFolder) | Out-Null
                        $returned += [PSCustomObject]@{
                            Subject = $subject
                        }
                    } catch {
                        Write-Host "Could not move '$subject': $($_.Exception.Message)" -ForegroundColor Yellow
                    }
                }
            }
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($item) | Out-Null
        } catch {
            # ignore
        }
    }

    Write-Host "Returned $($returned.Count) draft(s) to Drafts."
    if ($returned.Count -gt 0) {
        $returned | Format-Table -AutoSize
    }
    Write-Host "Target folder now has $($targetFolder.Items.Count) items."

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    if ($ns) { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ns) | Out-Null }
    if ($ol) { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ol) | Out-Null }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
