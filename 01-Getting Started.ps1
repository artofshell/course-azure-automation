<#########################################################

  Author: Trevor Sullivan <trevor@artofshell.com>
  Description: This PowerShell script demonstrates how to get started with
    Azure Automation using the Microsoft Azure PowerShell module.

COPYRIGHT NOTICE

This file is part of the "Microsoft Azure Automation" course, and is 
copyrighted by Art of Shell LLC. This file may not be copied or distributed, without 
written permission from an authorized member of Art of Shell LLC.
#########################################################>

### Install the Microsoft Azure Resource Manager (ARM) PowerShell module
Install-Module -Name AzureRM -Scope CurrentUser -Force;

### Install the Azure PowerShell Extensions (developed by Art of Shell)
Install-Module -Name AzureExt -Scope CurrentUser -Force;

### Install the Microsoft Azure Automation Authoring Toolkit (for PowerShell ISE)
Install-Module -Name AzureAutomationAuthoringToolkit -Scope CurrentUser -Force;

### Import the Azure Automation Authoring Toolkit
Import-Module -Name AzureAutomationAuthoringToolkit -Force;

### Inspect the commands for the Azure Automation module
Get-Command -Module AzureRM.Automation;

### Authenticate to Microsoft Azure using Azure Active Directory (AAD)
$AzureUsername = 'trevor@artofshell.com';
$AzureCredential = Get-Credential -Username $AzureUsername -Message 'Please enter your Microsoft Azure password.';
Add-AzureRmAccount -Credential $AzureCredential;

### Create a new Azure Resource Manager (ARM) Resource Group
$ResourceGroup = @{
    Name = 'ArtofShell-Automation';
    Location = 'West US';
    Force = $true;
}
New-AzureRmResourceGroup @ResourceGroup;

### Create a new Azure Automation Account
$AutomationAccount = @{
    ResourceGroupName = $ResourceGroup.Name;
    Name = 'ArtofShell';
    Location = 'West US';
    Plan = 'Free'; ### Basic is also supported
    Tags = @(
        @{ Name = 'Company'; Value = 'Art of Shell'; };
        @{ Name = 'Department'; Value = 'Marketing'; };
        )
    };
New-AzureRmAutomationAccount @AutomationAccount;

### Import an Azure Automation Runbook
Get-Command -Module AzureRM.Automation -Name *runbook*;

### Import an Azure Automation Runbook
$Runbook = @{
    AutomationAccountName = $AutomationAccount.Name;
    Path = '{0}\02-RunbookExample.ps1' -f $PSScriptRoot;
    Description = 'This is an example Runbook';
    Type = 'PowerShell';
    Published = $true;
    Force = $true;
    };
Import-AzureRmAutomationRunbook @Runbook;