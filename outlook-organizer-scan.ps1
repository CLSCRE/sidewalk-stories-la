#Requires -Version 5.1
$ErrorActionPreference = "Stop"

try {
    $ol = New-Object -ComObject Outlook.Application
    $ns = $ol.GetNamespace("MAPI")

    function List-Folders($folder, $indent = 0) {
        Write-Host ("  " * $indent + $folder.Name + " [" + $folder.Items.Count + " items]")
        foreach ($sub in $folder.Folders) {
            List-Folders -folder $sub -indent ($indent + 1)
        }
    }

    Write-Host "=== Outlook Account / Store Structure ==="
    foreach ($store in $ns.Stores) {
        try {
            Write-Host "`nStore: $($store.DisplayName)"
            $root = $store.GetRootFolder()
            List-Folders -folder $root
        } catch {
            Write-Host "  Could not read store: $($_.Exception.Message)"
        }
    }

    Write-Host "`n=== Looking for 'Sidewalk Stories LA' folder ==="
    $targetFolder = $null
    foreach ($store in $ns.Stores) {
        try {
            $root = $store.GetRootFolder()
            foreach ($top in $root.Folders) {
                if ($top.Name -match "Inbox") {
                    foreach ($sub in $top.Folders) {
                        if ($sub.Name -like "*Sidewalk*") {
                            Write-Host "Found: $($store.DisplayName) > $($top.Name) > $($sub.Name)"
                            $targetFolder = $sub
                        }
                    }
                }
            }
        } catch {
            # ignore
        }
    }

    if (-not $targetFolder) {
        Write-Host "No folder matching '*Sidewalk*' was found under any Inbox. Please confirm the folder name."
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
