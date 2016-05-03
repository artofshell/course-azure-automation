<#########################################################

  Author: Trevor Sullivan <trevor@artofshell.com>
  Description: This PowerShell script demonstrates how to manage the Microsoft Azure
    Automation service using the Azure Resource Manager (ARM) PowerShell module.

COPYRIGHT NOTICE

This file is part of the "Microsoft Azure Automation" course, and is 
copyrighted by Art of Shell LLC. This file may not be copied or distributed, without 
written permission from an authorized member of Art of Shell LLC.
#########################################################>

#region Install Azure PowerShell Modules

$Result = Read-Host -Prompt 'Install Azure PowerShell modules? (y/n)';

if ($Result -eq 'y') {
    ### Install the official Microsoft Azure Resource Manager (ARM) PowerShell module
    Install-Module -Name AzureRM -Scope CurrentUser -Force;

    ### Install the official Microsoft Azure Automation ISE Add-on
    Install-Module -Name AzureAutomationAuthoringToolkit -Scope CurrentUser -Force;

    ### Install the Art of Shell Azure PowerShell Extensions
    Install-Module -Name AzureExt -Scope CurrentUser -Force;
}

#endregion

#region Microsoft Azure Authentication

$Result = Read-Host -Prompt 'Authenticate to Microsoft Azure manually? (y/n)';

if ($Result -eq 'y') {
    ### Authenticate to Microsoft Azure using Azure Active Directory (AAD)
    $AzureUsername = 'aos@artofshell.com';
    $AzureCredential = Get-Credential -Username $AzureUsername -Message 'Please enter your Microsoft Azure password.';
    Add-AzureRmAccount -Credential $AzureCredential;
}

### This command, part of Azure PowerShell Extensions, simplifies authentication
### and loads Intellisense + ISE Snippets all at once.
Start-AzureRm;

#endregion

#region Azure Resource Manager (ARM) Resource Group
$Result = Read-Host -Prompt 'Create Azure Resource Manager (ARM) Resource Group? (y/n)';

if ($Result -eq 'y') {
    $ResourceGroup = @{
        Name = 'ArtofShell-Automation';
        Location = 'South Central US';
        Force = $true;
    }
    New-AzureRmResourceGroup @ResourceGroup;
}
#endregion

#region Automation Account

Get-Command -Module AzureRM.Automation -Name *AutomationAccount* | Format-Table -AutoSize;

$Result = Read-Host -Prompt 'Create Azure Automation Account? (y/n)';

if ($Result -eq 'y') {
    $AutomationAccount = @{
        ResourceGroupName = $ResourceGroup.Name;
        AutomationAccountName = 'ArtofShell-Automation';
        Location = $ResourceGroup.Location;
        };
    New-AzureRmAutomationAccount @AutomationAccount;
}
#endregion

#region Getting Started with Azure Automation Runbooks

### Inspect commands related to Microsoft Azure Automation Runbooks
Get-Command -Module AzureRM.Automation -Name *runbook*, *webhook*;

$Result = Read-Host -Prompt 'Import Azure Automation Runbook? (y/n)';

if ($Result -eq 'y') {
    $Runbook = @{
        ResourceGroupName = $AutomationAccount.ResourceGroupName;
        AutomationAccountName = $AutomationAccount.AutomationAccountName;
        Path = '{0}\02-RunbookExample.ps1' -f $PSScriptRoot;
        Name = 'DeleteAzureResourceGroups';
        Type = 'PowerShell';
        Published = $true;
        LogVerbose = $true;
        };
    Import-AzureRmAutomationRunbook @Runbook;
}

$Result = Read-Host -Prompt 'Start Azure Automation Runbook? (y/n)';

if ($Result -eq 'y') {
    $Runbook = @{
        ResourceGroupName = $AutomationAccount.ResourceGroupName;
        AutomationAccountName = $AutomationAccount.AutomationAccountName;
        Name = 'DeleteAzureResourceGroups';
        Parameters = @{
            CredentialName = 'AzureAdmin';
            };
        Wait = $true;
        };
    $Job = Start-AzureRmAutomationRunbook @Runbook;

    ### Retrieve the Runbook Job results
    $RunbookJob = @{
        ResourceGroupName = $AutomationAccount.ResourceGroupName;
        AutomationAccountName = $AutomationAccount.AutomationAccountName;
        Id = $Job.JobId;
        }
    Get-AzureRmAutomationJobOutput @RunbookJob;
}

#endregion

#region Getting Started with Azure Automation Runbooks

### Inspect commands related to Microsoft Azure Automation DSC
Get-Command -Module AzureRM.Automation -Name *dsc*;

### Import a Desired State Configuration (DSC) Document
$Result = Read-Host -Prompt 'Import DSC Configuration to Azure Automation? (y/n)';

if ($Result -eq 'y') {
    $ImportDsc = @{
        ResourceGroupName = $AutomationAccount.ResourceGroupName;
        AutomationAccountName = $AutomationAccount.AutomationAccountName;
        SourcePath = '{0}\ArtofShell.ps1' -f $PSScriptRoot;
        Description = 'This DSC Configuration contains the infrastructure configuration for the Art of Shell organization.';
        Published = $true;
        Force = $true;
        };
    Import-AzureRmAutomationDscConfiguration @ImportDsc;

    $CompilationJob = @{
        ResourceGroupName = $AutomationAccount.ResourceGroupName;
        AutomationAccountName = $AutomationAccount.AutomationAccountName;
        ConfigurationName = 'ArtofShell';
        }
    Start-AzureRmAutomationDscCompilationJob @CompilationJob;

    #region Deploy an Azure Resource Manager (ARM) JSON Template containing a DSC Node
    $Deployment = @{
        ResourceGroupName = $ResourceGroup.Name ### This is the Resource Group where the ARM JSON Template will be deployed into
        Name = 'ArtofShell-DSC-VM';   ### This is the name of the Deployment object that will be created inside the Resource Group
        TemplateFile = '{0}\04-Azure Automation DSC Node.json' -f $PSScriptRoot;            ### The URL to the publicly (anonymously) accessible ARM JSON Template file
        TemplateParameterObject = @{ ### These are the input parameters that are fed to the ARM Template
            adminUsername = 'aos';
            adminPassword = 'ILove!Aos!';
            dnsLabelPrefix = 'artofshell-dsc';
        }
        Mode = 'Incremental';        ### You can perform an "incremental" deployment or a "complete" deployment, 
                                     ### the latter of which wipes out all existing resources in the target Resource Group.
        DeploymentDebugLogLevel = 'All';
        Force = $true;
    }
    New-AzureRmResourceGroupDeployment @Deployment;
    #endregion

    ### Register an Azure Virtual Machine
    $NodeRegistration = @{
        ResourceGroupName = $AutomationAccount.ResourceGroupName;
        AutomationAccountName = $AutomationAccount.AutomationAccountName;
        AzureVMName = 'ArtofShellDSC';
        NodeConfigurationName = 'ArtofShell.web01';
        };
    Register-AzureRmAutomationDscNode @NodeRegistration;
}
#endregion