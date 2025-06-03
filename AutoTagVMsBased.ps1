<#
.SYNOPSIS
    Automatically tags all Azure VMs in specified resource groups with a custom tag.
.DESCRIPTION
    This script checks each VM in the given resource groups and applies a specified tag if it's not already present.
    Designed for use in Azure Automation with User Assigned Managed Identity (UAMI).
#>

# === Configuration ===
$tagKey = "ZertoRecovered"
$tagValue = "true"
$resourceGroups = @("AMI-Zerto-POC_2")
$uamiClientId = "7218f7db-6d77-4a2c-b227-6eec37aa6522"  # 🔁 Replace with your UAMI Client ID

# === Authenticate with UAMI ===
try {
    Connect-AzAccount -Identity -AccountId $uamiClientId
    Write-Host "✅ Connected to Azure using UAMI (Client ID: $uamiClientId)"
    Write-Host "🧭 Current Subscription: $(Get-AzContext).Subscription.Name"
}
catch {
    Write-Error "❌ Failed to authenticate with UAMI: $_"
    exit
}

# === Process Each Resource Group ===
foreach ($rg in $resourceGroups) {
    Write-Host "`n🔍 Checking Resource Group: $rg"

    $rgExists = Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue
    if (-not $rgExists) {
        Write-Warning "❌ Resource group '$rg' not found. Skipping..."
        continue
    }

    $vms = Get-AzVM -ResourceGroupName $rg -ErrorAction SilentlyContinue
    if (-not $vms) {
        Write-Warning "⚠️ No VMs found in resource group '$rg'."
        continue
    }

    foreach ($vm in $vms) {
        if ($vm.Tags -and $vm.Tags.ContainsKey($tagKey)) {
            Write-Host "➡️  Skipping $($vm.Name), tag already exists."
            continue
        }

        try {
            Write-Host "🔖 Tagging VM: $($vm.Name)..."

            $tags = @{}
            if ($vm.Tags) {
                foreach ($key in $vm.Tags.Keys) {
                    $tags[$key] = $vm.Tags[$key]
                }
            }

            $tags[$tagKey] = $tagValue

            Set-AzResource -ResourceId $vm.Id -Tag $tags -Force
            Write-Host "✅ Tagged $($vm.Name) with $tagKey=$tagValue"
        }
        catch {
            Write-Warning "❌ Failed to tag VM $($vm.Name): $_"
        }
    }
}

Write-Host "`n🎉 Tagging process complete."
