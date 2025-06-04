# === Configurable Inputs ===
$tagKey = "tag"
$tagValue = "true"
$uamiClientId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # UAMI client ID

# === Authenticate with UAMI ===
try {
    Connect-AzAccount -Identity -AccountId $uamiClientId
    Write-Output "✅ Connected using UAMI (Client ID: $uamiClientId)"
} catch {
    Write-Output "❌ Failed to authenticate with UAMI: $($_.Exception.Message)"
    exit
}

# === Get all subscriptions ===
$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions) {
    Set-AzContext -SubscriptionId $sub.Id
    Write-Output "`n🔄 Processing Subscription: $($sub.Name) [$($sub.Id)]"

    $vms = Get-AzVM -Status -ErrorAction SilentlyContinue | Where-Object {
        $_.Tags.ContainsKey($tagKey) -and $_.Tags[$tagKey] -eq $tagValue
    }

    if (-not $vms) {
        Write-Output "⚠️ No VMs with tag [$tagKey=$tagValue] found in subscription $($sub.Name)."
        continue
    }

    foreach ($vm in $vms) {
        $vmName = $vm.Name
        $rg = $vm.ResourceGroupName
        Write-Output "➡️ Processing VM: $vmName in RG: $rg"

        try {
            $fullVM = Get-AzVM -ResourceGroupName $rg -Name $vmName -ErrorAction Stop

            # Skip if already using managed diagnostics
            $diag = $fullVM.DiagnosticsProfile?.BootDiagnostics
            if ($diag -and $diag.Enabled -and (-not $diag.StorageUri)) {
                Write-Output "✅ Boot Diagnostics already enabled with managed storage for ${vmName}. Skipping."
                continue
            }

            # Enable Boot Diagnostics with managed storage account
            $bootDiag = New-Object -TypeName Microsoft.Azure.Management.Compute.Models.BootDiagnostics
            $bootDiag.Enabled = $true
            $bootDiag.StorageUri = $null

            if ($fullVM.DiagnosticsProfile -eq $null) {
                $fullVM.DiagnosticsProfile = New-Object -TypeName Microsoft.Azure.Management.Compute.Models.DiagnosticsProfile
            }

            $fullVM.DiagnosticsProfile.BootDiagnostics = $bootDiag

            # Apply update
            Update-AzVM -ResourceGroupName $rg -VM $fullVM -ErrorAction Stop
            Write-Output "✅ Boot Diagnostics (managed storage) enabled for ${vmName}"
        } catch {
            Write-Output "❌ Failed to update ${vmName}: $($_.Exception.Message)"
        }
    }
}

Write-Output "`n🎉 Boot Diagnostics update (managed storage) complete."
