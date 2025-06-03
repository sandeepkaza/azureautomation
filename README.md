# Azure Automation Scripts

A collection of PowerShell scripts to simplify and automate common Azure VM operations, with a focus on Zerto-integrated environments. These scripts are intended to streamline backup configuration, enable diagnostics, and apply VM tagging at scale across Azure subscriptions.

## ✨ Features

- **Auto-tagging VMs**  
  Automatically tag Azure VMs based on custom conditions to improve visibility and governance.

- **Enable Backup for Zerto VMs**  
  Quickly enable Azure Recovery Services Vault backups for virtual machines managed by Zerto.

- **Configure Boot Diagnostics**  
  Ensure all Zerto VMs have boot diagnostics configured for troubleshooting and compliance.

## 📁 Scripts Overview

| Script Name                          | Description                                                                 |
|-------------------------------------|-----------------------------------------------------------------------------|
| `AutoTagVMsBased.ps1`               | Tags VMs dynamically using defined tag keys and values                      |
| `Enable-Backup-For-Zerto-VMs.ps1`   | Enables backup for Zerto VMs using a defined vault and policy              |
| `Boot-Diagnostics-Update-ZertoVMs.ps1` | Configures storage accounts for boot diagnostics on targeted Zerto VMs  |

## ⚙️ Requirements

- Azure PowerShell Module (`Az`)
- Azure Automation Account (optional for runbook usage)
- Permissions to manage:
  - Virtual Machines
  - Recovery Services Vaults
  - Storage Accounts

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/sandeepkaza/azureautomation.git
   ```

2. Modify script parameters to match your environment (e.g., subscription IDs, tag values).

3. Execute scripts locally or import them into Azure Automation as runbooks.

## 📌 Notes

These scripts are meant to be templates—customize as needed for production environments. Consider adding logging, error handling, or parameter validation as required.

## 🙌 Contributions

Contributions and improvements are welcome! Feel free to fork the repo, submit pull requests, or open issues for discussion.

---

**Author:** [sandeepkaza](https://github.com/sandeepkaza)

**License:** MIT
