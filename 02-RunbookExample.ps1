<#########################################################

  Author: Trevor Sullivan <trevor@artofshell.com>
  Description: This PowerShell script demonstrates how to create a simple PowerShell
    script that acts as an Azure Automation Runbook.

COPYRIGHT NOTICE

This file is part of the "Microsoft Azure Automation" course, and is 
copyrighted by Art of Shell LLC. This file may not be copied or distributed, without 
written permission from an authorized member of Art of Shell LLC.
#########################################################>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string] $CredentialName = 'AzureAdmin'
)

### The first thing we need to do is authenticate to Microsoft Azure using Azure Active Directory (AAD)
### because this Runbook is managing resources inside our Microsoft Azure Subscription.

### LEARNING POINT: We use the special Get-AutomationPSCredential command to retrieve a credential 
###                 from the Azure Automation Asset Store.
$AzureCredential = Get-AutomationPSCredential -Name $CredentialName;
Write-Verbose -Message 'Retrieved credential from Azure Automation Asset Store';

### LEARNING POINT: The reason we put "$null =" at the beginning, is to suppress output
###                 from the Add-AzureRmAccount command
$null = Add-AzureRmAccount -Credential $AzureCredential;
Write-Verbose -Message 'Finished authenticating to Microsoft Azure';

### Delete specific Azure Resource Manager (ARM) Resource Groups
Get-AzureRmResourceGroup | 
    Where-Object -FilterScript { $PSItem.Name -in @('ArtofShell-Test1', 'ArtofShell-Test2') } | 
    Remove-AzureRmResourceGroup -Force;

Write-Verbose -Message 'Runbook completed';