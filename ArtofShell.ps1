<#########################################################

  Author: Trevor Sullivan <trevor@artofshell.com>
  Description: This PowerShell script demonstrates how to create a PowerShell
    Desired State Configuration (DSC) document.

COPYRIGHT NOTICE

This file is part of the "Microsoft Azure Automation" course, and is 
copyrighted by Art of Shell LLC. This file may not be copied or distributed, without 
written permission from an authorized member of Art of Shell LLC.
#########################################################>

configuration ArtofShell {
    Import-DscResource -ModuleName PSDesiredStateConfiguration;
    
    node @('web01', 'web02', 'web03') {
        WindowsFeature IIS {
            Name = 'Web-Server';
            Ensure = 'Present';
        }
    }

    node @('db01', 'db02') {
        ### Install .NET Framework dependency for SQL Server
        WindowsFeature NET-Framework-Core {
            Ensure = 'Present';
            Name = 'NET-Framework-Core';
        }
    }
}