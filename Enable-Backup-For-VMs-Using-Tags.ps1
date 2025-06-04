# === Configurable Inputs ===
$VaultName = "xxxxxxxxx"
$VaultRG = "xxxxxxxxxxxx"
$PolicyName = "Default-Policy"
$TagKey = "tag"
$TagValue = "true"
$uamiClientId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # UAMI client ID

# === Authenticate using UAMI ===
try {
    Connect-AzAccount -Identity -AccountId $uamiClientId
    Write-Output "✅ Connected using UAMI (Client ID: $uamiClientId)"
} catch {
    Write-Output "❌ Failed to authenticate with UAMI: $($_.Exception.Message)"
    exit
}

# === Set Recovery Services Vault context ===
try {
    $vault = Get-AzRecoveryServicesVault -Name $VaultName -ResourceGroupName $VaultRG -ErrorAction Stop
    Set-AzRecoveryServicesVaultContext -Vault $vault
    Write-Output "🔐 Vault context set: $VaultName ($VaultRG)"
} catch {
    Write-Output "❌ Failed to set Recovery Vault context: $($_.Exception.Message)"
    exit
}

# === Load backup policy ===
try {
    $policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name $PolicyName -ErrorAction Stop
    Write-Output "📄 Policy loaded: $PolicyName"
} catch {
    Write-Output "❌ Failed to retrieve backup policy: $($_.Exception.Message)"
    exit
}

# === Find tagged VMs ===
$vms = Get-AzVM | Where-Object { $_.Tags[$TagKey] -eq $TagValue }

if (-not $vms) {
    Write-Output "⚠️ No VMs found with tag [$TagKey=$TagValue]."
    return
}

foreach ($vm in $vms) {
    try {
        $vmName = $vm.Name
        $vmRG = $vm.ResourceGroupName
        Write-Output "`n➡️ Processing VM: $vmName in RG: $vmRG"

        # Ensure backup containers are available
        $containers = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -Status "Registered" -ErrorAction Stop

        if (-not $containers) {
            Write-Warning "⚠️ No backup containers returned. Skipping $vmName"
            continue
        }

        # Match container by FriendlyName
        $container = $containers | Where-Object { $_.FriendlyName -eq $vmName } | Select-Object -First 1

        if (-not $container) {
            Write-Warning "⚠️ No matching container found for VM: $vmName"
            continue
        }

        # Check if already actively protected
        $existingItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType "AzureVM"

        if ($existingItem -and $existingItem.ProtectionStatus -eq "Protected" -and $existingItem.ProtectionState -eq "Protected") {
            Write-Output "✅ Backup is already actively protected for VM: $vmName"
        } else {
            Write-Output "🛡️ Enabling backup for VM: $vmName"
            Enable-AzRecoveryServicesBackupProtection `
                -Policy $policy `
                -Name $vmName `
                -ResourceGroupName $vmRG
        }
    } catch {
        Write-Warning "❌ Failed to process VM '$($vm.Name)': $($_.Exception.Message)"
    }
}

Write-Output "`n🎉 Backup enablement task completed."
