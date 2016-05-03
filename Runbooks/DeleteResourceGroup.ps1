[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string] $ResourceGroup
)

### Login to Microsoft Azure
Add-AzureRmAccount -Credential (Get-AutomationPSCredential -Name AzureAdmin);

### Delete an Azure Resource Manager (ARM) Resource Group
Remove-AzureRmResourceGroup -Name  -Force;