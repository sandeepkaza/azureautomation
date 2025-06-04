# Azure Automation Scripts

A curated set of PowerShell scripts to automate Azure virtual machine tasks, with emphasis on Zerto-integrated environments. These scripts help streamline operations such as backup enablement, boot diagnostics configuration, and dynamic tagging across Azure subscriptions.

## ✨ Features

- **🎯 Auto-Tagging VMs**  
  Apply custom tags to Azure VMs dynamically, improving resource tracking and governance.

- **💾 VM Backup Automation**  
  Automatically enable Recovery Services Vault backups for VMs based on tags.

- **🛠 Boot Diagnostics Configuration**  
  Ensure all tagged VMs have boot diagnostics enabled with the correct storage account configuration.

## 📁 Script Summary

| Script Name                                          | Description                                                                  |
|-----------------------------------------------------|------------------------------------------------------------------------------|
| `AutoTagVMs.ps1`                                    | Automatically tags VMs using specified key-value pairs                       |
| `Enable-Backup-For-VMs-Using-Tags.ps1`              | Enables backup for VMs based on tag filters using a specified backup policy |
| `Boot-Diagnostics-Update-Using-Tags.ps1`            | Updates or enables boot diagnostics for tagged VMs with specified storage   |

## ⚙️ Prerequisites

- Azure PowerShell Module (`Az`)
- Azure Automation Account (for scheduled or scalable execution)
- Required role assignments:
  - **Reader** and **Contributor** for VM management
  - **Backup Contributor** for Recovery Services Vault
  - **Storage Account Contributor** for boot diagnostics

## 🚀 How to Use

1. **Clone the Repository**
   ```bash
   git clone https://github.com/sandeepkaza/azureautomation.git
   cd azureautomation
   ```

2. **Customize Script Parameters**
   Open each `.ps1` file and set variables such as subscription ID, tag keys, storage account names, etc.

3. **Run Locally or Upload to Azure Automation**
   Scripts can be executed locally via PowerShell or converted into runbooks for automation.

## 📘 Usage Examples

### Run a script locally
```powershell
# Example: Enable backup for VMs with specific tag
.\Enable-Backup-For-VMs-Using-Tags.ps1 -VaultName "MyVault" -VaultRG "MyResourceGroup" -PolicyName "DefaultPolicy" -TagKey "BackupEnabled" -TagValue "true"
```

### Schedule with Azure Automation (via Azure DevOps Pipeline)
```yaml
trigger:
  - main

pool:
  vmImage: 'windows-latest'

jobs:
- job: RunAutomation
  steps:
    - task: AzurePowerShell@5
      inputs:
        azureSubscription: '<AzureServiceConnection>'
        ScriptPath: 'scripts/Enable-Backup-For-VMs-Using-Tags.ps1'
        ScriptArguments: '-VaultName "MyVault" -VaultRG "MyRG" -PolicyName "DefaultPolicy" -TagKey "BackupEnabled" -TagValue "true"'
        azurePowerShellVersion: LatestVersion
```

## 💡 Best Practices

- Test scripts in a non-production environment
- Enable logging and add error handling for resilience
- Schedule runbooks in Azure Automation for ongoing management

## 🙌 Contributions

We welcome suggestions and improvements! Feel free to fork the repo, raise issues, or submit pull requests.

---

**Author:** [sandeepkaza](https://github.com/sandeepkaza)  
**License:** MIT
